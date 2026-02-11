import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'package:pos_mobile/domain/entities/order.dart';
import 'package:pos_mobile/domain/entities/order_item.dart';
import 'package:pos_mobile/domain/entities/order_status.dart';
import 'package:pos_mobile/domain/entities/restaurant_table.dart';
import 'package:pos_mobile/presentation/features/auth/auth_controller.dart';
import 'package:pos_mobile/data/repositories/orders_repository_impl.dart';
import 'package:pos_mobile/core/services/printing_service.dart';

class TableOrderDetailsDialog extends ConsumerStatefulWidget {
  final RestaurantTable table;

  const TableOrderDetailsDialog({super.key, required this.table});

  @override
  ConsumerState<TableOrderDetailsDialog> createState() =>
      _TableOrderDetailsDialogState();
}

class _TableOrderDetailsDialogState
    extends ConsumerState<TableOrderDetailsDialog> {
  bool _isLoading = false;
  Order? _activeOrder;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);
    try {
      final token = ref.read(authControllerProvider).value?.accessToken;
      if (token == null) return;

      final orders =
          await ref.read(ordersRepositoryProvider).fetchOrders(token);

      // Find active order for this table
      try {
        final order = orders.firstWhere(
          (o) =>
              (o.tableNumber == widget.table.tableNumber ||
                  o.tableNumber == widget.table.id) &&
              o.status != OrderStatus.COMPLETED &&
              o.status != OrderStatus.CANCELLED,
        );
        if (mounted) {
          setState(() {
            _activeOrder = order;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _activeOrder = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching order: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fireCourse(String course) async {
    if (_activeOrder == null) return;

    setState(() => _isLoading = true);
    try {
      final token = ref.read(authControllerProvider).value?.accessToken;
      if (token == null) return;

      await ref.read(ordersRepositoryProvider).fireCourse(
            token,
            _activeOrder!.id,
            course,
          );

      await _fetchOrder();

      if (_activeOrder != null) {
        try {
          await ref.read(printingServiceProvider).printKitchenTicket(
                _activeOrder!,
                onlyCourse: course,
              );
        } catch (e) {
          print('Printing error: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.firedCourse(course))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .tableOrderTitle(widget.table.tableNumber)),
      content: SizedBox(
        width: 500,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activeOrder == null
                ? Center(
                    child:
                        Text(AppLocalizations.of(context)!.noActiveOrderFound))
                : _buildOrderDetails(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    // Group items by course
    final Map<String, List<OrderItem>> itemsByCourse = {};
    for (final item in _activeOrder!.items) {
      final course = item.product.course; // Uses default 'OTHER' if null
      if (!itemsByCourse.containsKey(course)) {
        itemsByCourse[course] = [];
      }
      itemsByCourse[course]!.add(item);
    }

    // Define course order
    final courseOrder = ['STARTER', 'MAIN', 'DESSERT', 'DRINK', 'OTHER'];
    final sortedCourses = itemsByCourse.keys.toList()
      ..sort((a, b) {
        final indexA = courseOrder.indexOf(a);
        final indexB = courseOrder.indexOf(b);
        return (indexA == -1 ? 99 : indexA)
            .compareTo(indexB == -1 ? 99 : indexB);
      });

    return ListView(
      children: sortedCourses.map((course) {
        final items = itemsByCourse[course]!;
        final hasHeldItems = items.any((i) => i.status == 'HELD');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  course,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: hasHeldItems
                    ? ElevatedButton.icon(
                        onPressed: () => _fireCourse(course),
                        icon: const Icon(Icons.local_fire_department),
                        label: Text(AppLocalizations.of(context)!.fire),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : null,
              ),
              const Divider(),
              ...items.map((item) => ListTile(
                    title: Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? item.product.nameAr
                            : item.product.nameEn),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.modifiers.isNotEmpty)
                          ...item.modifiers.map((m) => Text(
                              '+ ${Localizations.localeOf(context).languageCode == 'ar' ? m.nameAr : m.nameEn}')),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Text(AppLocalizations.of(context)!.note(item.notes!)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context)!
                            .quantityCount(item.quantity)),
                        const SizedBox(width: 8),
                        _buildStatusBadge(item.status),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color = Colors.grey;
    if (status == 'PENDING') color = Colors.blue;
    if (status == 'PREPARING') color = Colors.orange;
    if (status == 'READY') color = Colors.green;
    if (status == 'SERVED') color = Colors.black54;
    if (status == 'HELD') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'PENDING',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}


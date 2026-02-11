import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/entities/order_item.dart' as order_item;
import '../../../domain/entities/order_status.dart';
import '../../../core/services/printing_service.dart';
import 'kitchen_controller.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  String? _selectedStationId;

  @override
  Widget build(BuildContext context) {
    final ordersAsync =
        ref.watch(kitchenControllerProvider(_selectedStationId));
    final stationsAsync = ref.watch(stationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.kitchenDisplaySystem),
        actions: [
          stationsAsync.when(
            data: (stations) => DropdownButton<String>(
              value: _selectedStationId,
              hint: Text(AppLocalizations.of(context)!.allStations,
                  style: const TextStyle(color: Colors.white)),
              dropdownColor: Colors.blue,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                setState(() => _selectedStationId = val);
              },
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(AppLocalizations.of(context)!.allStations),
                ),
                ...stations.map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    )),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(kitchenControllerProvider(_selectedStationId).notifier)
                .refresh(),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildKanbanBoard(orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  Widget _buildKanbanBoard(List<domain.Order> orders) {
    final pending =
        orders.where((o) => o.status == OrderStatus.PENDING).toList();
    final preparing =
        orders.where((o) => o.status == OrderStatus.PREPARING).toList();
    final ready = orders.where((o) => o.status == OrderStatus.READY).toList();

    return Row(
      children: [
        Expanded(
            child: _buildColumn(AppLocalizations.of(context)!.pending, pending,
                Colors.orange.shade100, OrderStatus.PREPARING)),
        Expanded(
            child: _buildColumn(AppLocalizations.of(context)!.preparing,
                preparing, Colors.blue.shade100, OrderStatus.READY)),
        Expanded(
            child: _buildColumn(AppLocalizations.of(context)!.ready, ready,
                Colors.green.shade100, OrderStatus.SERVED)),
      ],
    );
  }

  Widget _buildColumn(String title, List<domain.Order> orders, Color color,
      OrderStatus nextStatus) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            '$title (${orders.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, nextStatus);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(domain.Order order, OrderStatus nextStatus) {
    final duration = DateTime.now().difference(order.createdAt);
    final minutes = duration.inMinutes;

    // Filter and group items
    final itemsToShow = order.items.where((i) => i.status != 'HELD').toList();
    if (itemsToShow.isEmpty) return const SizedBox.shrink();

    final itemsByCourse = <String, List<order_item.OrderItem>>{};
    for (final item in itemsToShow) {
      final course = item.product.course;
      itemsByCourse.putIfAbsent(course, () => []).add(item);
    }

    final courseOrder = ['STARTER', 'MAIN', 'DESSERT', 'DRINK', 'OTHER'];
    final sortedCourses = itemsByCourse.keys.toList()
      ..sort((a, b) {
        final indexA = courseOrder.indexOf(a);
        final indexB = courseOrder.indexOf(b);
        return (indexA == -1 ? 99 : indexA)
            .compareTo(indexB == -1 ? 99 : indexB);
      });

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .tableNumber(order.tableNumber ?? "?"),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${minutes}m',
                  style: TextStyle(
                    color: minutes > 15 ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sortedCourses.map((course) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...((itemsByCourse[course] ?? const <order_item.OrderItem>[]).map((item) => Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.quantityCount(item.quantity)} ${Localizations.localeOf(context).languageCode == 'ar' ? item.product.nameAr : item.product.nameEn}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              if (item.modifiers.isNotEmpty)
                                Text(
                                  item.modifiers
                                      .map((m) =>
                                          '+ ${Localizations.localeOf(context).languageCode == 'ar' ? m.nameAr : m.nameEn}')
                                      .join(', '),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blueGrey),
                                ),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Text(
                                  AppLocalizations.of(context)!
                                      .note(item.notes!),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ))),
                    const Divider(height: 12),
                  ],
                )),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: Text(AppLocalizations.of(context)!.print),
                    onPressed: () {
                      ref
                          .read(printingServiceProvider)
                          .printKitchenTicket(order);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(kitchenControllerProvider(_selectedStationId)
                              .notifier)
                          .updateStatus(order.id, nextStatus);
                    },
                    child: Text(
                        AppLocalizations.of(context)!.moveTo(nextStatus.name)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


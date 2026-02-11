import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import 'my_deliveries_controller.dart';
import 'package:intl/intl.dart';

class MyDeliveriesScreen extends ConsumerWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(myDeliveriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myDeliveries),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(myDeliveriesControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: deliveriesAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
                child:
                    Text(AppLocalizations.of(context)!.noAssignedDeliveries));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _DeliveryOrderCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
    );
  }
}

class _DeliveryOrderCard extends ConsumerWidget {
  final Order order;

  const _DeliveryOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .orderNumber(order.id.substring(0, 8)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    order.status.name,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.addressLabel(
                order.deliveryAddress ??
                    AppLocalizations.of(context)!.noAddress)),
            if (order.customerName != null)
              Text(AppLocalizations.of(context)!
                  .customerLabel(order.customerName!)),
            const SizedBox(height: 8),
            const Divider(),
            ...order.items.map((item) {
              final isArabic =
                  Localizations.localeOf(context).languageCode == 'ar';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${item.quantity}x ${isArabic ? item.product.nameAr : item.product.nameEn}'),
                    Text(
                        '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    AppLocalizations.of(context)!.totalLabel(order.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, ref, order),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Order order) {
    if (order.status == OrderStatus.READY ||
        order.status == OrderStatus.PREPARING) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.directions_bike),
          label: Text(AppLocalizations.of(context)!.startDelivery),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: () {
            ref
                .read(myDeliveriesControllerProvider.notifier)
                .updateStatus(order.id, OrderStatus.ON_DELIVERY);
          },
        ),
      );
    } else if (order.status == OrderStatus.ON_DELIVERY) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: Text(AppLocalizations.of(context)!.markAsDelivered),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.white),
          onPressed: () {
            ref
                .read(myDeliveriesControllerProvider.notifier)
                .updateStatus(order.id, OrderStatus.DELIVERED);
          },
        ),
      );
    } else if (order.status == OrderStatus.DELIVERED) {
      return SizedBox(
        width: double.infinity,
        child: Text(AppLocalizations.of(context)!.completed,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.green)),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
      case OrderStatus.PREPARING:
        return Colors.orange;
      case OrderStatus.READY:
        return Colors.blue;
      case OrderStatus.ON_DELIVERY:
        return Colors.purple;
      case OrderStatus.DELIVERED:
      case OrderStatus.COMPLETED:
      case OrderStatus.SERVED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case OrderStatus.HELD:
        return Colors.grey;
    }
  }
}

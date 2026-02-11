import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_type.dart';
import '../../../domain/entities/order_status.dart';
import '../../features/users/users_controller.dart';
import 'delivery_orders_controller.dart';

class DeliveryOrdersScreen extends ConsumerWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(deliveryOrdersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deliveryManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(deliveryOrdersControllerProvider);
            },
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          final deliveryOrders = orders
              .where((o) =>
                  o.type == OrderType.DELIVERY &&
                  o.status != OrderStatus.COMPLETED &&
                  o.status != OrderStatus.CANCELLED)
              .toList();

          if (deliveryOrders.isEmpty) {
            return Center(
                child:
                    Text(AppLocalizations.of(context)!.noActiveDeliveryOrders));
          }

          return ListView.builder(
            itemCount: deliveryOrders.length,
            itemBuilder: (context, index) {
              final order = deliveryOrders[index];
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
    final hasDriver = order.driverId != null && order.driverId!.isNotEmpty;
    final hasExternalProvider =
        order.deliveryProvider != null && order.deliveryProvider!.isNotEmpty;

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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Chip(
                  label: Text(order.status.name),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.addressLabel(
                order.deliveryAddress ??
                    AppLocalizations.of(context)!.noAddress)),
            if (order.deliveryFee > 0)
              Text(AppLocalizations.of(context)!
                  .deliveryFeeLabel(order.deliveryFee)),
            if (hasExternalProvider)
              Text(
                  AppLocalizations.of(context)!.providerLabel(
                      order.deliveryProvider!, order.deliveryReferenceId ?? ''),
                  style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.itemsCount(order.items.length)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.totalLabel(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (hasExternalProvider)
                  Chip(
                      avatar: const Icon(Icons.delivery_dining),
                      label:
                          Text(AppLocalizations.of(context)!.externalDelivery))
                else if (hasDriver)
                  Chip(
                    avatar: const Icon(Icons.drive_eta),
                    label: Text(AppLocalizations.of(context)!
                        .driverAssigned), // In real app, fetch driver name
                  )
                else
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.delivery_dining),
                        label: Text(AppLocalizations.of(context)!.uberEats),
                        onPressed: () => ref
                            .read(deliveryOrdersControllerProvider.notifier)
                            .requestExternalDelivery(order.id, 'uber-eats'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: Text(AppLocalizations.of(context)!.assignDriver),
                        onPressed: () => _showAssignDriverDialog(context, ref),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange.shade100;
      case OrderStatus.PREPARING:
        return Colors.blue.shade100;
      case OrderStatus.READY:
        return Colors.green.shade100;
      case OrderStatus.SERVED: // Used for On Delivery maybe?
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showAssignDriverDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AssignDriverDialog(orderId: order.id),
    );
  }
}

class _AssignDriverDialog extends ConsumerStatefulWidget {
  final String orderId;

  const _AssignDriverDialog({required this.orderId});

  @override
  ConsumerState<_AssignDriverDialog> createState() =>
      _AssignDriverDialogState();
}

class _AssignDriverDialogState extends ConsumerState<_AssignDriverDialog> {
  String? selectedDriverId;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersControllerProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.assignDriver),
      content: usersAsync.when(
        data: (users) {
          final drivers = users.where((u) => u.role == 'driver').toList();
          if (drivers.isEmpty) {
            return Text(AppLocalizations.of(context)!.noDriversFound);
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return RadioListTile<String>(
                  title: Text(driver.name),
                  subtitle: Text(driver.email),
                  value: driver.id,
                  groupValue: selectedDriverId,
                  onChanged: (val) => setState(() => selectedDriverId = val),
                );
              },
            ),
          );
        },
        loading: () => const SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => Text('${AppLocalizations.of(context)!.error}: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: selectedDriverId == null
              ? null
              : () {
                  ref
                      .read(deliveryOrdersControllerProvider.notifier)
                      .assignDriver(widget.orderId, selectedDriverId!);
                  Navigator.pop(context);
                },
          child: Text(AppLocalizations.of(context)!.assign),
        ),
      ],
    );
  }
}

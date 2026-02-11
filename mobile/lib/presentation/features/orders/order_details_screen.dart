import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/entities/refund.dart';
import 'orders_history_controller.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final _refundReasonController = TextEditingController();
  final _refundAmountController = TextEditingController();
  final _voidReasonController = TextEditingController();
  bool _returnStock = true;

  @override
  void dispose() {
    _refundReasonController.dispose();
    _refundAmountController.dispose();
    _voidReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    // We might want to watch the order from provider to get updates,
    // but for now let's use the passed order and assume list updates on return.
    // Better: Watch the specific order from a provider if available, or just rely on list refresh.

    // To get updated status after actions, we really should rely on the list provider refreshing
    // or fetch details again. For simplicity, we'll pop this screen after actions or use a provider that updates.

    // Actually, let's use the order from the list provider if possible, or just the passed one.
    // If we want real-time updates after action, we should probably re-fetch.

    final canRefund = (order.status == OrderStatus.COMPLETED ||
            order.status == OrderStatus.DELIVERED ||
            order.status == OrderStatus.SERVED) &&
        order.paymentStatus == 'PAID' &&
        order.status != OrderStatus.REFUNDED &&
        order.status != OrderStatus.VOIDED;

    final canVoid = order.status != OrderStatus.VOIDED &&
        order.status != OrderStatus.REFUNDED &&
        order.status != OrderStatus.COMPLETED &&
        order.status != OrderStatus.DELIVERED;
    // Usually void is for active orders. If completed, use refund.

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
            .orderNumber(order.id.substring(0, 8))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                AppLocalizations.of(context)!.status, order.status.name),
            _buildInfoRow(AppLocalizations.of(context)!.paymentStatus,
                order.paymentStatus),
            _buildInfoRow(
                AppLocalizations.of(context)!.totalLabel(order.totalAmount),
                ''),
            _buildInfoRow(
                AppLocalizations.of(context)!.date,
                DateFormat('yyyy-MM-dd HH:mm',
                        Localizations.localeOf(context).toString())
                    .format(order.createdAt)),
            if (order.tableNumber != null)
              _buildInfoRow(
                  AppLocalizations.of(context)!.table, order.tableNumber!),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.itemsTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...order.items.map((item) {
              final isArabic =
                  Localizations.localeOf(context).languageCode == 'ar';
              return ListTile(
                title:
                    Text(isArabic ? item.product.nameAr : item.product.nameEn),
                subtitle: Text(AppLocalizations.of(context)!
                    .itemPriceQuantity(item.quantity, item.price)),
                trailing: Text(AppLocalizations.of(context)!
                    .priceLabel(item.quantity * item.price)),
              );
            }),
            if (order.refunds != null && order.refunds!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.refundsTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...order.refunds!.map((refund) => Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      title: Text(
                          '${AppLocalizations.of(context)!.refundLabel(refund.amount)} - ${refund.status}'),
                      subtitle: Text(
                          '${AppLocalizations.of(context)!.reasonLabel(refund.reason)}\n${DateFormat('yyyy-MM-dd HH:mm', Localizations.localeOf(context).toString()).format(refund.createdAt)}'),
                      trailing: refund.status == 'PENDING'
                          ? ElevatedButton(
                              onPressed: () => _approveRefund(refund),
                              child:
                                  Text(AppLocalizations.of(context)!.approve),
                            )
                          : null,
                    ),
                  )),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (canRefund)
                  ElevatedButton.icon(
                    onPressed: _showRefundDialog,
                    icon: const Icon(Icons.replay),
                    label: Text(AppLocalizations.of(context)!.requestRefund),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                if (canVoid)
                  ElevatedButton.icon(
                    onPressed: _showVoidDialog,
                    icon: const Icon(Icons.cancel),
                    label: Text(AppLocalizations.of(context)!.voidOrder),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showRefundDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.requestRefund),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _refundAmountController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _refundReasonController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reason),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_refundAmountController.text);
              if (amount == null || amount <= 0) return;

              Navigator.pop(ctx);
              try {
                await ref
                    .read(ordersActionsControllerProvider.notifier)
                    .requestRefund(
                        widget.order.id, amount, _refundReasonController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.refundRequested)));
                  Navigator.pop(context); // Go back to list to refresh
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('${AppLocalizations.of(context)!.error}: $e')));
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      ),
    );
  }

  void _showVoidDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.voidOrder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _voidReasonController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.reason),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.returnStock),
                value: _returnStock,
                onChanged: (val) => setState(() => _returnStock = val),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ref
                      .read(ordersActionsControllerProvider.notifier)
                      .voidOrder(widget.order.id, _voidReasonController.text,
                          _returnStock);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.orderVoided)));
                    Navigator.pop(context); // Go back to list
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '${AppLocalizations.of(context)!.error}: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.voidAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveRefund(Refund refund) async {
    try {
      await ref
          .read(ordersActionsControllerProvider.notifier)
          .approveRefund(refund.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.refundApproved)));
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e')));
      }
    }
  }
}

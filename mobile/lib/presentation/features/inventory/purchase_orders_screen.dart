import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'inventory_controller.dart';
import '../../../../domain/entities/purchase_order.dart';

class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(purchaseOrdersControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePODialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: posAsync.when(
        data: (pos) {
          if (pos.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noPurchaseOrders));
          }
          return ListView.builder(
            itemCount: pos.length,
            itemBuilder: (context, index) {
              final po = pos[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.poNumber(
                      po.id.substring(0, 8),
                      po.supplier?.name ?? "Unknown Supplier")),
                  subtitle: Text(AppLocalizations.of(context)!
                      .poStatusTotal(po.status, po.totalAmount)),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PurchaseOrderDetailsScreen(po: po)),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  void _showCreatePODialog(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.read(suppliersControllerProvider);
    // Ensure suppliers are loaded
    if (suppliersAsync is! AsyncData) {
      // Trigger load if needed or show error
      // For now assume loaded or loading
    }

    // We need to pick a supplier.
    // Let's just show a simple dialog that loads suppliers.
    showDialog(
      context: context,
      builder: (context) => const CreatePODialog(),
    );
  }
}

class CreatePODialog extends ConsumerStatefulWidget {
  const CreatePODialog({super.key});

  @override
  ConsumerState<CreatePODialog> createState() => _CreatePODialogState();
}

class _CreatePODialogState extends ConsumerState<CreatePODialog> {
  String? selectedSupplierId;
  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersControllerProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createPO),
      content: suppliersAsync.when(
        data: (suppliers) {
          if (suppliers.isEmpty)
            return Text(AppLocalizations.of(context)!.noSuppliersAvailable);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedSupplierId,
                hint: Text(AppLocalizations.of(context)!.selectSupplier),
                items: suppliers
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedSupplierId = val),
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.notesDescription),
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, s) => Text('${AppLocalizations.of(context)!.error}: $e'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedButton(
          onPressed: selectedSupplierId == null
              ? null
              : () {
                  ref.read(purchaseOrdersControllerProvider.notifier).createPO(
                        selectedSupplierId!,
                        notesController.text,
                      );
                  Navigator.pop(context);
                },
          child: Text(AppLocalizations.of(context)!.create),
        ),
      ],
    );
  }
}

class PurchaseOrderDetailsScreen extends ConsumerWidget {
  final PurchaseOrder po;

  const PurchaseOrderDetailsScreen({super.key, required this.po});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific PO from the list to get updates
    final posList = ref.watch(purchaseOrdersControllerProvider).valueOrNull;
    final currentPO = posList?.firstWhere((element) => element.id == po.id,
            orElse: () => po) ??
        po;

    return Scaffold(
      appBar: AppBar(
          title:
              Text(AppLocalizations.of(context)!.poDetails(currentPO.status))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.suppliers}: ${currentPO.supplier?.name ?? "Unknown"}',
                ),
                Text(
                  '${AppLocalizations.of(context)!.total}: ${currentPO.totalAmount.toStringAsFixed(2)}',
                ),
                Text(
                    '${AppLocalizations.of(context)!.notesDescription}: ${currentPO.notes ?? "-"}'),
                if (currentPO.status == 'draft')
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(purchaseOrdersControllerProvider.notifier)
                            .receivePO(currentPO.id);
                        Navigator.pop(context); // Go back after receiving
                      },
                      child: Text(AppLocalizations.of(context)!.receiveOrder),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: currentPO.items.length,
              itemBuilder: (context, index) {
                final item = currentPO.items[index];
                return ListTile(
                  title: Text(item.ingredient?.name ?? 'Item'),
                  subtitle: Text('${item.quantity} x ${item.unitPrice}'),
                  trailing: Text(item.totalPrice.toStringAsFixed(2)),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: currentPO.status == 'draft'
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context, ref, currentPO.id),
              child: const Icon(Icons.add_shopping_cart),
            )
          : null,
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, String poId) {
    showDialog(
      context: context,
      builder: (context) => AddPOItemDialog(poId: poId),
    );
  }
}

class AddPOItemDialog extends ConsumerStatefulWidget {
  final String poId;
  const AddPOItemDialog({super.key, required this.poId});

  @override
  ConsumerState<AddPOItemDialog> createState() => _AddPOItemDialogState();
}

class _AddPOItemDialogState extends ConsumerState<AddPOItemDialog> {
  String? selectedIngredientId;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsControllerProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addItem),
      content: ingredientsAsync.when(
        data: (ingredients) {
          if (ingredients.isEmpty)
            return Text(AppLocalizations.of(context)!.noIngredientsAvailable);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedIngredientId,
                hint: Text(AppLocalizations.of(context)!.selectIngredient),
                items: ingredients
                    .map((i) => DropdownMenuItem(
                          value: i.id,
                          child: Text('${i.name} (${i.unit})'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedIngredientId = val),
              ),
              TextField(
                controller: qtyController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.quantity),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.unitPrice),
                keyboardType: TextInputType.number,
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, s) => Text('${AppLocalizations.of(context)!.error}: $e'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedButton(
          onPressed: selectedIngredientId == null
              ? null
              : () {
                  final qty = double.tryParse(qtyController.text);
                  final price = double.tryParse(priceController.text);
                  if (qty != null && price != null) {
                    ref
                        .read(purchaseOrdersControllerProvider.notifier)
                        .addPOItem(
                          widget.poId,
                          selectedIngredientId!,
                          qty,
                          price,
                        );
                    Navigator.pop(context);
                  }
                },
          child: Text(AppLocalizations.of(context)!.add),
        )
      ],
    );
  }
}


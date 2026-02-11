import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import '../../../../domain/entities/ingredient.dart';
import 'inventory_controller.dart';
import 'inventory_logs_screen.dart';

class IngredientsScreen extends ConsumerWidget {
  const IngredientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsControllerProvider);

    return Scaffold(
      body: ingredientsAsync.when(
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noIngredientsFound));
          }
          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(ingredient.name),
                  subtitle: Text(AppLocalizations.of(context)!.stockLevel(
                      ingredient.currentStock,
                      ingredient.unit,
                      ingredient.minLevel)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditIngredientDialog(
                            context, ref, ingredient),
                      ),
                      IconButton(
                        icon: const Icon(Icons.history),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryLogsScreen(
                                ingredientId: ingredient.id),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.inventory),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              AdjustStockDialog(ingredient: ingredient),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditIngredientDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditIngredientDialog(
      BuildContext context, WidgetRef ref, Ingredient? ingredient) {
    showDialog(
      context: context,
      builder: (context) => AddEditIngredientDialog(ingredient: ingredient),
    );
  }
}

class AddEditIngredientDialog extends ConsumerStatefulWidget {
  final Ingredient? ingredient;
  const AddEditIngredientDialog({super.key, this.ingredient});

  @override
  ConsumerState<AddEditIngredientDialog> createState() =>
      _AddEditIngredientDialogState();
}

class _AddEditIngredientDialogState
    extends ConsumerState<AddEditIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient?.name);
    _unitController = TextEditingController(text: widget.ingredient?.unit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ingredient == null
          ? AppLocalizations.of(context)!.addIngredient
          : AppLocalizations.of(context)!.editIngredient),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              validator: (v) =>
                  v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitLabel),
              validator: (v) =>
                  v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (widget.ingredient == null) {
                ref
                    .read(ingredientsControllerProvider.notifier)
                    .addIngredient(_nameController.text, _unitController.text);
              } else {
                // Edit not implemented in controller yet, or assumes immutable name/unit for now
                // For now just show snackbar or implement update
              }
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

class AdjustStockDialog extends ConsumerStatefulWidget {
  final Ingredient ingredient;
  const AdjustStockDialog({super.key, required this.ingredient});

  @override
  ConsumerState<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends ConsumerState<AdjustStockDialog> {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  String? selectedWarehouseId;
  String selectedReason = 'ADJUSTMENT'; // Default
  final reasons = ['RESTOCK', 'WASTE', 'SPOILAGE', 'ADJUSTMENT', 'SALE'];

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .adjustStockTitle(widget.ingredient.name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.currentTotal(
                widget.ingredient.currentStock, widget.ingredient.unit)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.adjustmentAmount),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reason),
              items: reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => selectedReason = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.notesDescription,
                hintText: AppLocalizations.of(context)!.mandatoryForWaste,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            warehousesAsync.when(
              data: (warehouses) {
                if (warehouses.isEmpty)
                  return Text(AppLocalizations.of(context)!.noWarehousesFound);
                // Auto-select main if not selected
                if (selectedWarehouseId == null && warehouses.isNotEmpty) {
                  // Use microtask to avoid build phase setState
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && selectedWarehouseId == null) {
                      final main = warehouses.firstWhere((w) => w.isMain,
                          orElse: () => warehouses.first);
                      setState(() => selectedWarehouseId = main.id);
                    }
                  });
                }

                return DropdownButtonFormField<String>(
                  value: selectedWarehouseId,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.warehouse),
                  items: warehouses
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(
                                '${w.name}${w.isMain ? " (${AppLocalizations.of(context)!.mainWarehouse})" : ""}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedWarehouseId = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text(AppLocalizations.of(context)!
                  .errorLoadingWarehouses(e.toString())),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedButton(
          onPressed: () {
            final change = double.tryParse(amountController.text);
            final notes = notesController.text.trim();

            if (change == null || change == 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.invalidAmount)));
              return;
            }

            if ((selectedReason == 'WASTE' || selectedReason == 'SPOILAGE') &&
                notes.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.descriptionRequired)));
              return;
            }

            ref.read(ingredientsControllerProvider.notifier).updateStock(
                  widget.ingredient.id,
                  change,
                  warehouseId: selectedWarehouseId,
                  reason: selectedReason,
                  notes: notes,
                );
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.adjust),
        ),
      ],
    );
  }
}


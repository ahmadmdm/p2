import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'recipes_controller.dart';
import 'inventory_controller.dart';

class RecipesScreen extends ConsumerWidget {
  final String productId;
  final String productName;

  const RecipesScreen(
      {super.key, required this.productId, required this.productName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(productRecipesControllerProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text('Recipe: $productName')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIngredientDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No ingredients in this recipe'));
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final item = recipes[index];
              return ListTile(
                title: Text(item.ingredient.name),
                subtitle: Text('${item.quantity} ${item.ingredient.unit}'),
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

  void _showAddIngredientDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddRecipeItemDialog(
        onAdd: (ingredientId, quantity) {
          ref
              .read(productRecipesControllerProvider(productId).notifier)
              .addRecipeItem(ingredientId, quantity);
        },
      ),
    );
  }
}

class ModifierRecipesScreen extends ConsumerWidget {
  final String modifierId;
  final String modifierName;

  const ModifierRecipesScreen(
      {super.key, required this.modifierId, required this.modifierName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync =
        ref.watch(modifierRecipesControllerProvider(modifierId));

    return Scaffold(
      appBar: AppBar(title: Text('Recipe: $modifierName')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIngredientDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No ingredients in this recipe'));
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final item = recipes[index];
              return ListTile(
                title: Text(item.ingredient.name),
                subtitle: Text('${item.quantity} ${item.ingredient.unit}'),
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

  void _showAddIngredientDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddRecipeItemDialog(
        onAdd: (ingredientId, quantity) {
          ref
              .read(modifierRecipesControllerProvider(modifierId).notifier)
              .addRecipeItem(ingredientId, quantity);
        },
      ),
    );
  }
}

class AddRecipeItemDialog extends ConsumerStatefulWidget {
  final Function(String ingredientId, double quantity) onAdd;
  const AddRecipeItemDialog({super.key, required this.onAdd});

  @override
  ConsumerState<AddRecipeItemDialog> createState() =>
      _AddRecipeItemDialogState();
}

class _AddRecipeItemDialogState extends ConsumerState<AddRecipeItemDialog> {
  String? selectedIngredientId;
  final qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsControllerProvider);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addIngredient),
      content: ingredientsAsync.when(
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return Text(
                AppLocalizations.of(context)!.noIngredientsAvailableSimple);
          }
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
                    labelText: AppLocalizations.of(context)!.quantityPerItem),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                  if (qty != null && qty > 0) {
                    widget.onAdd(selectedIngredientId!, qty);
                    Navigator.pop(context);
                  }
                },
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/modifier.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;
  final Function(int quantity, String notes, List<ModifierItem> modifiers)
      onAddToCart;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  final Map<String, List<String>> _selectedModifiers =
      {}; // GroupId -> List<ModifierId>

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleModifier(ModifierGroup group, ModifierItem item) {
    setState(() {
      final current = _selectedModifiers[group.id] ?? [];

      if (group.selectionType == 'SINGLE') {
        _selectedModifiers[group.id] = [item.id];
      } else {
        if (current.contains(item.id)) {
          current.remove(item.id);
        } else {
          if (current.length < group.maxSelection) {
            current.add(item.id);
          }
        }
        _selectedModifiers[group.id] = current;
      }
    });
  }

  double _calculateTotal() {
    double total = widget.product.price;
    widget.product.modifierGroups.forEach((group) {
      final selectedIds = _selectedModifiers[group.id] ?? [];
      for (var itemId in selectedIds) {
        final item = group.items.firstWhere((i) => i.id == itemId,
            orElse: () =>
                const ModifierItem(id: '', nameEn: '', nameAr: '', price: 0));
        total += item.price;
      }
    });
    return total * _quantity;
  }

  void _handleAddToCart() {
    // Validate
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    for (var group in widget.product.modifierGroups) {
      final selectedCount = (_selectedModifiers[group.id] ?? []).length;
      if (selectedCount < group.minSelection) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.selectAtLeast(
                  group.minSelection, isArabic ? group.nameAr : group.nameEn))),
        );
        return;
      }
    }

    final List<ModifierItem> selectedItems = [];
    widget.product.modifierGroups.forEach((group) {
      final selectedIds = _selectedModifiers[group.id] ?? [];
      for (var itemId in selectedIds) {
        try {
          final item = group.items.firstWhere((i) => i.id == itemId);
          selectedItems.add(item);
        } catch (_) {}
      }
    });

    widget.onAddToCart(_quantity, _notesController.text, selectedItems);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isArabic ? widget.product.nameAr : widget.product.nameEn,
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),

            // Content
            Expanded(
              child: ListView(
                children: [
                  Text(
                      AppLocalizations.of(context)!
                          .priceLabel(widget.product.price),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  const SizedBox(height: 16),
                  ...widget.product.modifierGroups.map((group) {
                    final groupName = isArabic ? group.nameAr : group.nameEn;
                    final selectionText = group.selectionType == 'SINGLE'
                        ? AppLocalizations.of(context)!.selectOne
                        : AppLocalizations.of(context)!
                            .selectUpTo(group.maxSelection);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$groupName ($selectionText)',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: group.items.map((item) {
                            final isSelected =
                                (_selectedModifiers[group.id] ?? [])
                                    .contains(item.id);
                            final itemName =
                                isArabic ? item.nameAr : item.nameEn;
                            final pricePart = item.price > 0
                                ? ' (+${AppLocalizations.of(context)!.priceLabel(item.price)})'
                                : '';
                            return FilterChip(
                              label: Text('$itemName$pricePart'),
                              selected: isSelected,
                              onSelected: (_) => _toggleModifier(group, item),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                  Text(AppLocalizations.of(context)!.notesLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.specialInstructions,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(
                      () => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _quantity = _quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _handleAddToCart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(AppLocalizations.of(context)!
                      .addToCartTotal(_calculateTotal())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

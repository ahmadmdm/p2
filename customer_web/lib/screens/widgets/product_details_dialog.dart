import 'package:flutter/material.dart';
import 'package:customer_web/l10n/app_localizations.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(CartItem) onAddToCart;

  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  // Map<GroupId, List<ModifierItem>>
  final Map<String, List<Map<String, dynamic>>> _selectedModifiers = {};
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize required modifiers if needed, or just leave empty
  }

  double get _totalPrice {
    double basePrice =
        double.tryParse(widget.product['price'].toString()) ?? 0.0;
    double modifiersPrice = 0.0;

    _selectedModifiers.forEach((key, items) {
      for (var item in items) {
        modifiersPrice += double.tryParse(item['price'].toString()) ?? 0.0;
      }
    });

    return (basePrice + modifiersPrice) * _quantity;
  }

  bool _isValid() {
    final modifierGroups =
        (widget.product['modifierGroups'] as List<dynamic>?) ?? [];
    for (var group in modifierGroups) {
      final min = group['minSelection'] ?? 0;
      // final max = group['maxSelection'] ?? 1;
      final selectedCount = _selectedModifiers[group['id']]?.length ?? 0;

      if (selectedCount < min) {
        return false;
      }
    }
    return true;
  }

  void _toggleModifier(
    Map<String, dynamic> group,
    Map<String, dynamic> item,
    bool isSelected,
  ) {
    setState(() {
      final groupId = group['id'];
      final currentList = _selectedModifiers[groupId] ?? [];
      final max = group['maxSelection'] ?? 1;
      // final min = group['minSelection'] ?? 0;

      if (isSelected) {
        // Trying to add
        if (max == 1) {
          // Single selection: replace existing
          _selectedModifiers[groupId] = [item];
        } else {
          // Multi selection: check max
          if (currentList.length < max) {
            _selectedModifiers[groupId] = [...currentList, item];
          } else {
            // Max reached, show message?
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Maximum $max selection allowed for ${group['name']['en'] ?? group['name']}',
                ),
              ),
            );
          }
        }
      } else {
        // Removing
        _selectedModifiers[groupId] = currentList
            .where((i) => i['id'] != item['id'])
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final modifierGroups =
        (widget.product['modifierGroups'] as List<dynamic>?) ?? [];
    final name = widget.product['name'] is Map
        ? widget.product['name'][locale] ??
              widget.product['name']['en'] ??
              widget.product['name']
        : widget.product['name'];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Product Info (Image placeholder if needed)
                  Text(
                    '\$${widget.product['price']}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Modifiers
                  ...modifierGroups.map((group) {
                    final groupName = group['name'] is Map
                        ? group['name'][locale] ??
                              group['name']['en'] ??
                              group['name']
                        : group['name'];
                    final items = (group['items'] as List<dynamic>?) ?? [];
                    final max = group['maxSelection'] ?? 1;
                    final min = group['minSelection'] ?? 0;
                    final isSingle = max == 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '$groupName ${min > 0 ? '(Required)' : ''} ${max > 1 ? '(Max $max)' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...items.map((item) {
                          final itemName = item['name'] is Map
                              ? item['name'][locale] ??
                                    item['name']['en'] ??
                                    item['name']
                              : item['name'];
                          final itemPrice =
                              double.tryParse(item['price'].toString()) ?? 0.0;
                          final isSelected =
                              _selectedModifiers[group['id']]?.any(
                                (i) => i['id'] == item['id'],
                              ) ??
                              false;

                          return isSingle
                              ? ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(itemName),
                                      if (itemPrice > 0)
                                        Text(
                                          '+\$${itemPrice.toStringAsFixed(2)}',
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                  ),
                                  onTap: () {
                                    _toggleModifier(group, item, true);
                                  },
                                )
                              : CheckboxListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(itemName),
                                      if (itemPrice > 0)
                                        Text(
                                          '+\$${itemPrice.toStringAsFixed(2)}',
                                        ),
                                    ],
                                  ),
                                  value: isSelected,
                                  onChanged: (val) {
                                    _toggleModifier(group, item, val ?? false);
                                  },
                                );
                        }),
                        const Divider(),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions / Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_quantity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid()
                          ? () {
                              final allModifiers = _selectedModifiers.values
                                  .expand((i) => i)
                                  .toList();

                              double basePrice =
                                  double.tryParse(
                                    widget.product['price'].toString(),
                                  ) ??
                                  0.0;
                              double modifiersPrice = 0.0;
                              for (var m in allModifiers) {
                                modifiersPrice +=
                                    double.tryParse(m['price'].toString()) ??
                                    0.0;
                              }
                              final unitPrice = basePrice + modifiersPrice;

                              final cartItem = CartItem(
                                productId: widget.product['id'],
                                name: name,
                                price: unitPrice,
                                quantity: _quantity,
                                modifiers: allModifiers,
                                notes: _notesController.text.trim().isEmpty
                                    ? null
                                    : _notesController.text.trim(),
                              );

                              widget.onAddToCart(cartItem);
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        '${l10n.addToCart} - \$${_totalPrice.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

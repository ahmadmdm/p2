import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;
    final token = ref.watch(tableTokenProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOrder)),
      body: cartItems.isEmpty
          ? Center(child: Text(l10n.cartEmpty))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final modifiersText = item.modifiers.isNotEmpty
                          ? item.modifiers
                                .map((m) {
                                  final name = m['name'] is Map
                                      ? m['name'][locale] ??
                                            m['name']['en'] ??
                                            m['name']
                                      : m['name'];
                                  return name;
                                })
                                .join(', ')
                          : '';

                      return ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (modifiersText.isNotEmpty)
                              Text('${l10n.modifiers}: $modifiersText'),
                            if (item.notes != null)
                              Text(
                                '${l10n.notes}: ${item.notes}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(item, -1);
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(item, 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.total}:',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error: No table token found'),
                                ),
                              );
                              return;
                            }

                            try {
                              final activeOrderId = ref.read(activeOrderIdProvider);
                              
                              // Construct order payload
                              final itemsPayload = cartItems
                                    .map(
                                      (item) => {
                                        'productId': item.productId,
                                        'quantity': item.quantity,
                                        'modifiers': item.modifiers,
                                        'notes': item.notes,
                                      },
                                    )
                                    .toList();

                              dynamic result;
                              if (activeOrderId != null) {
                                // Add to existing order
                                result = await ref
                                    .read(apiServiceProvider.notifier)
                                    .addItemsToOrder(token, activeOrderId, itemsPayload);
                              } else {
                                // Create new order
                                final orderData = {
                                  'items': itemsPayload,
                                  'paymentMethod': 'later', // Default for self-order
                                };
                                result = await ref
                                    .read(apiServiceProvider.notifier)
                                    .createOrder(token, orderData);
                                    
                                // Set active order ID
                                if (result != null && result['id'] != null) {
                                  ref.read(activeOrderIdProvider.notifier).setId(result['id']);
                                }
                              }

                              ref.read(cartProvider.notifier).clear();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.orderPlaced),
                                  ),
                                );
                                context.go('/status/${result['id']}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${l10n.error}: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(l10n.placeOrder),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

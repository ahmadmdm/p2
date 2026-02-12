import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_web/l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  String _modifierName(dynamic modifier, String locale) {
    if (modifier is Map) {
      final name = modifier['name'];
      if (name is Map) {
        return (name[locale] ?? name['en'] ?? '').toString();
      }
      return name?.toString() ?? '';
    }
    return modifier.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;
    final token = ref.watch(tableTokenProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: AppTheme.gradientBackground(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.myOrder,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: cartItems.isEmpty
            ? Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.cartEmpty,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final modifiersText = item.modifiers
                            .map((m) => _modifierName(m, locale))
                            .where((s) => s.isNotEmpty)
                            .join(', ');

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (modifiersText.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${l10n.modifiers}: $modifiersText',
                                    style: TextStyle(
                                      color: Colors.brown.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (item.notes != null &&
                                    item.notes!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${l10n.notes}: ${item.notes}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(item, -1);
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(item, 1);
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.total,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                                final itemsPayload = cartItems
                                    .map(
                                      (item) => {
                                        'productId': item.productId,
                                        'quantity': item.quantity,
                                        'modifiers': item.modifiers.map((m) {
                                          if (m is Map && m['id'] != null) {
                                            return {'id': m['id']};
                                          }
                                          return {'id': m.toString()};
                                        }).toList(),
                                        'notes': item.notes,
                                      },
                                    )
                                    .toList();

                                dynamic result;
                                if (activeOrderId != null) {
                                  result = await ref
                                      .read(apiServiceProvider.notifier)
                                      .addItemsToOrder(
                                        token,
                                        activeOrderId,
                                        itemsPayload,
                                      );
                                } else {
                                  result = await ref
                                      .read(apiServiceProvider.notifier)
                                      .createOrder(token, {'items': itemsPayload});

                                  if (result != null && result['id'] != null) {
                                    ref
                                        .read(activeOrderIdProvider.notifier)
                                        .setId(result['id']);
                                  }
                                }

                                ref.read(cartProvider.notifier).clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.orderPlaced)),
                                  );
                                  context.go('/status/${result['id']}');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${l10n.error}: $e')),
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
      ),
    );
  }
}

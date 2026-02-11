import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_web/l10n/app_localizations.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import 'widgets/product_details_dialog.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);
    final cartItemCount = ref.watch(
      cartProvider.select(
        (items) => items.fold(0, (sum, item) => sum + item.quantity),
      ),
    );

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeStateProvider.notifier).toggleLocale();
            },
          ),
        ],
      ),
      body: menuAsync.when(
        data: (data) {
          final categories = data['categories'] as List<dynamic>;
          final locale = Localizations.localeOf(context).languageCode;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  category['name'][locale] ??
                      category['name']['en'] ??
                      category['name'],
                ),
                children: (category['products'] as List<dynamic>).map<Widget>((
                  product,
                ) {
                  return ListTile(
                    title: Text(
                      product['name'][locale] ??
                          product['name']['en'] ??
                          product['name'],
                    ),
                    subtitle: Text('\$${product['price']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProductDetailsDialog(
                            product: product,
                            onAddToCart: (cartItem) {
                              ref.read(cartProvider.notifier).addItem(cartItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${cartItem.name} ${l10n.addedToCart}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: cartItemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/cart');
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text('${l10n.viewCart} ($cartItemCount)'),
            )
          : null,
    );
  }
}

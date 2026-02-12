import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_web/l10n/app_localizations.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/product_details_dialog.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? _selectedCategoryId;

  String _localizedName(dynamic value, String locale) {
    if (value is Map) {
      return (value[locale] ?? value['en'] ?? value.values.first).toString();
    }
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuProvider);
    final cartItemCount = ref.watch(
      cartProvider.select((items) => items.fold(0, (sum, item) => sum + item.quantity)),
    );
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: AppTheme.gradientBackground(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.menuTitle,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language_rounded),
              onPressed: () {
                ref.read(localeStateProvider.notifier).toggleLocale();
              },
            ),
          ],
        ),
        body: menuAsync.when(
          data: (data) {
            final categories = (data['categories'] as List<dynamic>? ?? []);
            if (categories.isEmpty) {
              return const Center(child: Text('No menu available'));
            }

            _selectedCategoryId ??= categories.first['id']?.toString();
            final selectedCategory = categories.firstWhere(
              (category) => category['id']?.toString() == _selectedCategoryId,
              orElse: () => categories.first,
            );
            final products = selectedCategory['products'] as List<dynamic>? ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.table_restaurant_rounded,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Now Serving',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  data['tableNumber']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final id = category['id']?.toString() ?? '';
                      final selected = id == _selectedCategoryId;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(_localizedName(category['name'], locale)),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryId = id;
                          });
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.16),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 980
                          ? 3
                          : width > 620
                              ? 2
                              : 1;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.1,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index] as Map<String, dynamic>;
                          final name = _localizedName(product['name'], locale);
                          final price = double.tryParse(
                                product['price'].toString(),
                              ) ??
                              0;

                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ProductDetailsDialog(
                                    product: product,
                                    onAddToCart: (cartItem) {
                                      ref.read(cartProvider.notifier).addItem(
                                            cartItem,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: (product['imageUrl'] != null &&
                                                product['imageUrl']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? Image.network(
                                                product['imageUrl'].toString(),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
                                                    Container(
                                                  color: AppTheme.surfaceTint,
                                                  child: const Icon(
                                                    Icons.local_cafe_rounded,
                                                    color: AppTheme.secondary,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: AppTheme.surfaceTint,
                                                child: const Icon(
                                                  Icons.local_cafe_rounded,
                                                  color: AppTheme.secondary,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '\$${price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.add_circle_rounded,
                                      color: AppTheme.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        floatingActionButton: cartItemCount > 0
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: Text('${l10n.viewCart} ($cartItemCount)'),
              )
            : null,
      ),
    );
  }
}

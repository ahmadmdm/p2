import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import '../home/home_providers.dart';
import '../../../domain/entities/modifier.dart';
import '../../../theme/pos_theme.dart';
import 'recipes_screen.dart';

class ModifiersListScreen extends ConsumerWidget {
  const ModifiersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Container(
      decoration: POSTheme.backgroundGradient(),
      child: productsAsync.when(
        data: (products) {
        // Extract all modifiers
        final allModifiers = <String, ModifierItem>{};
        for (var product in products) {
          for (final group in product.modifierGroups) {
            final rawItems = (group as dynamic).items;
            if (rawItems is! Iterable) {
              continue;
            }
            for (final rawItem in rawItems) {
              if (rawItem is ModifierItem) {
                allModifiers[rawItem.id] = rawItem;
                continue;
              }

              if (rawItem is Map) {
                final itemJson = Map<String, dynamic>.from(rawItem);
                final nameJson = itemJson['name'];
                final itemNameEn = itemJson['nameEn']?.toString() ??
                    (nameJson is Map ? nameJson['en']?.toString() : null) ??
                    '';
                final itemNameAr = itemJson['nameAr']?.toString() ??
                    (nameJson is Map ? nameJson['ar']?.toString() : null) ??
                    '';
                final itemPriceRaw = itemJson['price'];
                final itemPrice = itemPriceRaw is num
                    ? itemPriceRaw.toDouble()
                    : double.tryParse(itemPriceRaw?.toString() ?? '') ?? 0;
                final item = ModifierItem(
                  id: itemJson['id']?.toString() ?? '',
                  nameEn: itemNameEn,
                  nameAr: itemNameAr,
                  price: itemPrice,
                );
                allModifiers[item.id] = item;
              }
            }
          }
        }

        final modifiersList = allModifiers.values.toList();
        modifiersList.sort((a, b) => a.nameEn.compareTo(b.nameEn));

        if (modifiersList.isEmpty) {
          return const Center(child: Text('No modifiers found in products.'));
        }

        return ListView.builder(
          itemCount: modifiersList.length,
          itemBuilder: (context, index) {
            final modifier = modifiersList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(modifier.nameEn),
                subtitle: Text(modifier.nameAr),
                trailing:
                    const Icon(Icons.chevron_right, color: POSTheme.secondary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ModifierRecipesScreen(
                        modifierId: modifier.id,
                        modifierName: modifier.nameEn,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../home/home_providers.dart';
import '../../../domain/entities/modifier.dart';
import 'recipes_screen.dart';

class ModifiersListScreen extends ConsumerWidget {
  const ModifiersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        // Extract all modifiers
        final allModifiers = <String, ModifierItem>{};
        for (var product in products) {
          for (var group in product.modifierGroups) {
            for (var item in group.items) {
              allModifiers[item.id] = item;
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
            return ListTile(
              title: Text(modifier.nameEn),
              subtitle: Text(modifier.nameAr),
              trailing: const Icon(Icons.chevron_right),
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
    );
  }
}

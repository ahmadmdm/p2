import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'inventory_controller.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplierDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: suppliersAsync.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noSuppliersFound));
          }
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier.name),
                subtitle: Text(supplier.email ??
                    supplier.phone ??
                    AppLocalizations.of(context)!.noContactInfo),
                trailing: supplier.isActive
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
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

  void _showAddSupplierDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addSupplier),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name)),
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email)),
            TextField(
                controller: phoneController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumber)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(suppliersControllerProvider.notifier).addSupplier(
                      nameController.text,
                      emailController.text.isEmpty
                          ? null
                          : emailController.text,
                      phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}


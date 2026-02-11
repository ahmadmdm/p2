import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'customers_controller.dart';
import '../../../../domain/entities/customer.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customersAndLoyalty),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(customersControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noCustomersFound));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _CustomerCard(customer: customer);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _AddCustomerDialog(),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTierColor(customer.tier),
          child: Text(customer.tier[0].toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(customer.name),
        subtitle: Text(AppLocalizations.of(context)!
            .pointsTier(customer.loyaltyPoints, customer.tier)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to details or history
        },
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'PLATINUM':
        return Colors.black87;
      case 'GOLD':
        return Colors.amber;
      case 'SILVER':
        return Colors.grey;
      case 'BRONZE':
      default:
        return Colors.brown;
    }
  }
}

class _AddCustomerDialog extends ConsumerStatefulWidget {
  const _AddCustomerDialog();

  @override
  ConsumerState<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addCustomer),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              validator: (v) =>
                  v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber),
              validator: (v) =>
                  v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              ref.read(customersControllerProvider.notifier).addCustomer(
                    _nameController.text,
                    _phoneController.text,
                  );
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}


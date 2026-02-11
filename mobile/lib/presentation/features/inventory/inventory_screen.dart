import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import '../../../data/repositories/inventory_repository_impl.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../auth/auth_controller.dart';
import 'suppliers_screen.dart';
import 'purchase_orders_screen.dart';
import 'ingredients_screen.dart';
import 'modifiers_list_screen.dart';
import 'inventory_logs_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventoryAndPurchasing),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: AppLocalizations.of(context)!.syncInventory,
            onPressed: () async {
              final token = ref.read(authControllerProvider).value?.accessToken;
              if (token != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)!.syncing)),
                );
                try {
                  await Future.wait([
                    ref.read(inventoryRepositoryProvider).syncInventory(token),
                    ref.read(ordersRepositoryProvider).syncPendingOrders(token),
                  ]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(AppLocalizations.of(context)!.syncSuccess)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${AppLocalizations.of(context)!.syncFailed}: $e')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.notAuthenticated)),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.suppliers),
            Tab(text: AppLocalizations.of(context)!.ingredients),
            Tab(text: AppLocalizations.of(context)!.purchaseOrders),
            Tab(text: AppLocalizations.of(context)!.modifierRecipes),
            Tab(text: AppLocalizations.of(context)!.logs),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SuppliersScreen(),
          IngredientsScreen(),
          PurchaseOrdersScreen(),
          ModifiersListScreen(),
          InventoryLogsScreen(),
        ],
      ),
    );
  }
}


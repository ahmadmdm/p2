import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';
import '../tables/floor_plan_screen.dart';
import '../inventory/inventory_screen.dart';
import '../kitchen/kitchen_screen.dart';
import '../shifts/shift_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/settings_controller.dart';
import 'home_providers.dart';
import 'cart_controller.dart';
import 'cart_state.dart';
import 'widgets/product_details_dialog.dart';
import '../inventory/recipes_screen.dart';
import '../reports/reports_screen.dart';
import '../orders/delivery_orders_screen.dart';
import '../../../domain/entities/customer.dart' as domain;
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/entities/order_item.dart' as domain;
import '../../../domain/entities/order_status.dart';
import '../../../domain/entities/order_type.dart' as domain;
import '../../../data/repositories/customers_repository_impl.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../../../data/repositories/tables_repository_impl.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/printing_service.dart';

import '../../../domain/entities/loyalty_transaction.dart';
import '../../../domain/entities/restaurant_table.dart';

import '../orders/my_deliveries_screen.dart';
import '../orders/orders_history_screen.dart';
import '../orders/refunds_approval_screen.dart';
import '../customers/customers_screen.dart';
import '../../../theme/pos_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Start Sync Service
    ref.read(syncServiceProvider);
    Future.microtask(() => ref.read(syncServiceProvider).syncAll());
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(filteredProductsStreamProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final cartState = ref.watch(cartControllerProvider);
    final user = ref.watch(authControllerProvider).value;
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        actions: [
          if (user?.role == 'driver')
            IconButton(
              icon: const Icon(Icons.motorcycle),
              tooltip: AppLocalizations.of(context)!.myDeliveries,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.table_restaurant),
            tooltip: AppLocalizations.of(context)!.floorPlan,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FloorPlanScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            tooltip: AppLocalizations.of(context)!.inventory,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.kitchen),
            tooltip: AppLocalizations.of(context)!.kitchenDisplay,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KitchenScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              // Trigger sync manually via SyncService
              final user = ref.read(authControllerProvider).value;
              if (user?.accessToken != null) {
                try {
                  await ref.read(syncServiceProvider).syncAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!.success)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .cannotSyncNotLoggedIn)),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: AppLocalizations.of(context)!.reports,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: AppLocalizations.of(context)!.orderHistory,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()),
              );
            },
          ),
          if (user?.role == 'manager')
            IconButton(
              icon: const Icon(Icons.approval),
              tooltip: AppLocalizations.of(context)!.approveRefunds,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const RefundsApprovalScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: AppLocalizations.of(context)!.customers,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delivery_dining),
            tooltip: AppLocalizations.of(context)!.delivery,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeliveryOrdersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.work_history),
            tooltip: AppLocalizations.of(context)!.workHistory,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShiftScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.logout,
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Categories & Products
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Categories (Horizontal List)
                SizedBox(
                  height: 60,
                  child: categoriesAsync.when(
                    data: (categories) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isArabic =
                            Localizations.localeOf(context).languageCode ==
                                'ar';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(
                                isArabic ? category.nameAr : category.nameEn),
                            selected: selectedCategoryId == category.id,
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(selectedCategoryIdProvider.notifier)
                                    .select(category.id);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
                const Divider(),
                // Products Grid
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Menu is empty. Please sync data.'),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.sync),
                                label:
                                    Text(AppLocalizations.of(context)!.syncNow),
                                onPressed: () async {
                                  await ref.read(syncServiceProvider).syncAll();
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Adjust for iPad
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isArabic =
                              Localizations.localeOf(context).languageCode ==
                                  'ar';
                          return Card(
                            child: InkWell(
                              onTap: () {
                                if (product.modifierGroups.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProductDetailsDialog(
                                      product: product,
                                      onAddToCart:
                                          (quantity, notes, modifiers) {
                                        ref
                                            .read(
                                                cartControllerProvider.notifier)
                                            .addToCart(product,
                                                quantity: quantity,
                                                notes: notes,
                                                modifiers: modifiers);
                                      },
                                    ),
                                  );
                                } else {
                                  ref
                                      .read(cartControllerProvider.notifier)
                                      .addToCart(product);
                                }
                              },
                              onLongPress: () {
                                // Open Recipe/Inventory Management for this product
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RecipesScreen(
                                      productId: product.id,
                                      productName: product.nameEn,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: POSTheme.surfaceTint.withValues(
                                        alpha: 0.55,
                                      ),
                                      child: const Icon(
                                        Icons.fastfood,
                                        size: 40,
                                        color: POSTheme.secondary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isArabic
                                              ? product.nameAr
                                              : product.nameEn,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _formatCurrency(
                                              product.price, settings),
                                          style: const TextStyle(
                                            color: POSTheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right Side: Cart
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Customer Section
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: POSTheme.surfaceTint.withValues(alpha: 0.7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppLocalizations.of(context)!.customer}:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            InkWell(
                              onTap: () {
                                if (cartState.selectedCustomer != null) {
                                  _showLoyaltyHistory(context, ref,
                                      cartState.selectedCustomer!.id);
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      cartState.selectedCustomer?.name ??
                                          AppLocalizations.of(context)!.guest,
                                      style: const TextStyle(fontSize: 16)),
                                  if (cartState.selectedCustomer != null)
                                    Text(
                                        '${cartState.selectedCustomer!.loyaltyPoints} pts (${cartState.selectedCustomer!.tier})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: POSTheme.secondary,
                                        )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cartState.selectedCustomer != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .removeCustomer(),
                        )
                      else
                        TextButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: Text(AppLocalizations.of(context)!.select),
                          onPressed: () =>
                              _showCustomerSelectionDialog(context, ref),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: POSTheme.surfaceTint.withValues(alpha: 0.55),
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.currentOrder,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      final isArabic =
                          Localizations.localeOf(context).languageCode == 'ar';
                      return ListTile(
                        title: Text(isArabic
                            ? item.product.nameAr
                            : item.product.nameEn),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${item.quantity} x ${_formatCurrency(item.product.price, settings)}'),
                            if (item.modifiers.isNotEmpty)
                              Text(
                                item.modifiers
                                    .map((m) => '+${m.nameEn}')
                                    .join(', '),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text(
                                AppLocalizations.of(context)!.note(item.notes!),
                                style: const TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: Text(_formatCurrency(item.total, settings)),
                        onTap: () {
                          _showEditItemDialog(context, ref, item);
                        },
                        leading: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            ref
                                .read(cartControllerProvider.notifier)
                                .updateQuantity(
                                    item.product, item.quantity - 1);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppLocalizations.of(context)!.subtotal}:',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  _formatCurrency(cartState.subtotal, settings),
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      '${AppLocalizations.of(context)!.discount}:',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.red)),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 16, color: Colors.grey),
                                    onPressed: () => _showGlobalValueDialog(
                                        context,
                                        ref,
                                        AppLocalizations.of(context)!.discount,
                                        cartState.globalDiscountAmount,
                                        (val) => ref
                                            .read(
                                                cartControllerProvider.notifier)
                                            .setGlobalDiscount(val)),
                                  ),
                                ],
                              ),
                              Text(
                                  '-${_formatCurrency(cartState.globalDiscountAmount, settings)}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.red)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('${AppLocalizations.of(context)!.tax}:',
                                      style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 16, color: Colors.grey),
                                    onPressed: () => _showGlobalValueDialog(
                                        context,
                                        ref,
                                        AppLocalizations.of(context)!.tax,
                                        cartState.globalTaxAmount,
                                        (val) => ref
                                            .read(
                                                cartControllerProvider.notifier)
                                            .setGlobalTax(val)),
                                  ),
                                ],
                              ),
                              Text(
                                  _formatCurrency(
                                      cartState.globalTaxAmount, settings),
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppLocalizations.of(context)!.total}:',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                _formatCurrency(
                                    cartState.totalAmount, settings),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: POSTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: cartState.items.isEmpty
                              ? null
                              : () {
                                  _processCheckout(context, ref);
                                },
                          child: Text(AppLocalizations.of(context)!.charge,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(BuildContext context, WidgetRef ref) async {
    final cartState = ref.read(cartControllerProvider);
    final cartItems = cartState.items;
    if (cartItems.isEmpty) return;

    final checkoutSelection = await _showCheckoutOptionsDialog(context, ref);
    if (checkoutSelection == null) return;

    // 2. Ask for Payment Method
    if (!context.mounted) return;

    final customer = cartState.selectedCustomer;
    final pointsNeeded = (cartState.totalAmount * 10).ceil();
    final canPayWithPoints =
        customer != null && customer.loyaltyPoints >= pointsNeeded;

    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.selectPaymentMethod),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'CASH'),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(AppLocalizations.of(context)!.cash,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'CARD'),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(AppLocalizations.of(context)!.card,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          if (canPayWithPoints)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'LOYALTY'),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.loyaltyPoints,
                        style: const TextStyle(fontSize: 18)),
                    Text(
                      AppLocalizations.of(context)!
                          .usePoints(pointsNeeded, customer.loyaltyPoints),
                      style: const TextStyle(
                        fontSize: 14,
                        color: POSTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'LATER'),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(AppLocalizations.of(context)!.payLater,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );

    if (paymentMethod == null) return;

    try {
      // Construct Order
      final cartState = ref.read(cartControllerProvider);
      const uuid = Uuid();
      final order = domain.Order(
        id: uuid.v4(),
        tableNumber: checkoutSelection.tableNumber,
        type: checkoutSelection.type,
        status: OrderStatus.PENDING,
        paymentMethod: paymentMethod,
        customerId: cartState.selectedCustomer?.id,
        paymentStatus: (paymentMethod == 'CASH' ||
                paymentMethod == 'CARD' ||
                paymentMethod == 'LOYALTY')
            ? 'PAID'
            : 'PENDING',
        totalAmount: cartState.totalAmount,
        taxAmount: cartState.globalTaxAmount,
        discountAmount: cartState.globalDiscountAmount,
        deliveryAddress: checkoutSelection.deliveryAddress,
        deliveryFee: checkoutSelection.deliveryFee,
        deliveryProvider: checkoutSelection.deliveryProvider,
        createdAt: DateTime.now(),
        items: cartItems
            .map((item) => domain.OrderItem(
                  id: uuid.v4(),
                  quantity: item.quantity,
                  price: item.product.price,
                  notes: item.notes,
                  product: item.product,
                  taxAmount: item.taxAmount,
                  discountAmount: item.discountAmount,
                ))
            .toList(),
      );

      // Get Auth Token
      final user = ref.read(authControllerProvider).value;
      final token = user?.accessToken;

      // Create Order
      final createdOrder = await ref
          .read(ordersRepositoryProvider)
          .createOrder(order, token: token);
      if (createdOrder.type == domain.OrderType.DELIVERY &&
          token != null &&
          checkoutSelection.deliveryProvider != null &&
          checkoutSelection.deliveryProvider != 'internal') {
        await ref.read(ordersRepositoryProvider).requestDelivery(
              token,
              createdOrder.id,
              checkoutSelection.deliveryProvider!,
            );
      }

      final settings = await ref.read(settingsControllerProvider.future);
      final autoPrintReceipt = settings['autoPrintReceipt'] as bool? ?? true;
      final autoPrintKitchen = settings['autoPrintKitchen'] as bool? ?? true;

      if (autoPrintReceipt) {
        try {
          await ref
              .read(printingServiceProvider)
              .printOrderReceipt(createdOrder);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Receipt print failed: $e'),
              ),
            );
          }
        }
      }

      if (autoPrintKitchen) {
        try {
          await ref
              .read(printingServiceProvider)
              .printKitchenTicket(createdOrder);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kitchen ticket print failed: $e'),
              ),
            );
          }
        }
      }

      // Clear Cart
      ref.read(cartControllerProvider.notifier).clearCart();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.success)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  String _formatCurrency(double amount, Map<String, dynamic> settings) {
    final symbol = (settings['currencySymbol'] ?? '\$').toString();
    final decimals = (settings['currencyDecimals'] as int?) ?? 2;
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  String _takeawayLabel(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? 'سفري' : 'Takeaway';
  }

  String _internalDriverLabel(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? 'مندوب داخلي' : 'Internal Driver';
  }

  String _selectOrderTypeLabel(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? 'اختر نوع الطلب' : 'Select Order Type';
  }

  String _selectTableLabel(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? 'اختر الطاولة' : 'Select Table';
  }

  String _tableIdOf(dynamic table) {
    if (table is RestaurantTable) return table.id;
    if (table is Map<String, dynamic>) return table['id']?.toString() ?? '';
    if (table is Map) return table['id']?.toString() ?? '';
    return '';
  }

  String _tableNumberOf(dynamic table) {
    if (table is RestaurantTable) return table.tableNumber;
    if (table is Map<String, dynamic>) {
      return table['tableNumber']?.toString() ?? '';
    }
    if (table is Map) return table['tableNumber']?.toString() ?? '';
    return '';
  }

  Future<_CheckoutSelection?> _showCheckoutOptionsDialog(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final settings =
        ref.read(settingsControllerProvider).valueOrNull ?? const {};
    final feeController = TextEditingController(text: '0');
    final addressController = TextEditingController();

    final tables = await ref.read(tablesRepositoryProvider).getTables();
    final sortedTables = [...tables]
      ..sort((a, b) => _tableNumberOf(a).compareTo(_tableNumberOf(b)));
    if (!context.mounted) return null;

    domain.OrderType selectedType = domain.OrderType.DINE_IN;
    dynamic selectedTable = sortedTables.isNotEmpty ? sortedTables.first : null;
    String selectedProvider =
        (settings['defaultDeliveryProvider'] ?? 'internal').toString();

    final selection = await showDialog<_CheckoutSelection>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.charge),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectOrderTypeLabel(context),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.table),
                          selected: selectedType == domain.OrderType.DINE_IN,
                          onSelected: (_) {
                            setState(
                                () => selectedType = domain.OrderType.DINE_IN);
                          },
                        ),
                        ChoiceChip(
                          label: Text(_takeawayLabel(context)),
                          selected: selectedType == domain.OrderType.TAKEAWAY,
                          onSelected: (_) {
                            setState(
                                () => selectedType = domain.OrderType.TAKEAWAY);
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.delivery),
                          selected: selectedType == domain.OrderType.DELIVERY,
                          onSelected: (_) {
                            setState(
                                () => selectedType = domain.OrderType.DELIVERY);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedType == domain.OrderType.DINE_IN) ...[
                      Text(
                        _selectTableLabel(context),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      if (sortedTables.isEmpty)
                        const Text('No tables available.')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sortedTables
                              .map((table) => ChoiceChip(
                                    label: Text(_tableNumberOf(table)),
                                    selected: _tableIdOf(selectedTable) ==
                                        _tableIdOf(table),
                                    onSelected: (_) {
                                      setState(() => selectedTable = table);
                                    },
                                  ))
                              .toList(),
                        ),
                    ],
                    if (selectedType == domain.OrderType.DELIVERY) ...[
                      Text(
                        l10n.deliveryManagement,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedProvider,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Provider',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'internal',
                            child: Text(_internalDriverLabel(context)),
                          ),
                          const DropdownMenuItem(
                            value: 'uber-eats',
                            child: Text('Uber Eats'),
                          ),
                          const DropdownMenuItem(
                            value: 'mock-aggregator',
                            child: Text('Mock Aggregator'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedProvider = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: feeController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Delivery Fee',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedType == domain.OrderType.DINE_IN &&
                      (selectedTable == null ||
                          _tableNumberOf(selectedTable).isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_selectTableLabel(context))),
                    );
                    return;
                  }
                  final deliveryFee =
                      double.tryParse(feeController.text) ?? 0.0;
                  final deliveryAddress = addressController.text.trim();

                  Navigator.pop(
                    context,
                    _CheckoutSelection(
                      type: selectedType,
                      tableNumber: selectedType == domain.OrderType.DINE_IN
                          ? _tableNumberOf(selectedTable)
                          : null,
                      deliveryAddress: selectedType == domain.OrderType.DELIVERY
                          ? (deliveryAddress.isEmpty ? null : deliveryAddress)
                          : null,
                      deliveryFee: selectedType == domain.OrderType.DELIVERY
                          ? deliveryFee
                          : 0.0,
                      deliveryProvider:
                          selectedType == domain.OrderType.DELIVERY
                              ? selectedProvider
                              : null,
                    ),
                  );
                },
                child: Text(l10n.next),
              ),
            ],
          ),
        );
      },
    );

    feeController.dispose();
    addressController.dispose();
    return selection;
  }

  Future<void> _showEditItemDialog(
      BuildContext context, WidgetRef ref, CartItem item) async {
    final noteController = TextEditingController(text: item.notes);
    final discountController =
        TextEditingController(text: item.discountAmount.toString());
    final taxController =
        TextEditingController(text: item.taxAmount.toString());
    int quantity = item.quantity;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .editItem(isArabic ? item.product.nameAr : item.product.nameEn)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.notes),
                ),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.itemDiscount),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: taxController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.itemTax),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update quantity and notes
                ref
                    .read(cartControllerProvider.notifier)
                    .updateQuantity(item.product, quantity);
                ref
                    .read(cartControllerProvider.notifier)
                    .updateNotes(item.product, noteController.text);
                ref.read(cartControllerProvider.notifier).setItemDiscount(
                    item.product,
                    double.tryParse(discountController.text) ?? 0.0);
                ref.read(cartControllerProvider.notifier).setItemTax(
                    item.product, double.tryParse(taxController.text) ?? 0.0);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerSelectionDialog(
      BuildContext context, WidgetRef ref) async {
    final searchController = TextEditingController();
    // Using a ValueNotifier to handle search results update without rebuilding the whole widget tree
    // Ideally, this should be in a separate widget/provider
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.select),
            content: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.searchCustomerHint,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(
                              () {}); // Trigger rebuild to run FutureBuilder
                        },
                      ),
                    ),
                    onSubmitted: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<domain.Customer>>(
                      future: ref
                          .read(customersRepositoryProvider)
                          .searchCustomers(searchController.text),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  '${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
                        }
                        final customers = snapshot.data ?? [];
                        if (customers.isEmpty) {
                          return Center(
                              child: Text(AppLocalizations.of(context)!
                                  .noCustomersFound));
                        }
                        return ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return ListTile(
                              title: Text(customer.name),
                              subtitle: Text(customer.phoneNumber),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${customer.loyaltyPoints} pts',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(customer.tier,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              onTap: () {
                                ref
                                    .read(cartControllerProvider.notifier)
                                    .selectCustomer(customer);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Close selection dialog and open create dialog
                  // Or open create dialog on top
                  await _showCreateCustomerDialog(context, ref);
                  // After create, if successful, we might want to refresh or if user selected one, we are done.
                  // For simplicity, let's just close this dialog if customer was selected in create dialog
                  if (ref.read(cartControllerProvider).selectedCustomer !=
                          null &&
                      context.mounted) {
                    Navigator.pop(context);
                  } else {
                    setState(
                        () {}); // Refresh list if we just created one but didn't select?
                    // Actually createCustomer returns the customer, so we can just select it.
                  }
                },
                child: Text(AppLocalizations.of(context)!.newCustomer),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showCreateCustomerDialog(
      BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newCustomer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseFillAllFields)),
                );
                return;
              }

              try {
                final customer = await ref
                    .read(customersRepositoryProvider)
                    .createCustomer(name, phone);

                ref
                    .read(cartControllerProvider.notifier)
                    .selectCustomer(customer);

                if (context.mounted) {
                  Navigator.pop(context); // Close Create Dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${AppLocalizations.of(context)!.customerCreated}: ${customer.name}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${AppLocalizations.of(context)!.errorCreatingCustomer}: $e')),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  Future<void> _showGlobalValueDialog(BuildContext context, WidgetRef ref,
      String title, double currentValue, Function(double) onSave) async {
    final controller = TextEditingController(text: currentValue.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.set} $title'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context)!.amount} ($title)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              onSave(val);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoyaltyHistory(
      BuildContext context, WidgetRef ref, String customerId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loyaltyHistory),
        content: SizedBox(
          width: 400,
          height: 400,
          child: FutureBuilder<List<LoyaltyTransaction>>(
            future: ref
                .read(customersRepositoryProvider)
                .getLoyaltyHistory(customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        '${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
              }
              final transactions = snapshot.data ?? [];
              if (transactions.isEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)!.noHistoryFound));
              }
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isRedeem = tx.type == 'REDEEM';
                  return ListTile(
                    leading: Icon(
                      isRedeem ? Icons.remove_circle : Icons.add_circle,
                      color: isRedeem ? Colors.red : Colors.green,
                    ),
                    title: Text('${tx.points} pts'),
                    subtitle: Text(tx.description ?? tx.type),
                    trailing: Text(
                      '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSelection {
  final domain.OrderType type;
  final String? tableNumber;
  final String? deliveryAddress;
  final String? deliveryProvider;
  final double deliveryFee;

  const _CheckoutSelection({
    required this.type,
    this.tableNumber,
    this.deliveryAddress,
    this.deliveryProvider,
    this.deliveryFee = 0,
  });
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'POS System';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get printerSettings => 'Printer Settings';

  @override
  String get printerIp => 'Printer IP Address';

  @override
  String get printerPort => 'Printer Port';

  @override
  String get paperSize => 'Paper Size';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get dataSync => 'Data Sync';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get orders => 'Orders';

  @override
  String get inventory => 'Inventory';

  @override
  String get reports => 'Reports';

  @override
  String get customers => 'Customers';

  @override
  String get kitchen => 'Kitchen';

  @override
  String get floorPlan => 'Floor Plan';

  @override
  String get kitchenDisplay => 'Kitchen Display';

  @override
  String get shifts => 'Shifts';

  @override
  String get myDeliveries => 'My Deliveries';

  @override
  String get deliveryOrders => 'Delivery Orders';

  @override
  String get refunds => 'Refunds';

  @override
  String get users => 'Users';

  @override
  String get categories => 'Categories';

  @override
  String get orderHistory => 'Order History';

  @override
  String get delivery => 'Delivery';

  @override
  String get workHistory => 'Work History';

  @override
  String get currentOrder => 'Current Order';

  @override
  String get customer => 'Customer';

  @override
  String get guest => 'Guest';

  @override
  String get select => 'Select';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get approveRefunds => 'Approve Refunds';

  @override
  String get enterTableNumber => 'Enter Table Number';

  @override
  String get tableNumberPlaceholder => 'Table # or \"TakeAway\"';

  @override
  String get next => 'Next';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get payLater => 'Pay Later';

  @override
  String get loyaltyPoints => 'Loyalty Points';

  @override
  String get charge => 'Charge';

  @override
  String get save => 'Save';

  @override
  String get notes => 'Notes';

  @override
  String get itemDiscount => 'Item Discount';

  @override
  String get itemTax => 'Item Tax';

  @override
  String get searchCustomerHint => 'Search by name or phone';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get newCustomer => 'New Customer';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get customerCreated => 'Customer created';

  @override
  String get errorCreatingCustomer => 'Error creating customer';

  @override
  String get set => 'Set';

  @override
  String get amount => 'Amount';

  @override
  String get loyaltyHistory => 'Loyalty History';

  @override
  String get noHistoryFound => 'No history found';

  @override
  String get close => 'Close';

  @override
  String get create => 'Create';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get status => 'Status';

  @override
  String get sync => 'Sync';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncSuccess => 'Sync Completed Successfully';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get notAuthenticated => 'Not authenticated';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get purchaseOrders => 'Purchase Orders';

  @override
  String get modifierRecipes => 'Modifier Recipes';

  @override
  String get logs => 'Logs';

  @override
  String get inventoryAndPurchasing => 'Inventory & Purchasing';

  @override
  String get syncInventory => 'Sync Inventory';

  @override
  String get reportsAndAnalytics => 'Reports & Analytics';

  @override
  String get dailySales => 'Daily Sales';

  @override
  String salesCount(int count) {
    return 'Count: $count orders';
  }

  @override
  String get lowStockAlerts => 'Low Stock Alerts';

  @override
  String get noLowStockAlerts => 'No low stock alerts.';

  @override
  String stockLevel(double stock, String unit, double min) {
    final intl.NumberFormat stockNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stockString = stockNumberFormat.format(stock);
    final intl.NumberFormat minNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minString = minNumberFormat.format(min);

    return 'Stock: $stockString $unit (Min: $minString)';
  }

  @override
  String get topProducts => 'Top Products';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String itemsSold(int count) {
    return '$count sold';
  }

  @override
  String get salesByCategory => 'Sales by Category';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get kitchenDisplaySystem => 'Kitchen Display System';

  @override
  String get allStations => 'All Stations';

  @override
  String get pending => 'Pending';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get served => 'Served';

  @override
  String tableNumber(String number) {
    return 'Table $number';
  }

  @override
  String note(String note) {
    return 'Note: $note';
  }

  @override
  String get print => 'Print';

  @override
  String moveTo(String status) {
    return 'Move to $status';
  }

  @override
  String get editTable => 'Edit Table';

  @override
  String get tableNumberInput => 'Table Number';

  @override
  String get shape => 'Shape';

  @override
  String get rectangle => 'Rectangle';

  @override
  String get circle => 'Circle';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get loginSuccess => 'Login Success!';

  @override
  String get enterEmail => 'Please enter email';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get customersAndLoyalty => 'Customers & Loyalty';

  @override
  String pointsTier(int points, String tier) {
    return '$points Points - $tier Tier';
  }

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get required => 'Required';

  @override
  String get add => 'Add';

  @override
  String get general => 'General';

  @override
  String get administration => 'Administration';

  @override
  String get staffManagement => 'Staff Management';

  @override
  String get edit => 'Edit';

  @override
  String get deleteUser => 'Delete User';

  @override
  String deleteUserConfirmation(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get editUser => 'Edit User';

  @override
  String get addUser => 'Add User';

  @override
  String get email => 'Email';

  @override
  String get passwordPlaceholder => 'Password';

  @override
  String get passwordEditPlaceholder => 'Password (leave blank to keep)';

  @override
  String get role => 'Role';

  @override
  String get pinCode => 'PIN Code (Optional)';

  @override
  String get shiftManagement => 'Shift Management';

  @override
  String get openShift => 'Open Shift';

  @override
  String get closeShift => 'Close Shift';

  @override
  String get payIn => 'Pay In';

  @override
  String get payOut => 'Pay Out';

  @override
  String get reason => 'Reason';

  @override
  String get startingCash => 'Starting Cash';

  @override
  String get endingCash => 'Ending Cash (Counted)';

  @override
  String shiftId(String id) {
    return 'Shift ID: $id';
  }

  @override
  String started(String time) {
    return 'Started: $time';
  }

  @override
  String startingCashLabel(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return 'Starting Cash: $amountString';
  }

  @override
  String get open => 'Open';

  @override
  String get deliveryManagement => 'Delivery Management';

  @override
  String get noActiveDeliveryOrders => 'No active delivery orders';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String addressLabel(String address) {
    return 'Address: $address';
  }

  @override
  String get noAddress => 'No address';

  @override
  String deliveryFeeLabel(double fee) {
    final intl.NumberFormat feeNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String feeString = feeNumberFormat.format(fee);

    return 'Delivery Fee: $feeString';
  }

  @override
  String providerLabel(String provider, String refId) {
    return 'Provider: $provider (Ref: $refId)';
  }

  @override
  String itemsCount(int count) {
    return 'Items: $count';
  }

  @override
  String totalLabel(double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'Total: $totalString';
  }

  @override
  String get externalDelivery => 'External Delivery';

  @override
  String get driverAssigned => 'Driver Assigned';

  @override
  String get uberEats => 'UberEats';

  @override
  String get assignDriver => 'Assign Driver';

  @override
  String get noDriversFound => 'No drivers found. Add a user with DRIVER role.';

  @override
  String get assign => 'Assign';

  @override
  String get cannotSyncNotLoggedIn => 'Cannot sync: Not logged in';

  @override
  String usePoints(int points, int available) {
    return 'Use $points pts (Available: $available)';
  }

  @override
  String editItem(String name) {
    return 'Edit $name';
  }

  @override
  String get startDelivery => 'Start Delivery';

  @override
  String get markAsDelivered => 'Mark as Delivered';

  @override
  String get completed => 'Completed';

  @override
  String customerLabel(String name) {
    return 'Customer: $name';
  }

  @override
  String get noAssignedDeliveries => 'No assigned deliveries.';

  @override
  String get pendingRefunds => 'Pending Refunds';

  @override
  String get noPendingRefunds => 'No pending refunds';

  @override
  String refundLabel(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return 'Refund $amountString';
  }

  @override
  String reasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get refundApproved => 'Refund Approved';

  @override
  String get refundRejected => 'Refund Rejected';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get date => 'Date';

  @override
  String get table => 'Table';

  @override
  String get itemsTitle => 'Items';

  @override
  String get refundsTitle => 'Refunds';

  @override
  String get requestRefund => 'Request Refund';

  @override
  String get voidOrder => 'Void Order';

  @override
  String get returnStock => 'Return Stock';

  @override
  String get refundRequested => 'Refund requested';

  @override
  String get orderVoided => 'Order Voided';

  @override
  String get submit => 'Submit';

  @override
  String get voidAction => 'Void';

  @override
  String get noSuppliersFound => 'No suppliers found';

  @override
  String get noContactInfo => 'No contact info';

  @override
  String get addSupplier => 'Add Supplier';

  @override
  String get noIngredientsFound => 'No ingredients found';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get editIngredient => 'Edit Ingredient';

  @override
  String get unitLabel => 'Unit (e.g., kg, L)';

  @override
  String adjustStockTitle(String name) {
    return 'Adjust Stock: $name';
  }

  @override
  String currentTotal(double total, String unit) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Current Total: $totalString $unit';
  }

  @override
  String get adjustmentAmount => 'Adjustment Amount (+/-)';

  @override
  String get notesDescription => 'Notes / Description';

  @override
  String get mandatoryForWaste => 'Mandatory for Waste/Spoilage';

  @override
  String get noWarehousesFound => 'No warehouses found';

  @override
  String get warehouse => 'Warehouse';

  @override
  String get mainWarehouse => 'Main';

  @override
  String errorLoadingWarehouses(String error) {
    return 'Error loading warehouses: $error';
  }

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get descriptionRequired =>
      'Description is required for Waste/Spoilage';

  @override
  String get adjust => 'Adjust';

  @override
  String get noPurchaseOrders => 'No Purchase Orders';

  @override
  String poNumber(String id, String supplier) {
    return 'PO #$id - $supplier';
  }

  @override
  String poStatusTotal(String status, double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'Status: $status\nTotal: $totalString';
  }

  @override
  String get createPO => 'Create Purchase Order';

  @override
  String get noSuppliersAvailable =>
      'No suppliers available. Create one first.';

  @override
  String get selectSupplier => 'Select Supplier';

  @override
  String poDetails(String status) {
    return 'PO Details - $status';
  }

  @override
  String get receiveOrder => 'Receive Order (Update Stock)';

  @override
  String get addItem => 'Add Item';

  @override
  String get noIngredientsAvailable => 'No ingredients. Create one first.';

  @override
  String get selectIngredient => 'Select Ingredient';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get ingredientLogs => 'Ingredient Logs';

  @override
  String get inventoryLogs => 'Inventory Logs';

  @override
  String get noLogsFound => 'No inventory logs found';

  @override
  String get unknownIngredient => 'Unknown Ingredient';

  @override
  String warehouseLabel(String name) {
    return 'Warehouse: $name';
  }

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get items => 'items';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noModifiersFound => 'No modifiers found in products.';

  @override
  String recipeTitle(String name) {
    return 'Recipe: $name';
  }

  @override
  String get noIngredientsInRecipe => 'No ingredients in this recipe';

  @override
  String get quantityPerItem => 'Quantity per item';

  @override
  String get noIngredientsAvailableSimple => 'No ingredients available.';

  @override
  String itemPriceQuantity(int quantity, double price) {
    final intl.NumberFormat priceNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String priceString = priceNumberFormat.format(price);

    return '$quantity x $priceString';
  }

  @override
  String priceLabel(double price) {
    final intl.NumberFormat priceNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String priceString = priceNumberFormat.format(price);

    return '$priceString';
  }

  @override
  String firedCourse(String course) {
    return 'Fired $course!';
  }

  @override
  String tableOrderTitle(String number) {
    return 'Table $number Order';
  }

  @override
  String get noActiveOrderFound => 'No active order found';

  @override
  String get fire => 'FIRE';

  @override
  String quantityCount(int count) {
    return 'x$count';
  }

  @override
  String selectAtLeast(int count, String name) {
    return 'Please select at least $count option(s) for $name';
  }

  @override
  String get selectOne => 'Select 1';

  @override
  String selectUpTo(int count) {
    return 'Select up to $count';
  }

  @override
  String get specialInstructions => 'Special instructions...';

  @override
  String get notesLabel => 'Notes';

  @override
  String addToCartTotal(double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'Add to Cart - $totalString';
  }
}

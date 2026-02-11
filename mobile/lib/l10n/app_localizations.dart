import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'POS System'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Printer Settings'**
  String get printerSettings;

  /// No description provided for @printerIp.
  ///
  /// In en, this message translates to:
  /// **'Printer IP Address'**
  String get printerIp;

  /// No description provided for @printerPort.
  ///
  /// In en, this message translates to:
  /// **'Printer Port'**
  String get printerPort;

  /// No description provided for @paperSize.
  ///
  /// In en, this message translates to:
  /// **'Paper Size'**
  String get paperSize;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @floorPlan.
  ///
  /// In en, this message translates to:
  /// **'Floor Plan'**
  String get floorPlan;

  /// No description provided for @kitchenDisplay.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Display'**
  String get kitchenDisplay;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @myDeliveries.
  ///
  /// In en, this message translates to:
  /// **'My Deliveries'**
  String get myDeliveries;

  /// No description provided for @deliveryOrders.
  ///
  /// In en, this message translates to:
  /// **'Delivery Orders'**
  String get deliveryOrders;

  /// No description provided for @refunds.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refunds;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @workHistory.
  ///
  /// In en, this message translates to:
  /// **'Work History'**
  String get workHistory;

  /// No description provided for @currentOrder.
  ///
  /// In en, this message translates to:
  /// **'Current Order'**
  String get currentOrder;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @approveRefunds.
  ///
  /// In en, this message translates to:
  /// **'Approve Refunds'**
  String get approveRefunds;

  /// No description provided for @enterTableNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Table Number'**
  String get enterTableNumber;

  /// No description provided for @tableNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Table # or \"TakeAway\"'**
  String get tableNumberPlaceholder;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @payLater.
  ///
  /// In en, this message translates to:
  /// **'Pay Later'**
  String get payLater;

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get loyaltyPoints;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @itemDiscount.
  ///
  /// In en, this message translates to:
  /// **'Item Discount'**
  String get itemDiscount;

  /// No description provided for @itemTax.
  ///
  /// In en, this message translates to:
  /// **'Item Tax'**
  String get itemTax;

  /// No description provided for @searchCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchCustomerHint;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @customerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer created'**
  String get customerCreated;

  /// No description provided for @errorCreatingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Error creating customer'**
  String get errorCreatingCustomer;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @loyaltyHistory.
  ///
  /// In en, this message translates to:
  /// **'Loyalty History'**
  String get loyaltyHistory;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync Completed Successfully'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get syncFailed;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get notAuthenticated;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @purchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get purchaseOrders;

  /// No description provided for @modifierRecipes.
  ///
  /// In en, this message translates to:
  /// **'Modifier Recipes'**
  String get modifierRecipes;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @inventoryAndPurchasing.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Purchasing'**
  String get inventoryAndPurchasing;

  /// No description provided for @syncInventory.
  ///
  /// In en, this message translates to:
  /// **'Sync Inventory'**
  String get syncInventory;

  /// No description provided for @reportsAndAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsAndAnalytics;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySales;

  /// No description provided for @salesCount.
  ///
  /// In en, this message translates to:
  /// **'Count: {count} orders'**
  String salesCount(int count);

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @noLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'No low stock alerts.'**
  String get noLowStockAlerts;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock} {unit} (Min: {min})'**
  String stockLevel(double stock, String unit, double min);

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get topProducts;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @itemsSold.
  ///
  /// In en, this message translates to:
  /// **'{count} sold'**
  String itemsSold(int count);

  /// No description provided for @salesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Sales by Category'**
  String get salesByCategory;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @kitchenDisplaySystem.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Display System'**
  String get kitchenDisplaySystem;

  /// No description provided for @allStations.
  ///
  /// In en, this message translates to:
  /// **'All Stations'**
  String get allStations;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @served.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get served;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table {number}'**
  String tableNumber(String number);

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String note(String note);

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to {status}'**
  String moveTo(String status);

  /// No description provided for @editTable.
  ///
  /// In en, this message translates to:
  /// **'Edit Table'**
  String get editTable;

  /// No description provided for @tableNumberInput.
  ///
  /// In en, this message translates to:
  /// **'Table Number'**
  String get tableNumberInput;

  /// No description provided for @shape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// No description provided for @rectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get rectangle;

  /// No description provided for @circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Success!'**
  String get loginSuccess;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @customersAndLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Customers & Loyalty'**
  String get customersAndLoyalty;

  /// No description provided for @pointsTier.
  ///
  /// In en, this message translates to:
  /// **'{points} Points - {tier} Tier'**
  String pointsTier(int points, String tier);

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @staffManagement.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get staffManagement;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteUserConfirmation(String name);

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordPlaceholder;

  /// No description provided for @passwordEditPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Password (leave blank to keep)'**
  String get passwordEditPlaceholder;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code (Optional)'**
  String get pinCode;

  /// No description provided for @shiftManagement.
  ///
  /// In en, this message translates to:
  /// **'Shift Management'**
  String get shiftManagement;

  /// No description provided for @openShift.
  ///
  /// In en, this message translates to:
  /// **'Open Shift'**
  String get openShift;

  /// No description provided for @closeShift.
  ///
  /// In en, this message translates to:
  /// **'Close Shift'**
  String get closeShift;

  /// No description provided for @payIn.
  ///
  /// In en, this message translates to:
  /// **'Pay In'**
  String get payIn;

  /// No description provided for @payOut.
  ///
  /// In en, this message translates to:
  /// **'Pay Out'**
  String get payOut;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @startingCash.
  ///
  /// In en, this message translates to:
  /// **'Starting Cash'**
  String get startingCash;

  /// No description provided for @endingCash.
  ///
  /// In en, this message translates to:
  /// **'Ending Cash (Counted)'**
  String get endingCash;

  /// No description provided for @shiftId.
  ///
  /// In en, this message translates to:
  /// **'Shift ID: {id}'**
  String shiftId(String id);

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started: {time}'**
  String started(String time);

  /// No description provided for @startingCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Cash: {amount}'**
  String startingCashLabel(double amount);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @deliveryManagement.
  ///
  /// In en, this message translates to:
  /// **'Delivery Management'**
  String get deliveryManagement;

  /// No description provided for @noActiveDeliveryOrders.
  ///
  /// In en, this message translates to:
  /// **'No active delivery orders'**
  String get noActiveDeliveryOrders;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String addressLabel(String address);

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get noAddress;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee: {fee}'**
  String deliveryFeeLabel(double fee);

  /// No description provided for @providerLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider: {provider} (Ref: {refId})'**
  String providerLabel(String provider, String refId);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items: {count}'**
  String itemsCount(int count);

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String totalLabel(double total);

  /// No description provided for @externalDelivery.
  ///
  /// In en, this message translates to:
  /// **'External Delivery'**
  String get externalDelivery;

  /// No description provided for @driverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver Assigned'**
  String get driverAssigned;

  /// No description provided for @uberEats.
  ///
  /// In en, this message translates to:
  /// **'UberEats'**
  String get uberEats;

  /// No description provided for @assignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assignDriver;

  /// No description provided for @noDriversFound.
  ///
  /// In en, this message translates to:
  /// **'No drivers found. Add a user with DRIVER role.'**
  String get noDriversFound;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @cannotSyncNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Cannot sync: Not logged in'**
  String get cannotSyncNotLoggedIn;

  /// No description provided for @usePoints.
  ///
  /// In en, this message translates to:
  /// **'Use {points} pts (Available: {available})'**
  String usePoints(int points, int available);

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editItem(String name);

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery'**
  String get startDelivery;

  /// No description provided for @markAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markAsDelivered;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerLabel(String name);

  /// No description provided for @noAssignedDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No assigned deliveries.'**
  String get noAssignedDeliveries;

  /// No description provided for @pendingRefunds.
  ///
  /// In en, this message translates to:
  /// **'Pending Refunds'**
  String get pendingRefunds;

  /// No description provided for @noPendingRefunds.
  ///
  /// In en, this message translates to:
  /// **'No pending refunds'**
  String get noPendingRefunds;

  /// No description provided for @refundLabel.
  ///
  /// In en, this message translates to:
  /// **'Refund {amount}'**
  String refundLabel(double amount);

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonLabel(String reason);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @refundApproved.
  ///
  /// In en, this message translates to:
  /// **'Refund Approved'**
  String get refundApproved;

  /// No description provided for @refundRejected.
  ///
  /// In en, this message translates to:
  /// **'Refund Rejected'**
  String get refundRejected;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// No description provided for @refundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refundsTitle;

  /// No description provided for @requestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request Refund'**
  String get requestRefund;

  /// No description provided for @voidOrder.
  ///
  /// In en, this message translates to:
  /// **'Void Order'**
  String get voidOrder;

  /// No description provided for @returnStock.
  ///
  /// In en, this message translates to:
  /// **'Return Stock'**
  String get returnStock;

  /// No description provided for @refundRequested.
  ///
  /// In en, this message translates to:
  /// **'Refund requested'**
  String get refundRequested;

  /// No description provided for @orderVoided.
  ///
  /// In en, this message translates to:
  /// **'Order Voided'**
  String get orderVoided;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @voidAction.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get voidAction;

  /// No description provided for @noSuppliersFound.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get noSuppliersFound;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact info'**
  String get noContactInfo;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @noIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get noIngredientsFound;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @editIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredient;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g., kg, L)'**
  String get unitLabel;

  /// No description provided for @adjustStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock: {name}'**
  String adjustStockTitle(String name);

  /// No description provided for @currentTotal.
  ///
  /// In en, this message translates to:
  /// **'Current Total: {total} {unit}'**
  String currentTotal(double total, String unit);

  /// No description provided for @adjustmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Amount (+/-)'**
  String get adjustmentAmount;

  /// No description provided for @notesDescription.
  ///
  /// In en, this message translates to:
  /// **'Notes / Description'**
  String get notesDescription;

  /// No description provided for @mandatoryForWaste.
  ///
  /// In en, this message translates to:
  /// **'Mandatory for Waste/Spoilage'**
  String get mandatoryForWaste;

  /// No description provided for @noWarehousesFound.
  ///
  /// In en, this message translates to:
  /// **'No warehouses found'**
  String get noWarehousesFound;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @mainWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainWarehouse;

  /// No description provided for @errorLoadingWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Error loading warehouses: {error}'**
  String errorLoadingWarehouses(String error);

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required for Waste/Spoilage'**
  String get descriptionRequired;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjust;

  /// No description provided for @noPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'No Purchase Orders'**
  String get noPurchaseOrders;

  /// No description provided for @poNumber.
  ///
  /// In en, this message translates to:
  /// **'PO #{id} - {supplier}'**
  String poNumber(String id, String supplier);

  /// No description provided for @poStatusTotal.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}\nTotal: {total}'**
  String poStatusTotal(String status, double total);

  /// No description provided for @createPO.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Order'**
  String get createPO;

  /// No description provided for @noSuppliersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No suppliers available. Create one first.'**
  String get noSuppliersAvailable;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get selectSupplier;

  /// No description provided for @poDetails.
  ///
  /// In en, this message translates to:
  /// **'PO Details - {status}'**
  String poDetails(String status);

  /// No description provided for @receiveOrder.
  ///
  /// In en, this message translates to:
  /// **'Receive Order (Update Stock)'**
  String get receiveOrder;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @noIngredientsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ingredients. Create one first.'**
  String get noIngredientsAvailable;

  /// No description provided for @selectIngredient.
  ///
  /// In en, this message translates to:
  /// **'Select Ingredient'**
  String get selectIngredient;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @ingredientLogs.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Logs'**
  String get ingredientLogs;

  /// No description provided for @inventoryLogs.
  ///
  /// In en, this message translates to:
  /// **'Inventory Logs'**
  String get inventoryLogs;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory logs found'**
  String get noLogsFound;

  /// No description provided for @unknownIngredient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Ingredient'**
  String get unknownIngredient;

  /// No description provided for @warehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse: {name}'**
  String warehouseLabel(String name);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noModifiersFound.
  ///
  /// In en, this message translates to:
  /// **'No modifiers found in products.'**
  String get noModifiersFound;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {name}'**
  String recipeTitle(String name);

  /// No description provided for @noIngredientsInRecipe.
  ///
  /// In en, this message translates to:
  /// **'No ingredients in this recipe'**
  String get noIngredientsInRecipe;

  /// No description provided for @quantityPerItem.
  ///
  /// In en, this message translates to:
  /// **'Quantity per item'**
  String get quantityPerItem;

  /// No description provided for @noIngredientsAvailableSimple.
  ///
  /// In en, this message translates to:
  /// **'No ingredients available.'**
  String get noIngredientsAvailableSimple;

  /// No description provided for @itemPriceQuantity.
  ///
  /// In en, this message translates to:
  /// **'{quantity} x {price}'**
  String itemPriceQuantity(int quantity, double price);

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String priceLabel(double price);

  /// No description provided for @firedCourse.
  ///
  /// In en, this message translates to:
  /// **'Fired {course}!'**
  String firedCourse(String course);

  /// No description provided for @tableOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Table {number} Order'**
  String tableOrderTitle(String number);

  /// No description provided for @noActiveOrderFound.
  ///
  /// In en, this message translates to:
  /// **'No active order found'**
  String get noActiveOrderFound;

  /// No description provided for @fire.
  ///
  /// In en, this message translates to:
  /// **'FIRE'**
  String get fire;

  /// No description provided for @quantityCount.
  ///
  /// In en, this message translates to:
  /// **'x{count}'**
  String quantityCount(int count);

  /// No description provided for @selectAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Please select at least {count} option(s) for {name}'**
  String selectAtLeast(int count, String name);

  /// No description provided for @selectOne.
  ///
  /// In en, this message translates to:
  /// **'Select 1'**
  String get selectOne;

  /// No description provided for @selectUpTo.
  ///
  /// In en, this message translates to:
  /// **'Select up to {count}'**
  String selectUpTo(int count);

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions...'**
  String get specialInstructions;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @addToCartTotal.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart - {total}'**
  String addToCartTotal(double total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

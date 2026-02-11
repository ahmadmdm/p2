// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuTitle => 'Menu';

  @override
  String get myOrder => 'My Order';

  @override
  String get viewCart => 'View Cart';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addedToCart => 'added to cart';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get requestBill => 'Request Bill';

  @override
  String get orderMore => 'Order More Items';

  @override
  String get total => 'Total';

  @override
  String get items => 'Items';

  @override
  String get notes => 'Notes';

  @override
  String get modifiers => 'Modifiers';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get orderPlaced => 'Order placed successfully!';

  @override
  String get billRequested =>
      'Bill requested. A waiter will be with you shortly.';

  @override
  String get error => 'Error';

  @override
  String get pending => 'Pending';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get served => 'Served';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get unknown => 'Unknown';
}

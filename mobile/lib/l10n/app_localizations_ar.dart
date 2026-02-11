// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نظام نقاط البيع';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'إنجليزي';

  @override
  String get arabic => 'عربي';

  @override
  String get printerSettings => 'إعدادات الطابعة';

  @override
  String get printerIp => 'عنوان IP للطابعة';

  @override
  String get printerPort => 'منفذ الطابعة';

  @override
  String get paperSize => 'حجم الورق';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get dataSync => 'مزامنة البيانات';

  @override
  String get dashboard => 'لوحة المعلومات';

  @override
  String get orders => 'الطلبات';

  @override
  String get inventory => 'المخزون';

  @override
  String get reports => 'التقارير';

  @override
  String get customers => 'العملاء';

  @override
  String get kitchen => 'المطبخ';

  @override
  String get floorPlan => 'مخطط الطاولات';

  @override
  String get kitchenDisplay => 'شاشة المطبخ';

  @override
  String get shifts => 'الورديات';

  @override
  String get myDeliveries => 'طلباتي';

  @override
  String get deliveryOrders => 'طلبات التوصيل';

  @override
  String get refunds => 'استرجاع';

  @override
  String get users => 'المستخدمين';

  @override
  String get categories => 'الفئات';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get delivery => 'التوصيل';

  @override
  String get workHistory => 'سجل العمل';

  @override
  String get currentOrder => 'الطلب الحالي';

  @override
  String get customer => 'العميل';

  @override
  String get guest => 'ضيف';

  @override
  String get select => 'اختيار';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

  @override
  String get tax => 'الضريبة';

  @override
  String get clearCart => 'مسح السلة';

  @override
  String get approveRefunds => 'الموافقة على الاسترجاع';

  @override
  String get enterTableNumber => 'أدخل رقم الطاولة';

  @override
  String get tableNumberPlaceholder => 'رقم الطاولة أو \"سفري\"';

  @override
  String get next => 'التالي';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get cash => 'نقداً';

  @override
  String get card => 'بطاقة';

  @override
  String get payLater => 'دفع لاحقاً';

  @override
  String get loyaltyPoints => 'نقاط الولاء';

  @override
  String get charge => 'دفع';

  @override
  String get save => 'حفظ';

  @override
  String get notes => 'ملاحظات';

  @override
  String get itemDiscount => 'خصم الصنف';

  @override
  String get itemTax => 'ضريبة الصنف';

  @override
  String get searchCustomerHint => 'بحث بالاسم أو الهاتف';

  @override
  String get noCustomersFound => 'لا يوجد عملاء';

  @override
  String get newCustomer => 'عميل جديد';

  @override
  String get name => 'الاسم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get customerCreated => 'تم إنشاء العميل';

  @override
  String get errorCreatingCustomer => 'خطأ في إنشاء العميل';

  @override
  String get set => 'تعيين';

  @override
  String get amount => 'المبلغ';

  @override
  String get loyaltyHistory => 'سجل الولاء';

  @override
  String get noHistoryFound => 'لا يوجد سجل';

  @override
  String get close => 'إغلاق';

  @override
  String get create => 'إنشاء';

  @override
  String get noOrdersFound => 'لا توجد طلبات';

  @override
  String get status => 'الحالة';

  @override
  String get sync => 'مزامنة';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get syncSuccess => 'تمت المزامنة بنجاح';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get notAuthenticated => 'غير مسجل الدخول';

  @override
  String get suppliers => 'الموردين';

  @override
  String get ingredients => 'المكونات';

  @override
  String get purchaseOrders => 'أوامر الشراء';

  @override
  String get modifierRecipes => 'وصفات الإضافات';

  @override
  String get logs => 'السجلات';

  @override
  String get inventoryAndPurchasing => 'المخزون والمشتريات';

  @override
  String get syncInventory => 'مزامنة المخزون';

  @override
  String get reportsAndAnalytics => 'التقارير والتحليلات';

  @override
  String get dailySales => 'المبيعات اليومية';

  @override
  String salesCount(int count) {
    return 'العدد: $count طلبات';
  }

  @override
  String get lowStockAlerts => 'تنبيهات انخفاض المخزون';

  @override
  String get noLowStockAlerts => 'لا توجد تنبيهات لانخفاض المخزون.';

  @override
  String stockLevel(double stock, String unit, double min) {
    final intl.NumberFormat stockNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stockString = stockNumberFormat.format(stock);
    final intl.NumberFormat minNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minString = minNumberFormat.format(min);

    return 'المخزون: $stockString $unit (الحد الأدنى: $minString)';
  }

  @override
  String get topProducts => 'المنتجات الأكثر مبيعاً';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة.';

  @override
  String itemsSold(int count) {
    return 'تم بيع $count';
  }

  @override
  String get salesByCategory => 'المبيعات حسب الفئة';

  @override
  String get uncategorized => 'غير مصنف';

  @override
  String get kitchenDisplaySystem => 'نظام عرض المطبخ';

  @override
  String get allStations => 'كل المحطات';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get preparing => 'جاري التحضير';

  @override
  String get ready => 'جاهز';

  @override
  String get served => 'تم التقديم';

  @override
  String tableNumber(String number) {
    return 'طاولة $number';
  }

  @override
  String note(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String get print => 'طباعة';

  @override
  String moveTo(String status) {
    return 'انقل إلى $status';
  }

  @override
  String get editTable => 'تعديل الطاولة';

  @override
  String get tableNumberInput => 'رقم الطاولة';

  @override
  String get shape => 'الشكل';

  @override
  String get rectangle => 'مستطيل';

  @override
  String get circle => 'دائرة';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get enterEmail => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get enterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get customersAndLoyalty => 'العملاء والولاء';

  @override
  String pointsTier(int points, String tier) {
    return '$points نقاط - مستوى $tier';
  }

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get required => 'مطلوب';

  @override
  String get add => 'إضافة';

  @override
  String get general => 'عام';

  @override
  String get administration => 'الإدارة';

  @override
  String get staffManagement => 'إدارة الموظفين';

  @override
  String get edit => 'تعديل';

  @override
  String get deleteUser => 'حذف المستخدم';

  @override
  String deleteUserConfirmation(String name) {
    return 'هل أنت متأكد من حذف $name؟';
  }

  @override
  String get editUser => 'تعديل المستخدم';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get passwordPlaceholder => 'كلمة المرور';

  @override
  String get passwordEditPlaceholder =>
      'كلمة المرور (اتركها فارغة للإبقاء عليها)';

  @override
  String get role => 'الدور';

  @override
  String get pinCode => 'رمز PIN (اختياري)';

  @override
  String get shiftManagement => 'إدارة الورديات';

  @override
  String get openShift => 'فتح وردية';

  @override
  String get closeShift => 'إغلاق الوردية';

  @override
  String get payIn => 'إيداع';

  @override
  String get payOut => 'سحب';

  @override
  String get reason => 'السبب';

  @override
  String get startingCash => 'النقد الافتتاحي';

  @override
  String get endingCash => 'النقد الختامي (الفعلي)';

  @override
  String shiftId(String id) {
    return 'رقم الوردية: $id';
  }

  @override
  String started(String time) {
    return 'بدأت: $time';
  }

  @override
  String startingCashLabel(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return 'النقد الافتتاحي: $amountString';
  }

  @override
  String get open => 'فتح';

  @override
  String get deliveryManagement => 'إدارة التوصيل';

  @override
  String get noActiveDeliveryOrders => 'لا توجد طلبات توصيل نشطة';

  @override
  String orderNumber(String id) {
    return 'طلب #$id';
  }

  @override
  String addressLabel(String address) {
    return 'العنوان: $address';
  }

  @override
  String get noAddress => 'لا يوجد عنوان';

  @override
  String deliveryFeeLabel(double fee) {
    final intl.NumberFormat feeNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String feeString = feeNumberFormat.format(fee);

    return 'رسوم التوصيل: $feeString';
  }

  @override
  String providerLabel(String provider, String refId) {
    return 'المزود: $provider (مرجع: $refId)';
  }

  @override
  String itemsCount(int count) {
    return 'العناصر: $count';
  }

  @override
  String totalLabel(double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'الإجمالي: $totalString';
  }

  @override
  String get externalDelivery => 'توصيل خارجي';

  @override
  String get driverAssigned => 'تم تعيين سائق';

  @override
  String get uberEats => 'أوبر إيتس';

  @override
  String get assignDriver => 'تعيين سائق';

  @override
  String get noDriversFound =>
      'لم يتم العثور على سائقين. أضف مستخدماً بصلاحية سائق.';

  @override
  String get assign => 'تعيين';

  @override
  String get cannotSyncNotLoggedIn => 'لا يمكن المزامنة: غير مسجل الدخول';

  @override
  String usePoints(int points, int available) {
    return 'استخدام $points نقطة (متاح: $available)';
  }

  @override
  String editItem(String name) {
    return 'تعديل $name';
  }

  @override
  String get startDelivery => 'بدء التوصيل';

  @override
  String get markAsDelivered => 'تحديد كموصل';

  @override
  String get completed => 'مكتمل';

  @override
  String customerLabel(String name) {
    return 'العميل: $name';
  }

  @override
  String get noAssignedDeliveries => 'لا توجد طلبات توصيل معينة.';

  @override
  String get pendingRefunds => 'استرجاعات معلقة';

  @override
  String get noPendingRefunds => 'لا توجد استرجاعات معلقة';

  @override
  String refundLabel(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String amountString = amountNumberFormat.format(amount);

    return 'استرجاع $amountString';
  }

  @override
  String reasonLabel(String reason) {
    return 'السبب: $reason';
  }

  @override
  String dateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get reject => 'رفض';

  @override
  String get approve => 'موافقة';

  @override
  String get refundApproved => 'تمت الموافقة على الاسترجاع';

  @override
  String get refundRejected => 'تم رفض الاسترجاع';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get date => 'التاريخ';

  @override
  String get table => 'طاولة';

  @override
  String get itemsTitle => 'العناصر';

  @override
  String get refundsTitle => 'الاسترجاعات';

  @override
  String get requestRefund => 'طلب استرجاع';

  @override
  String get voidOrder => 'إلغاء الطلب';

  @override
  String get returnStock => 'إرجاع للمخزون';

  @override
  String get refundRequested => 'تم طلب الاسترجاع';

  @override
  String get orderVoided => 'تم إلغاء الطلب';

  @override
  String get submit => 'إرسال';

  @override
  String get voidAction => 'إلغاء';

  @override
  String get noSuppliersFound => 'لم يتم العثور على موردين';

  @override
  String get noContactInfo => 'لا توجد معلومات اتصال';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get noIngredientsFound => 'لم يتم العثور على مكونات';

  @override
  String get addIngredient => 'إضافة مكون';

  @override
  String get editIngredient => 'تعديل مكون';

  @override
  String get unitLabel => 'الوحدة (مثل كجم، لتر)';

  @override
  String adjustStockTitle(String name) {
    return 'تعديل المخزون: $name';
  }

  @override
  String currentTotal(double total, String unit) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'المجموع الحالي: $totalString $unit';
  }

  @override
  String get adjustmentAmount => 'كمية التعديل (+/-)';

  @override
  String get notesDescription => 'ملاحظات / وصف';

  @override
  String get mandatoryForWaste => 'إلزامي للهدر/التلف';

  @override
  String get noWarehousesFound => 'لم يتم العثور على مستودعات';

  @override
  String get warehouse => 'المستودع';

  @override
  String get mainWarehouse => 'الرئيسي';

  @override
  String errorLoadingWarehouses(String error) {
    return 'خطأ في تحميل المستودعات: $error';
  }

  @override
  String get invalidAmount => 'كمية غير صالحة';

  @override
  String get descriptionRequired => 'الوصف مطلوب للهدر/التلف';

  @override
  String get adjust => 'تعديل';

  @override
  String get noPurchaseOrders => 'لا توجد أوامر شراء';

  @override
  String poNumber(String id, String supplier) {
    return 'طلب شراء #$id - $supplier';
  }

  @override
  String poStatusTotal(String status, double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'الحالة: $status\nالمجموع: $totalString';
  }

  @override
  String get createPO => 'إنشاء طلب شراء';

  @override
  String get noSuppliersAvailable =>
      'لا يوجد موردين متاحين. قم بإنشاء واحد أولاً.';

  @override
  String get selectSupplier => 'اختر المورد';

  @override
  String poDetails(String status) {
    return 'تفاصيل الطلب - $status';
  }

  @override
  String get receiveOrder => 'استلام الطلب (تحديث المخزون)';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get noIngredientsAvailable => 'لا توجد مكونات. قم بإنشاء واحدة أولاً.';

  @override
  String get selectIngredient => 'اختر المكون';

  @override
  String get quantity => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get ingredientLogs => 'سجلات المكون';

  @override
  String get inventoryLogs => 'سجلات المخزون';

  @override
  String get noLogsFound => 'لم يتم العثور على سجلات مخزون';

  @override
  String get unknownIngredient => 'مكون غير معروف';

  @override
  String warehouseLabel(String name) {
    return 'المستودع: $name';
  }

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get welcome => 'مرحباً';

  @override
  String get items => 'عناصر';

  @override
  String get total => 'الإجمالي';

  @override
  String get checkout => 'دفع';

  @override
  String get addToCart => 'إضافة للسلة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get search => 'بحث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'تم بنجاح';

  @override
  String get noModifiersFound => 'لم يتم العثور على إضافات في المنتجات.';

  @override
  String recipeTitle(String name) {
    return 'الوصفة: $name';
  }

  @override
  String get noIngredientsInRecipe => 'لا توجد مكونات في هذه الوصفة';

  @override
  String get quantityPerItem => 'الكمية لكل عنصر';

  @override
  String get noIngredientsAvailableSimple => 'لا توجد مكونات متاحة.';

  @override
  String itemPriceQuantity(int quantity, double price) {
    final intl.NumberFormat priceNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String priceString = priceNumberFormat.format(price);

    return '$quantity × $priceString';
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
    return 'تم إطلاق $course!';
  }

  @override
  String tableOrderTitle(String number) {
    return 'طلب طاولة $number';
  }

  @override
  String get noActiveOrderFound => 'لا يوجد طلب نشط';

  @override
  String get fire => 'إطلاق';

  @override
  String quantityCount(int count) {
    return '×$count';
  }

  @override
  String selectAtLeast(int count, String name) {
    return 'يرجى اختيار $count خيار(ات) على الأقل لـ $name';
  }

  @override
  String get selectOne => 'اختر 1';

  @override
  String selectUpTo(int count) {
    return 'اختر حتى $count';
  }

  @override
  String get specialInstructions => 'تعليمات خاصة...';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String addToCartTotal(double total) {
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.currency(
        locale: localeName, symbol: '\$', decimalDigits: 2);
    final String totalString = totalNumberFormat.format(total);

    return 'أضف للسلة - $totalString';
  }
}

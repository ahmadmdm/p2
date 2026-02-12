import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer_web/main.dart';

void main() {
  testWidgets('renders landing screen when no token is provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('QR Dining Experience'), findsOneWidget);
  });
}

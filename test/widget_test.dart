import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_battery_sms_monitor/main.dart';

void main() {
  testWidgets('App should launch without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Battery & SMS Monitor'), findsOneWidget);
  });
}

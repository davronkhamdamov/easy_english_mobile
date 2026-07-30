import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/main.dart';


void main() {
  testWidgets('EasyIeltsApp renders showcase screen cleanly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EasyIeltsApp());
    await tester.pumpAndSettle();

    // Verify that Design System Spec and Component Investigation Hub exist
    expect(find.text('Design System Spec'), findsOneWidget);
    expect(find.text('Component Investigation Hub'), findsOneWidget);
  });
}

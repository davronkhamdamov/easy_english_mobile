import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/main.dart';


void main() {
  testWidgets('EasyIeltsApp renders login screen as default home screen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyIeltsApp());
    await tester.pump();
    await tester.pump();

    // Verify that LoginScreen header and social buttons exist
    expect(find.text('Better sound. Better focus.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}

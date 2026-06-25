import 'package:flutter_test/flutter_test.dart';
import 'package:stdy4u/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const Stdy4uApp());
    await tester.pumpAndSettle();
    expect(find.text('stdy4u'), findsOneWidget);
  });
}

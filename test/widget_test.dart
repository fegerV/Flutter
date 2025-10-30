import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ar_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterArApp());
    
    expect(find.text('Flutter AR App'), findsOneWidget);
  });
}

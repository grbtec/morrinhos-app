import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/my_app.dart';

void main() {
  testWidgets('Pump my app', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
  });
}

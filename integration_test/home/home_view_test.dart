import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/main.dart' as app;
import 'package:mobile/mock/mock_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_view_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  final client = MockClient();

  DefaultHttpClientProvider.instance =
      Provider((ref) => client);

  mock(client);

  final mockObserver = MockNavigatorObserver();

  group("end-to-end", () {
    testWidgets(
       '''
      Renders the Home View screen,
      find View Widgets using Key,
      find the Special Widget using the Key,
      click on the Special Widget and wait for it to remain on the screen,
      one by one, click on each View Widget and click the back button.
      ''',
      (WidgetTester tester) async {
        app.main(navigatorObservers: [mockObserver]);

        await tester.pumpAndSettle();

        final backButton = find.byTooltip('Back');


        final widgetView0 = find.byKey(const Key("0-widgetView"));
        final widgetView1 = find.byKey(const Key("1-widgetView"));
        final widgetSpecial2 = find.byKey(const Key("2-widgetSpecial"));
        final widgetView3 = find.byKey(const Key("3-widgetView"));


        await tester.tap(widgetSpecial2);

        await tester.pumpAndSettle();

        expect(widgetSpecial2, findsOneWidget);

        await tester.tap(widgetView0);

        await tester.pumpAndSettle();

        await tester.tap(backButton);

        await tester.pumpAndSettle();

        await tester.tap(widgetView1);

        await tester.pumpAndSettle();

        await tester.tap(backButton);

        await tester.pumpAndSettle();

        await tester.tap(widgetView3);

        await tester.pumpAndSettle();

        await tester.tap(backButton);
      },
    );
  });
}
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:devtools_extensions/devtools_extensions.dart';

import 'package:komodo_flutter_dev_tools/src/app.dart';
import 'package:komodo_flutter_dev_tools/src/features/dashboard/view/home_view.dart';

void main() {
  testWidgets('renders DevTools extension shell', (tester) async {
    await tester.pumpWidget(
      const DevToolsExtension(child: KomodoDevToolsApp()),
    );

    expect(find.byType(KomodoDevToolsHomeView), findsOneWidget);
  });
}

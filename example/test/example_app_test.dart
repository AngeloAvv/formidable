import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/guides.dart';
import 'package:formidable_example/main.dart';

import 'support.dart';

void main() {
  testWidgets('the home page lists every guide', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const ExampleApp());

    for (final guide in guides) {
      expect(find.text(guide.title), findsOneWidget, reason: guide.title);
    }
    expect(
      guides.map((guide) => guide.title),
      containsAll([
        'Sign up',
        'Edit a contact',
        'Field Arrays',
        'Wizard',
        'Dynamic Form',
        'Widgets',
      ]),
    );
  });

  group('a guide opens Material and Cupertino side by side', () {
    for (final guide in guides) {
      testWidgets(guide.title, (tester) async {
        useTallSurface(tester, width: 1400);
        await tester.pumpWidget(const ExampleApp());

        await tester.tap(find.text(guide.title));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('material-pane')), findsOneWidget);
        expect(find.byKey(const Key('cupertino-pane')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('a narrow screen shows one design system at a time', (
    tester,
  ) async {
    useTallSurface(tester, width: 400);
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('material-pane')), findsOneWidget);
    expect(find.byKey(const Key('cupertino-pane')), findsNothing);

    await tester.tap(find.text('Cupertino'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('material-pane')), findsNothing);
    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
  });
}

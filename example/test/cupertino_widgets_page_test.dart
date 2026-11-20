import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/cupertino_widgets_page.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

void main() {
  // A tall surface, so that the whole list is built and on screen.
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: [
          FormidableLocalizations.delegate,
          ...GlobalCupertinoLocalizations.delegates,
        ],
        supportedLocales: FormidableLocalizations.supportedLocales,
        home: const CupertinoWidgetsPage(),
      ),
    );
  }

  testWidgets('shows every Cupertino widget', (tester) async {
    await pumpPage(tester);

    for (final type in <Type>[
      CupertinoTextField,
      CupertinoSwitch,
      CupertinoCheckbox,
      CupertinoSegmentedControl<String>,
      CupertinoSlidingSegmentedControl<String>,
      CupertinoRadio<String>,
      CupertinoSlider,
      CupertinoDatePicker,
      CupertinoTimerPicker,
    ]) {
      expect(find.byType(type), findsWidgets, reason: '$type');
    }
  });

  testWidgets('submitting an empty form asks to fix the errors', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(CupertinoButton, 'Save'));
    await tester.pump();

    expect(find.text('Please fix the errors above.'), findsOneWidget);
  });
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/widgets/widgets_cupertino.dart';

import 'support.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) =>
      pumpCupertino(tester, const WidgetsCupertinoPage());

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

  testWidgets('the name field shows a clear button once there is text', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.byKey(const Key('clear-name')), findsNothing);

    await tester.enterText(find.byType(CupertinoTextField).first, 'Angelo');
    await tester.pump();
    expect(find.byKey(const Key('clear-name')), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-name')));
    await tester.pump();

    expect(find.byKey(const Key('clear-name')), findsNothing);
    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField).first)
          .controller!
          .text,
      isEmpty,
    );
  });
}

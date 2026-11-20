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
}

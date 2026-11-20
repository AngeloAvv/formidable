import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/widgets/profile.dart';
import 'package:formidable_example/widgets/widgets_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) =>
      pumpMaterial(tester, const WidgetsMaterialPage());

  testWidgets('shows every Material widget', (tester) async {
    await pumpPage(tester);

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byType(RadioListTile<(Plan,)>), findsNWidgets(3));
    expect(find.byType(RadioListTile<(bool?,)>), findsNWidgets(3));
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(DropdownButton<(String,)>), findsOneWidget);
    expect(find.text('Birthday'), findsOneWidget);
    expect(find.text('Reminder'), findsOneWidget);
    expect(find.byType(SegmentedButton<(Layout,)>), findsOneWidget);
  });

  testWidgets('submitting an empty form asks to fix the errors', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Please fix the errors above.'), findsOneWidget);
  });

  testWidgets('a filled form is saved', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Pro'));
    await tester.tap(find.text('No preference'));
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.tap(find.byType(DropdownButton<(String,)>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italy').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grid'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
  });
}

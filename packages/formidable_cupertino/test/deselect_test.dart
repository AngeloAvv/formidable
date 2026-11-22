import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

/// Seam 2: deselecting is a choice. When the user cycles a tristate checkbox
/// to "mixed" and the type of the Field admits null, null is written as a
/// chosen value, so the Field is set and dirty. When it does not, null cannot
/// be written and the Field falls back to Unset (still touched).
void main() {
  Widget app(Widget child) => CupertinoApp(home: Center(child: child));

  group('FormidableCupertinoCheckbox with tristate', () {
    testWidgets('a nullable Field chooses null, which is dirty', (
      tester,
    ) async {
      final beta = FormidableField<bool?>();
      addTearDown(beta.dispose);
      await tester.pumpWidget(
        app(FormidableCupertinoCheckbox(field: beta, tristate: true)),
      );

      // Unset is shown as mixed: mixed -> false -> true -> mixed.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(CupertinoCheckbox));
        await tester.pump();
      }

      expect(beta.defined, isTrue);
      expect(beta.value, isNull);
      expect(beta.state.dirty, isTrue);
      expect(beta.state.touched, isTrue);
      expect(
        tester.widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox)).value,
        isNull,
      );
    });

    testWidgets('a nullable Field with an initial value is dirty too', (
      tester,
    ) async {
      final beta = FormidableField<bool?>(initial: (value: true));
      addTearDown(beta.dispose);
      await tester.pumpWidget(
        app(FormidableCupertinoCheckbox(field: beta, tristate: true)),
      );
      expect(beta.state.dirty, isFalse);

      await tester.tap(find.byType(CupertinoCheckbox)); // true -> mixed
      await tester.pump();

      expect(beta.defined, isTrue);
      expect(beta.value, isNull);
      expect(beta.state.dirty, isTrue);
    });

    testWidgets('a non-nullable Field falls back to Unset, touched', (
      tester,
    ) async {
      final beta = FormidableField<bool>();
      addTearDown(beta.dispose);
      await tester.pumpWidget(
        app(FormidableCupertinoCheckbox(field: beta, tristate: true)),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(CupertinoCheckbox));
        await tester.pump();
      }

      expect(beta.defined, isFalse);
      expect(beta.state.touched, isTrue);
    });
  });
}

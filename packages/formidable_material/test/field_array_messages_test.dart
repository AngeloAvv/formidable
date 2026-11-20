import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: the text of the item-count errors of a Field Array, in every
/// language, as the widget tree resolves it.
void main() {
  const min = FormidableMinItemsError(min: 2, actual: 1);
  const max = FormidableMaxItemsError(max: 3, actual: 4);
  const maxOne = FormidableMaxItemsError(max: 1, actual: 2);
  const minOne = FormidableMinItemsError(min: 1, actual: 0);

  const expected = {
    'en': [
      'Must have at least 2 items (got 1).',
      'Must have at most 3 items (got 4).',
      'Must have at least 1 item (got 0).',
      'Must have at most 1 item (got 2).',
    ],
    'it': [
      'Deve avere almeno 2 elementi (ne ha 1).',
      'Deve avere al massimo 3 elementi (ne ha 4).',
      'Deve avere almeno 1 elemento (ne ha 0).',
      'Deve avere al massimo 1 elemento (ne ha 2).',
    ],
    'es': [
      'Debe tener al menos 2 elementos (tiene 1).',
      'Debe tener como máximo 3 elementos (tiene 4).',
      'Debe tener al menos 1 elemento (tiene 0).',
      'Debe tener como máximo 1 elemento (tiene 2).',
    ],
    'fr': [
      'Doit contenir au moins 2 éléments (actuellement 1).',
      'Doit contenir au plus 3 éléments (actuellement 4).',
      'Doit contenir au moins 1 élément (actuellement 0).',
      'Doit contenir au plus 1 élément (actuellement 2).',
    ],
    'de': [
      'Muss mindestens 2 Einträge haben (aktuell 1).',
      'Muss höchstens 3 Einträge haben (aktuell 4).',
      'Muss mindestens 1 Eintrag haben (aktuell 0).',
      'Muss höchstens 1 Eintrag haben (aktuell 2).',
    ],
  };

  for (final entry in expected.entries) {
    testWidgets('says the item-count errors in ${entry.key}', (tester) async {
      late List<String> texts;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(entry.key),
          supportedLocales: FormidableLocalizations.supportedLocales,
          localizationsDelegates: [
            FormidableLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Builder(
            builder: (context) {
              texts = [
                for (final error in [min, max, minOne, maxOne])
                  formidableMessageOf(context, error),
              ];
              return const SizedBox();
            },
          ),
        ),
      );

      expect(texts, entry.value);
    });
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: the text of the error a failed Async Validator leaves on a Field.
void main() {
  const expected = {
    'en': 'The value could not be checked. Try again.',
    'it': 'Non è stato possibile verificare il valore. Riprova.',
    'es': 'No se pudo comprobar el valor. Inténtalo de nuevo.',
    'fr': "La valeur n'a pas pu être vérifiée. Réessayez.",
    'de': 'Der Wert konnte nicht geprüft werden. Versuchen Sie es erneut.',
  };

  for (final entry in expected.entries) {
    testWidgets('says the failed check in ${entry.key}', (tester) async {
      final field = FormidableField<String>(initial: (value: 'alice'))
        ..applyErrors([FormidableAsyncCheckFailedError(StateError('offline'))])
        ..markAsTouched();
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(entry.key),
          supportedLocales: FormidableLocalizations.supportedLocales,
          localizationsDelegates: [
            FormidableLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: FormidableMaterialTextField<String>(field: field),
          ),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
    });
  }
}

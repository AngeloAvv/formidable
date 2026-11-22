import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/password_change.dart';
import 'support/password_change.formidable_scope.dart';

/// Seam 2: the five languages of the cross-field errors, and one error shown
/// through a widget.
void main() {
  const locales = ['en', 'it', 'es', 'fr', 'de'];

  FormidableLocalizations localizations(String code) => switch (code) {
    'it' => const FormidableLocalizationsIt(),
    'es' => const FormidableLocalizationsEs(),
    'fr' => const FormidableLocalizationsFr(),
    'de' => const FormidableLocalizationsDe(),
    _ => const FormidableLocalizationsEn(),
  };

  const errors = <FormidableValidationError>[
    FormidableMustMatchError(),
    FormidableDifferentError(),
    FormidableCompareError(FormidableComparison.equalTo),
    FormidableCompareError(FormidableComparison.notEqualTo),
    FormidableCompareError(FormidableComparison.lessThan),
    FormidableCompareError(FormidableComparison.lessThanOrEqualTo),
    FormidableCompareError(FormidableComparison.greaterThan),
    FormidableCompareError(FormidableComparison.greaterThanOrEqualTo),
    FormidableDateRangeOrderError(allowSame: true),
    FormidableDateRangeOrderError(allowSame: false),
    FormidableRequiredIfError(),
    FormidableRequiredUnlessError(),
    FormidableRequiredWithError(),
    FormidableRequiredWithAllError(),
    FormidableRequiredWithoutError(),
    FormidableRequiredWithoutAllError(),
    FormidableRequiredIfAcceptedError(),
    FormidableRequiredIfDeclinedError(),
    FormidableProhibitedIfError(),
    FormidableProhibitedUnlessError(),
    FormidableProhibitsError(),
    FormidableAcceptedIfError(),
    FormidableDeclinedIfError(),
    FormidableAtLeastOneOfError(),
    FormidableExactlyOneOfError(),
    FormidableAtMostOneOfError(),
    FormidableInListError(),
    FormidableUniqueByError(),
  ];

  for (final locale in locales) {
    test('every cross-field error has a message in $locale', () {
      final messages = localizations(locale);
      for (final error in errors) {
        final message = messages.messageOf(error);
        expect(message, isNotNull, reason: '$error');
        expect(message, isNotEmpty, reason: '$error');
      }
    });
  }

  test('the English messages are the last-resort messages of the errors', () {
    final english = localizations('en');
    for (final error in errors) {
      expect(english.messageOf(error), error.toString(), reason: '$error');
    }
  });

  test('the languages say different things', () {
    for (final error in errors) {
      final texts = {
        for (final l in locales) localizations(l).messageOf(error),
      };
      expect(texts.length, greaterThan(1), reason: '$error');
    }
  });

  const mustMatch = {
    'en': 'The values do not match.',
    'it': 'I valori non coincidono.',
    'es': 'Los valores no coinciden.',
    'fr': 'Les valeurs ne correspondent pas.',
    'de': 'Die Werte stimmen nicht überein.',
  };
  for (final entry in mustMatch.entries) {
    testWidgets('shows the must-match error in ${entry.key}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(entry.key),
          supportedLocales: FormidableLocalizations.supportedLocales,
          localizationsDelegates: [
            FormidableLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: PasswordChangeFormScope(
              create: () =>
                  PasswordChangeForm(password: 'a', confirmation: 'b')
                    ..confirmation.touch(),
              child: Builder(
                builder: (context) => FormidableMaterialTextField(
                  field: context.passwordChangeForm.confirmation,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
    });
  }
}

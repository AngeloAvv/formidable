import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/account.dart';
import 'support/account.formidable_scope.dart';
import 'support/contact.dart';
import 'support/contact.formidable_scope.dart';
import 'support/sign_up.dart';
import 'support/sign_up.formidable_scope.dart';

/// Seam 2: the text a user reads for a Validation Error, in every step of the
/// lookup (widget override, config registry, localizations, string form), and
/// how that text reacts to locale and config changes.
void main() {
  Widget app({
    Locale locale = const Locale('en'),
    LocalizationsDelegate<FormidableLocalizations>? delegate =
        FormidableLocalizations.delegate,
    FormidableMessages? config,
    required Widget child,
  }) {
    final home = MaterialApp(
      locale: locale,
      supportedLocales: FormidableLocalizations.supportedLocales,
      localizationsDelegates: [
        ?delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(body: child),
    );
    return config == null
        ? home
        : FormidableConfig(messages: config, child: home);
  }

  /// A sign-up page whose Field is touched, so that its error is visible.
  Widget signUp({FormidableMessages? messages}) => SignUpFormScope(
    create: () => SignUpForm()..username.markAsTouched(),
    child: Builder(
      builder: (context) => FormidableTextField(
        field: context.signUpForm.username,
        messages: messages,
      ),
    ),
  );

  Widget account({FormidableMessages? messages}) => AccountFormScope(
    create: () => AccountForm(username: 'admin')..username.markAsTouched(),
    child: Builder(
      builder: (context) => FormidableTextField(
        field: context.accountForm.username,
        messages: messages,
      ),
    ),
  );

  group('localizations delegate', () {
    const required = {
      'en': 'This field is required.',
      'it': 'Questo campo è obbligatorio.',
      'es': 'Este campo es obligatorio.',
      'fr': 'Ce champ est obligatoire.',
      'de': 'Dieses Feld ist erforderlich.',
    };

    for (final entry in required.entries) {
      testWidgets('says the required error in ${entry.key}', (tester) async {
        await tester.pumpWidget(
          app(locale: Locale(entry.key), child: signUp()),
        );

        expect(find.text(entry.value), findsOneWidget);
      });
    }

    const minLength = {
      'en': 'Must be at least 4 characters long (got 2).',
      'it': 'Deve contenere almeno 4 caratteri (ne ha 2).',
      'es': 'Debe tener al menos 4 caracteres (tiene 2).',
      'fr': 'Doit contenir au moins 4 caractères (actuellement 2).',
      'de': 'Muss mindestens 4 Zeichen lang sein (aktuell 2).',
    };

    for (final entry in minLength.entries) {
      testWidgets('says the min length error in ${entry.key}', (tester) async {
        await tester.pumpWidget(
          app(
            locale: Locale(entry.key),
            child: SignUpFormScope(
              create: () =>
                  SignUpForm(username: 'ab')..username.markAsTouched(),
              child: Builder(
                builder: (context) =>
                    FormidableTextField(field: context.signUpForm.username),
              ),
            ),
          ),
        );

        expect(find.text(entry.value), findsOneWidget);
      });
    }

    testWidgets('rebuilds the error text when the locale changes', (
      tester,
    ) async {
      final page = signUp();
      await tester.pumpWidget(app(locale: const Locale('en'), child: page));
      expect(find.text('This field is required.'), findsOneWidget);

      await tester.pumpWidget(app(locale: const Locale('it'), child: page));
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsNothing);
      expect(find.text('Questo campo è obbligatorio.'), findsOneWidget);
    });

    testWidgets('can be extended to override the wording', (tester) async {
      await tester.pumpWidget(
        app(
          delegate: const _ShoutingDelegate(),
          locale: const Locale('it'),
          child: signUp(),
        ),
      );

      expect(find.text('QUESTO CAMPO È OBBLIGATORIO!'), findsOneWidget);
    });

    testWidgets('falls back to the string form without the delegate', (
      tester,
    ) async {
      await tester.pumpWidget(app(delegate: null, child: signUp()));

      expect(find.text('This field is required.'), findsOneWidget);
    });
  });

  group('config registry', () {
    testWidgets('overrides the localizations for a built-in error', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'Fill me in',
          ),
          child: signUp(),
        ),
      );

      expect(find.text('Fill me in'), findsOneWidget);
      expect(find.text('This field is required.'), findsNothing);
    });

    testWidgets('gives the message for a custom error type', (tester) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<NotAdminError>(
            (context, error) => 'admin is reserved',
          ),
          child: account(),
        ),
      );

      expect(find.text('admin is reserved'), findsOneWidget);
    });

    testWidgets('hands the data of the error to the message', (tester) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableMinLengthError>(
            (context, error) =>
                'need ${error.minLength - error.actualLength} more',
          ),
          child: SignUpFormScope(
            create: () => SignUpForm(username: 'ab')..username.markAsTouched(),
            child: Builder(
              builder: (context) =>
                  FormidableTextField(field: context.signUpForm.username),
            ),
          ),
        ),
      );

      expect(find.text('need 2 more'), findsOneWidget);
    });

    testWidgets('lets other errors fall through to the localizations', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          locale: const Locale('it'),
          config: const FormidableMessages().on<NotAdminError>(
            (context, error) => 'unused',
          ),
          child: signUp(),
        ),
      );

      expect(find.text('Questo campo è obbligatorio.'), findsOneWidget);
    });

    testWidgets('lets the message read the context', (tester) async {
      await tester.pumpWidget(
        app(
          locale: const Locale('fr'),
          config: const FormidableMessages().on<NotAdminError>(
            (context, error) =>
                'locale: ${Localizations.localeOf(context).languageCode}',
          ),
          child: account(),
        ),
      );

      expect(find.text('locale: fr'), findsOneWidget);
    });

    testWidgets('rebuilds the error text when the config changes', (
      tester,
    ) async {
      final page = signUp();
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'first',
          ),
          child: page,
        ),
      );
      expect(find.text('first'), findsOneWidget);

      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'second',
          ),
          child: page,
        ),
      );

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('the last registration for a type wins', (tester) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages()
              .on<FormidableRequiredError>((context, error) => 'old')
              .on<FormidableRequiredError>((context, error) => 'new'),
          child: signUp(),
        ),
      );

      expect(find.text('new'), findsOneWidget);
    });
  });

  group('widget override', () {
    testWidgets('wins over the config registry', (tester) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'from config',
          ),
          child: signUp(
            messages: const FormidableMessages().on<FormidableRequiredError>(
              (context, error) => 'from widget',
            ),
          ),
        ),
      );

      expect(find.text('from widget'), findsOneWidget);
      expect(find.text('from config'), findsNothing);
    });

    testWidgets('only covers the types it registers', (tester) async {
      await tester.pumpWidget(
        app(
          config: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'from config',
          ),
          child: signUp(
            messages: const FormidableMessages().on<NotAdminError>(
              (context, error) => 'unused',
            ),
          ),
        ),
      );

      expect(find.text('from config'), findsOneWidget);
    });

    testWidgets('wins over the localizations without any config', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          child: signUp(
            messages: const FormidableMessages().on<FormidableRequiredError>(
              (context, error) => 'one-off',
            ),
          ),
        ),
      );

      expect(find.text('one-off'), findsOneWidget);
    });
  });

  group('AnyOf error', () {
    const anyOf = {
      'en': 'Does not satisfy any of the allowed rules.',
      'it': 'Non soddisfa nessuna delle regole consentite.',
      'es': 'No cumple ninguna de las reglas permitidas.',
      'fr': 'Ne satisfait aucune des règles autorisées.',
      'de': 'Erfüllt keine der erlaubten Regeln.',
    };

    for (final entry in anyOf.entries) {
      testWidgets('is said in ${entry.key}', (tester) async {
        await tester.pumpWidget(
          app(
            locale: Locale(entry.key),
            child: ContactFormScope(
              create: () =>
                  ContactForm(reference: 'ab')..reference.markAsTouched(),
              child: Builder(
                builder: (context) =>
                    FormidableTextField(field: context.contactForm.reference),
              ),
            ),
          ),
        );

        expect(find.text(entry.value), findsOneWidget);
      });
    }
  });
}

/// An app-level override: the Italian wording shouts.
class _ShoutingDelegate extends FormidableLocalizationsDelegate {
  const _ShoutingDelegate();

  @override
  FormidableLocalizations lookup(Locale locale) =>
      locale.languageCode == 'it' ? _ShoutingItalian() : super.lookup(locale);
}

class _ShoutingItalian extends FormidableLocalizationsIt {
  @override
  String requiredField() => 'QUESTO CAMPO È OBBLIGATORIO!';
}

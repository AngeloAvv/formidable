import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'categories/combinators.dart';
import 'categories/presence.dart';
import 'categories/strings.dart';

/// The Validation Messages of the built-in Validation Errors, in one language.
///
/// Install [FormidableLocalizations.delegate] in the app, next to the other
/// localizations delegates. To change the wording, extend the class of a
/// language, override the methods you want and return it from a
/// [FormidableLocalizationsDelegate] subclass.
///
/// Every category of built-in errors is a mixin with one method per error.
/// The class stays abstract on purpose: a language that misses a message does
/// not compile.
abstract class FormidableLocalizations
    with
        FormidableCombinatorMessages,
        FormidablePresenceMessages,
        FormidableStringMessages {
  const FormidableLocalizations();

  /// The delegate that loads the built-in languages.
  static const FormidableLocalizationsDelegate delegate =
      FormidableLocalizationsDelegate();

  /// English, Italian, Spanish, French and German.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
  ];

  /// The localizations of the nearest [Localizations], or null when the delegate
  /// is not installed.
  static FormidableLocalizations? maybeOf(BuildContext context) =>
      Localizations.of<FormidableLocalizations>(
        context,
        FormidableLocalizations,
      );

  /// Like [maybeOf], but throws when the delegate is not installed.
  static FormidableLocalizations of(BuildContext context) {
    final localizations = maybeOf(context);
    if (localizations == null) {
      throw FlutterError(
        'No FormidableLocalizations found in the widget tree.\n'
        'Add FormidableLocalizations.delegate to localizationsDelegates.',
      );
    }
    return localizations;
  }

  /// The message for [error], or null when this class has no message for it.
  String? messageOf(FormidableValidationError error) =>
      presenceMessageOf(error) ??
      stringMessageOf(error) ??
      combinatorMessageOf(error);
}

/// English.
class FormidableLocalizationsEn extends FormidableLocalizations
    with
        FormidableCombinatorMessagesEn,
        FormidablePresenceMessagesEn,
        FormidableStringMessagesEn {
  const FormidableLocalizationsEn();
}

/// Italian.
class FormidableLocalizationsIt extends FormidableLocalizations
    with
        FormidableCombinatorMessagesIt,
        FormidablePresenceMessagesIt,
        FormidableStringMessagesIt {
  const FormidableLocalizationsIt();
}

/// Spanish.
class FormidableLocalizationsEs extends FormidableLocalizations
    with
        FormidableCombinatorMessagesEs,
        FormidablePresenceMessagesEs,
        FormidableStringMessagesEs {
  const FormidableLocalizationsEs();
}

/// French.
class FormidableLocalizationsFr extends FormidableLocalizations
    with
        FormidableCombinatorMessagesFr,
        FormidablePresenceMessagesFr,
        FormidableStringMessagesFr {
  const FormidableLocalizationsFr();
}

/// German.
class FormidableLocalizationsDe extends FormidableLocalizations
    with
        FormidableCombinatorMessagesDe,
        FormidablePresenceMessagesDe,
        FormidableStringMessagesDe {
  const FormidableLocalizationsDe();
}

/// Loads [FormidableLocalizations] for the locale of the app.
///
/// Extend it and override [lookup] to replace the wording of one or more
/// languages, and fall back to `super.lookup` for the others.
class FormidableLocalizationsDelegate
    extends LocalizationsDelegate<FormidableLocalizations> {
  const FormidableLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => FormidableLocalizations.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  /// The localizations for [locale], which is always a supported one.
  FormidableLocalizations lookup(Locale locale) =>
      switch (locale.languageCode) {
        'it' => const FormidableLocalizationsIt(),
        'es' => const FormidableLocalizationsEs(),
        'fr' => const FormidableLocalizationsFr(),
        'de' => const FormidableLocalizationsDe(),
        _ => const FormidableLocalizationsEn(),
      };

  @override
  Future<FormidableLocalizations> load(Locale locale) =>
      SynchronousFuture(lookup(locale));

  @override
  bool shouldReload(FormidableLocalizationsDelegate old) => false;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'categories/asynchronous.dart';
import 'categories/choices.dart';
import 'categories/collections.dart';
import 'categories/combinators.dart';
import 'categories/cross_field.dart';
import 'categories/dates.dart';
import 'categories/files.dart';
import 'categories/finance.dart';
import 'categories/formats.dart';
import 'categories/locale.dart';
import 'categories/network.dart';
import 'categories/numbers.dart';
import 'categories/parsing.dart';
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
        FormidableAsyncMessages,
        FormidableChoiceMessages,
        FormidableCollectionMessages,
        FormidableCombinatorMessages,
        FormidableCrossFieldMessages,
        FormidableDateMessages,
        FormidableFileMessages,
        FormidableFinanceMessages,
        FormidableFormatMessages,
        FormidableLocaleMessages,
        FormidableNetworkMessages,
        FormidableNumberMessages,
        FormidableParsingMessages,
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
      formatMessageOf(error) ??
      combinatorMessageOf(error) ??
      crossFieldMessageOf(error) ??
      collectionMessageOf(error) ??
      fileMessageOf(error) ??
      networkMessageOf(error) ??
      financeMessageOf(error) ??
      localeMessageOf(error) ??
      parsingMessageOf(error) ??
      asyncMessageOf(error) ??
      numberMessageOf(error) ??
      dateMessageOf(error) ??
      choiceMessageOf(error);
}

/// English.
class FormidableLocalizationsEn extends FormidableLocalizations
    with
        FormidableAsyncMessagesEn,
        FormidableChoiceMessagesEn,
        FormidableCollectionMessagesEn,
        FormidableCombinatorMessagesEn,
        FormidableCrossFieldMessagesEn,
        FormidableDateMessagesEn,
        FormidableFileMessagesEn,
        FormidableFinanceMessagesEn,
        FormidableFormatMessagesEn,
        FormidableLocaleMessagesEn,
        FormidableNetworkMessagesEn,
        FormidableNumberMessagesEn,
        FormidableParsingMessagesEn,
        FormidablePresenceMessagesEn,
        FormidableStringMessagesEn {
  const FormidableLocalizationsEn();
}

/// Italian.
class FormidableLocalizationsIt extends FormidableLocalizations
    with
        FormidableAsyncMessagesIt,
        FormidableChoiceMessagesIt,
        FormidableCollectionMessagesIt,
        FormidableCombinatorMessagesIt,
        FormidableCrossFieldMessagesIt,
        FormidableDateMessagesIt,
        FormidableFileMessagesIt,
        FormidableFinanceMessagesIt,
        FormidableFormatMessagesIt,
        FormidableLocaleMessagesIt,
        FormidableNetworkMessagesIt,
        FormidableNumberMessagesIt,
        FormidableParsingMessagesIt,
        FormidablePresenceMessagesIt,
        FormidableStringMessagesIt {
  const FormidableLocalizationsIt();
}

/// Spanish.
class FormidableLocalizationsEs extends FormidableLocalizations
    with
        FormidableAsyncMessagesEs,
        FormidableChoiceMessagesEs,
        FormidableCollectionMessagesEs,
        FormidableCombinatorMessagesEs,
        FormidableCrossFieldMessagesEs,
        FormidableDateMessagesEs,
        FormidableFileMessagesEs,
        FormidableFinanceMessagesEs,
        FormidableFormatMessagesEs,
        FormidableLocaleMessagesEs,
        FormidableNetworkMessagesEs,
        FormidableNumberMessagesEs,
        FormidableParsingMessagesEs,
        FormidablePresenceMessagesEs,
        FormidableStringMessagesEs {
  const FormidableLocalizationsEs();
}

/// French.
class FormidableLocalizationsFr extends FormidableLocalizations
    with
        FormidableAsyncMessagesFr,
        FormidableChoiceMessagesFr,
        FormidableCollectionMessagesFr,
        FormidableCombinatorMessagesFr,
        FormidableCrossFieldMessagesFr,
        FormidableDateMessagesFr,
        FormidableFileMessagesFr,
        FormidableFinanceMessagesFr,
        FormidableFormatMessagesFr,
        FormidableLocaleMessagesFr,
        FormidableNetworkMessagesFr,
        FormidableNumberMessagesFr,
        FormidableParsingMessagesFr,
        FormidablePresenceMessagesFr,
        FormidableStringMessagesFr {
  const FormidableLocalizationsFr();
}

/// German.
class FormidableLocalizationsDe extends FormidableLocalizations
    with
        FormidableAsyncMessagesDe,
        FormidableChoiceMessagesDe,
        FormidableCollectionMessagesDe,
        FormidableCombinatorMessagesDe,
        FormidableCrossFieldMessagesDe,
        FormidableDateMessagesDe,
        FormidableFileMessagesDe,
        FormidableFinanceMessagesDe,
        FormidableFormatMessagesDe,
        FormidableLocaleMessagesDe,
        FormidableNetworkMessagesDe,
        FormidableNumberMessagesDe,
        FormidableParsingMessagesDe,
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

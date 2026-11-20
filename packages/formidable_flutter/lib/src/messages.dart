import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'config.dart';
import 'localizations/localizations.dart';

/// Builds the Validation Message for an error of type [E].
///
/// The [context] is the one of the widget that shows the message, so it can
/// read the locale, the theme or an application localizations class.
typedef FormidableMessageBuilder<E extends FormidableValidationError> =
    String Function(BuildContext context, E error);

/// A typed registry of Validation Messages.
///
/// It is used twice with the same shape: in [FormidableConfig] for the whole
/// app, and on a single widget to override one message.
///
/// ```dart
/// const FormidableMessages()
///     .on<FormidableMinLengthError>(
///       (context, error) => 'Use ${error.minLength} characters or more',
///     )
///     .on<NotAdminError>((context, error) => 'That name is reserved');
/// ```
///
/// A message is registered for the exact type of an error. Registering a
/// type again replaces the earlier message.
@immutable
final class FormidableMessages {
  const FormidableMessages() : _builders = const {};

  const FormidableMessages._(this._builders);

  final Map<Type, String Function(BuildContext, FormidableValidationError)>
  _builders;

  /// Returns a registry that also gives [message] for errors of type [E].
  FormidableMessages on<E extends FormidableValidationError>(
    FormidableMessageBuilder<E> message,
  ) => FormidableMessages._({
    ..._builders,
    E: (context, error) => message(context, error as E),
  });

  /// The message for [error], or null when its type is not registered.
  String? resolve(BuildContext context, FormidableValidationError error) =>
      _builders[error.runtimeType]?.call(context, error);
}

/// The text shown to the user for [error].
///
/// This is the single place where a Validation Error becomes a Validation
/// Message. The first step that has a message wins:
///
/// 1. [overrides], the registry of the widget;
/// 2. the registry of the nearest [FormidableConfig];
/// 3. the [FormidableLocalizations] of the nearest [Localizations];
/// 4. the string form of the error.
///
/// Calling it from a build method makes that widget rebuild when the locale or
/// the config changes.
String formidableMessageOf(
  BuildContext context,
  FormidableValidationError error, {
  FormidableMessages? overrides,
}) =>
    overrides?.resolve(context, error) ??
    FormidableConfig.maybeOf(context)?.messages.resolve(context, error) ??
    FormidableLocalizations.maybeOf(context)?.messageOf(error) ??
    error.toString();

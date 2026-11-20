import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

/// The text shown to the user for [error].
///
/// This is the single place where a Validation Error becomes a Validation
/// Message. For now it is the last step of the lookup, the error's string
/// form. The localizations delegate, the typed registry and widget overrides
/// are consulted here ahead of it, so that [context] can react to locale and
/// configuration changes.
String formidableMessageOf(
  BuildContext context,
  FormidableValidationError error,
) => error.toString();

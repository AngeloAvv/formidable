import 'package:material_ui/material_ui.dart';

import 'preferences.dart';
import 'preferences.formidable_scope.dart';

/// Mounts a generated Preferences Form Scope and hands the field widget the
/// Form. The Form is passed to [onCreated], so tests can drive it in code.
Widget preferencesApp(
  Widget Function(PreferencesForm form) field, {
  void Function(PreferencesForm form)? onCreated,
  PreferencesForm Function()? create,
}) => MaterialApp(
  home: Scaffold(
    body: PreferencesFormScope(
      create: () {
        final form = create?.call() ?? PreferencesForm();
        onCreated?.call(form);
        return form;
      },
      child: Builder(builder: (context) => field(context.preferencesForm)),
    ),
  ),
);

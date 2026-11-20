import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'form_widgets.dart';

/// Stops the user from leaving the screen while the Form has unsaved changes.
///
/// While the Form is dirty, a pop (the back button, the back gesture or
/// `Navigator.maybePop`) is blocked and [confirmLeave] is called. Show your
/// confirmation there and return true to leave anyway or false to stay. While
/// the Form is clean, the screen can be left without asking.
///
/// The Form comes from [form] or from the closest Form Scope of type [F].
/// After a successful save, call `form.commit()` so the Form is clean and the
/// screen can be left.
class FormidablePopScope<F extends FormidableForm<Object?>>
    extends StatelessWidget {
  const FormidablePopScope({
    super.key,
    this.form,
    required this.confirmLeave,
    required this.child,
  });

  final F? form;

  /// Asks the user whether to leave and lose the changes. Called only when a
  /// pop is blocked because the Form is dirty.
  final Future<bool> Function(BuildContext context) confirmLeave;

  final Widget child;

  @override
  Widget build(BuildContext context) => FormidableFormBuilder<F>(
    form: form,
    buildWhen: (previous, current) => previous.dirty != current.dirty,
    builder: (context, state) => PopScope<Object?>(
      canPop: !state.dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmLeave(context);
        if (leave && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: child,
    ),
  );
}

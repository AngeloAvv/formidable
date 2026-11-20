import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

/// The part of the widget tree where a Form is available.
///
/// This scope owns the Form: it creates it once and disposes it. Generated
/// scopes such as `SignUpFormScope` extend it with the concrete Form type.
class FormidableScope<F extends FormidableForm<Object?>>
    extends StatefulWidget {
  const FormidableScope({super.key, required this.create, required this.child});

  /// Creates the Form. Called once, when the scope is first inserted.
  final F Function() create;

  final Widget child;

  /// The Form of the closest scope of type [F] above [context].
  ///
  /// Throws a [FlutterError] that names the missing scope when there is none.
  static F of<F extends FormidableForm<Object?>>(BuildContext context) {
    final form = maybeOf<F>(context);
    if (form != null) return form;
    throw FlutterError.fromParts([
      ErrorSummary('No FormidableScope<$F> found in the widget tree.'),
      ErrorDescription(
        'The widget that asked for the Form is below no scope that provides '
        'a $F.',
      ),
      ErrorHint(
        'Wrap it in the generated Form Scope of that Form, for example '
        '"SignUpFormScope" for a Schema named "SignUp".',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Like [of], but returns null when there is no scope.
  static F? maybeOf<F extends FormidableForm<Object?>>(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_FormidableInherited<F>>()?.form;

  @override
  State<FormidableScope<F>> createState() => _FormidableScopeState<F>();
}

class _FormidableScopeState<F extends FormidableForm<Object?>>
    extends State<FormidableScope<F>> {
  late final F _form = widget.create();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _FormidableInherited<F>(form: _form, child: widget.child);
}

class _FormidableInherited<F extends FormidableForm<Object?>>
    extends InheritedWidget {
  const _FormidableInherited({required this.form, required super.child});

  final F form;

  // The Form never changes for the lifetime of the scope. Widgets that care
  // about its state listen to it instead of depending on this widget.
  @override
  bool updateShouldNotify(_FormidableInherited<F> oldWidget) => false;
}

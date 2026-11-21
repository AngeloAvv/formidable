import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'config.dart';
import 'error_display.dart';

/// The part of the widget tree where a Form is available.
///
/// The default constructor owns the Form: it creates it once and disposes it.
/// [FormidableScope.value] only exposes a Form that something else owns and
/// never disposes it. Generated scopes such as `SignUpFormScope` extend this
/// class with the concrete Form type.
///
/// Give the scope exactly one of [child] and [builder]. The [builder] receives
/// the Form and a context that is below the scope, so everything it builds can
/// use the Form right away, for example to bind Field widgets to its Fields.
class FormidableScope<F extends FormidableForm<Object?>>
    extends StatefulWidget {
  const FormidableScope({
    super.key,
    required this.create,
    this.errorDisplay,
    this.child,
    this.builder,
  }) : assert(
         (child == null) != (builder == null),
         'Give a FormidableScope exactly one of child and builder.',
       ),
       _form = null;

  /// Exposes [form], which is owned elsewhere. The scope never disposes it, so
  /// whoever created it must.
  const FormidableScope.value({
    super.key,
    required F this._form,
    this.errorDisplay,
    this.child,
    this.builder,
  }) : assert(
         (child == null) != (builder == null),
         'Give a FormidableScope exactly one of child and builder.',
       ),
       create = null;

  /// Creates the Form. Called once, when the scope is first inserted. Null for
  /// a scope made with [FormidableScope.value].
  final F Function()? create;

  final F? _form;

  /// When the errors of the Fields of this Form are shown. Null follows
  /// [FormidableConfig.errorDisplay].
  final FormidableErrorDisplay? errorDisplay;

  /// The widget below the scope. Null when [builder] is given.
  final Widget? child;

  /// Builds the widget below the scope from the Form. Its context is below
  /// the scope. Null when [child] is given.
  final Widget Function(BuildContext context, F form)? builder;

  /// The Form of the closest scope of type [F] above [context].
  ///
  /// Throws a [FlutterError] that names the missing scope when there is none.
  /// With [listen], the widget that asks is rebuilt if the scope starts
  /// exposing another Form; it is meant for `build` methods.
  static F of<F extends FormidableForm<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    final form = maybeOf<F>(context, listen: listen);
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
  static F? maybeOf<F extends FormidableForm<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) =>
      (listen
              ? context
                    .dependOnInheritedWidgetOfExactType<
                      _FormidableInherited<F>
                    >()
              : context
                    .getInheritedWidgetOfExactType<_FormidableInherited<F>>())
          ?.form;

  /// The policy that applies to widgets below [context]: the one of the
  /// closest scope that sets one, else the one of the config, else
  /// [FormidableErrorDisplay.touched]. Registers a dependency.
  static FormidableErrorDisplay errorDisplayOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_FormidableErrorDisplayScope>()
          ?.errorDisplay ??
      FormidableConfig.maybeOf(context)?.errorDisplay ??
      FormidableErrorDisplay.touched;

  @override
  State<FormidableScope<F>> createState() => _FormidableScopeState<F>();
}

class _FormidableScopeState<F extends FormidableForm<Object?>>
    extends State<FormidableScope<F>> {
  // An owning scope creates its Form once; a value scope follows its widget.
  late final F? _owned = widget._form == null ? widget.create!() : null;

  F get _form => _owned ?? widget._form!;

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormidableInherited<F>(
    form: _form,
    child: _FormidableErrorDisplayScope(
      errorDisplay: widget.errorDisplay,
      child:
          widget.child ??
          Builder(builder: (context) => widget.builder!(context, _form)),
    ),
  );
}

class _FormidableInherited<F extends FormidableForm<Object?>>
    extends InheritedWidget {
  const _FormidableInherited({required this.form, required super.child});

  final F form;

  // Only a `.value` scope can start exposing another Form. Widgets that care
  // about the state of a Form listen to it instead of depending on this widget.
  @override
  bool updateShouldNotify(_FormidableInherited<F> oldWidget) =>
      !identical(form, oldWidget.form);
}

class _FormidableErrorDisplayScope extends InheritedWidget {
  const _FormidableErrorDisplayScope({
    required this.errorDisplay,
    required super.child,
  });

  final FormidableErrorDisplay? errorDisplay;

  @override
  bool updateShouldNotify(_FormidableErrorDisplayScope oldWidget) =>
      errorDisplay != oldWidget.errorDisplay;
}

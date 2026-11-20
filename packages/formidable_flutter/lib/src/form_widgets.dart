import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'observable_widgets.dart';
import 'scope.dart';

/// Rebuilds [builder] with the state of a Form, starting with its current
/// state.
///
/// The state is complete: it holds the state of every Field, Nested Form and
/// Field Array below the Form, so the builder runs for every change of the
/// Form, a typed value included. Narrow it down with [buildWhen].
///
/// Pass [form] to use a specific Form. Without it, the widget looks up the
/// closest Form Scope of type [F] and throws an error naming the missing scope
/// when there is none.
///
/// [S] is the type of the state the builder receives: the generated state of
/// the Form (`SignUpFormState`). This is what the generated `SignUpFormBuilder`
/// extends, so use that one. [FormidableFormBuilder] is the same widget typed
/// as [FormidableFormState], for code that does not use the generator.
class FormidableTypedFormBuilder<
  F extends FormidableForm<Object?>,
  S extends FormidableFormState
>
    extends StatelessWidget {
  const FormidableTypedFormBuilder({
    super.key,
    this.form,
    required this.builder,
    this.buildWhen,
  });

  final F? form;

  /// Builds the widget for the current state.
  final Widget Function(BuildContext context, S state) builder;

  /// Decides, from the previous and the next state, whether to rebuild.
  /// Without it every state change rebuilds.
  final FormidableStateCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) => ObservableBuilder<S>(
    observable: _FormStates<F, S>(
      form ?? FormidableScope.of<F>(context, listen: true),
    ),
    builder: builder,
    buildWhen: buildWhen,
  );
}

/// Calls [listener] each time the state of a Form changes, never for the
/// state present when it is built. The Form comes from [form] or from the
/// closest Form Scope of type [F], and [S] is the state type, as in
/// [FormidableTypedFormBuilder].
///
/// [listenWhen] receives the previous and the next state and decides whether
/// to call the listener. Without it every state change calls it.
class FormidableTypedFormListener<
  F extends FormidableForm<Object?>,
  S extends FormidableFormState
>
    extends StatelessWidget {
  const FormidableTypedFormListener({
    super.key,
    this.form,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final F? form;
  final void Function(BuildContext context, S state) listener;
  final FormidableStateCondition<S>? listenWhen;
  final Widget child;

  @override
  Widget build(BuildContext context) => ObservableListener<S>(
    observable: _FormStates<F, S>(
      form ?? FormidableScope.of<F>(context, listen: true),
    ),
    listener: listener,
    listenWhen: listenWhen,
    child: child,
  );
}

/// Rebuilds [builder] only when what [selector] picks from the state of a Form
/// changes (compared with `==`) and [buildWhen] agrees.
///
/// The selector receives the state, which also holds the Schema value
/// (`state.value`, null while the Form is invalid), so it can follow any part
/// of the Form. The Form comes from [form] or from the closest Form Scope of
/// type [F], and [S] is the state type, as in [FormidableTypedFormBuilder].
class FormidableTypedFormSelector<
  F extends FormidableForm<Object?>,
  S extends FormidableFormState,
  R
>
    extends StatelessWidget {
  const FormidableTypedFormSelector({
    super.key,
    this.form,
    required this.selector,
    required this.builder,
    this.buildWhen,
  });

  final F? form;
  final R Function(S state) selector;
  final Widget Function(BuildContext context, R selected) builder;

  /// Receives the previous and the next selected value and can still veto a
  /// rebuild.
  final FormidableStateCondition<R>? buildWhen;

  @override
  Widget build(BuildContext context) => ObservableSelector<S, R>(
    observable: _FormStates<F, S>(
      form ?? FormidableScope.of<F>(context, listen: true),
    ),
    selector: selector,
    builder: builder,
    buildWhen: buildWhen,
  );
}

/// [FormidableTypedFormBuilder] typed as [FormidableFormState], for code
/// that does not use the generated builders.
class FormidableFormBuilder<F extends FormidableForm<Object?>>
    extends FormidableTypedFormBuilder<F, FormidableFormState> {
  const FormidableFormBuilder({
    super.key,
    super.form,
    required super.builder,
    super.buildWhen,
  });
}

/// [FormidableTypedFormListener] typed as [FormidableFormState], for code
/// that does not use the generated listeners.
class FormidableFormListener<F extends FormidableForm<Object?>>
    extends FormidableTypedFormListener<F, FormidableFormState> {
  const FormidableFormListener({
    super.key,
    super.form,
    required super.listener,
    required super.child,
    super.listenWhen,
  });
}

/// [FormidableTypedFormSelector] typed as [FormidableFormState], for code
/// that does not use the generated selectors.
class FormidableFormSelector<F extends FormidableForm<Object?>, R>
    extends FormidableTypedFormSelector<F, FormidableFormState, R> {
  const FormidableFormSelector({
    super.key,
    super.form,
    required super.selector,
    required super.builder,
    super.buildWhen,
  });
}

/// Observes a Form as a source of states of type [S]. A generated Form narrows
/// its `state` to the generated state type, so the cast always holds.
final class _FormStates<F extends FormidableForm<Object?>, S>
    implements FormidableObservable<S> {
  const _FormStates(this._form);

  final F _form;

  @override
  S get state => _form.state as S;

  @override
  void addListener(void Function() listener) => _form.addListener(listener);

  @override
  void removeListener(void Function() listener) =>
      _form.removeListener(listener);

  // Widgets compare observables to notice that they follow another Form.
  @override
  bool operator ==(Object other) =>
      other is _FormStates<F, S> && identical(other._form, _form);

  @override
  int get hashCode => identityHashCode(_form);
}

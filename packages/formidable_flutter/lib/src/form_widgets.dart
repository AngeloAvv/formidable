import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'observable_widgets.dart';
import 'scope.dart';

/// Rebuilds [builder] with the state of a Form, starting with its current
/// state.
///
/// Pass [form] to use a specific Form. Without it, the widget looks up the
/// closest Form Scope of type [F] and throws an error naming the missing scope
/// when there is none.
class FormidableFormBuilder<F extends FormidableForm<Object?>>
    extends StatelessWidget {
  const FormidableFormBuilder({
    super.key,
    this.form,
    required this.builder,
    this.buildWhen,
  });

  final F? form;
  final Widget Function(BuildContext context, FormidableFormState state)
  builder;
  final FormidableStateCondition<FormidableFormState>? buildWhen;

  @override
  Widget build(BuildContext context) => ObservableBuilder<FormidableFormState>(
    observable: form ?? FormidableScope.of<F>(context, listen: true),
    builder: builder,
    buildWhen: buildWhen,
  );
}

/// Calls [listener] each time the state of a Form changes. The Form comes from
/// [form] or from the closest Form Scope of type [F], as in
/// [FormidableFormBuilder].
class FormidableFormListener<F extends FormidableForm<Object?>>
    extends StatelessWidget {
  const FormidableFormListener({
    super.key,
    this.form,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final F? form;
  final void Function(BuildContext context, FormidableFormState state) listener;
  final FormidableStateCondition<FormidableFormState>? listenWhen;
  final Widget child;

  @override
  Widget build(BuildContext context) => ObservableListener<FormidableFormState>(
    observable: form ?? FormidableScope.of<F>(context, listen: true),
    listener: listener,
    listenWhen: listenWhen,
    child: child,
  );
}

/// Rebuilds [builder] only when what [selector] picks from the Form changes.
///
/// The selector receives the Form itself, so it can read `form.value` or any
/// Field. It runs after every change of the Form, which is what lets it follow
/// `form.value` even when the Form state stays equal. The Form comes from
/// [form] or from the closest Form Scope of type [F].
class FormidableFormSelector<F extends FormidableForm<Object?>, R>
    extends StatelessWidget {
  const FormidableFormSelector({
    super.key,
    this.form,
    required this.selector,
    required this.builder,
    this.buildWhen,
  });

  final F? form;
  final R Function(F form) selector;
  final Widget Function(BuildContext context, R selected) builder;
  final FormidableStateCondition<R>? buildWhen;

  @override
  Widget build(BuildContext context) => ObservableSelector<F, R>(
    observable: _FormChanges<F>(
      form ?? FormidableScope.of<F>(context, listen: true),
    ),
    selector: selector,
    builder: builder,
    buildWhen: buildWhen,
  );
}

/// Observes a Form through its change channel: the "state" is the Form itself
/// and listeners hear every change.
final class _FormChanges<F extends FormidableForm<Object?>>
    implements FormidableObservable<F> {
  const _FormChanges(this._form);

  final F _form;

  @override
  F get state => _form;

  @override
  void addListener(void Function() listener) =>
      _form.addChangeListener(listener);

  @override
  void removeListener(void Function() listener) =>
      _form.removeChangeListener(listener);

  @override
  bool operator ==(Object other) =>
      other is _FormChanges<F> && identical(other._form, _form);

  @override
  int get hashCode => identityHashCode(_form);
}

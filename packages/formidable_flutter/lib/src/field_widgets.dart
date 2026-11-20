import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'observable_widgets.dart';

/// Rebuilds [builder] with the state of [field], starting with its current
/// state, so there is no empty first frame.
///
/// [buildWhen] receives the previous and the current state and decides whether
/// to rebuild.
class FormidableFieldBuilder<T> extends StatelessWidget {
  const FormidableFieldBuilder({
    super.key,
    required this.field,
    required this.builder,
    this.buildWhen,
  });

  final FormidableField<T> field;
  final Widget Function(BuildContext context, FormidableFieldState<T> state)
  builder;
  final FormidableStateCondition<FormidableFieldState<T>>? buildWhen;

  @override
  Widget build(BuildContext context) =>
      ObservableBuilder<FormidableFieldState<T>>(
        observable: field,
        builder: builder,
        buildWhen: buildWhen,
      );
}

/// Calls [listener] each time the state of [field] changes, never for the
/// state present when it is built.
///
/// [listenWhen] receives the previous and the current state and decides
/// whether to call it.
class FormidableFieldListener<T> extends StatelessWidget {
  const FormidableFieldListener({
    super.key,
    required this.field,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final FormidableField<T> field;
  final void Function(BuildContext context, FormidableFieldState<T> state)
  listener;
  final FormidableStateCondition<FormidableFieldState<T>>? listenWhen;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ObservableListener<FormidableFieldState<T>>(
        observable: field,
        listener: listener,
        listenWhen: listenWhen,
        child: child,
      );
}

/// Rebuilds [builder] only when what [selector] picks from the state of
/// [field] changes.
///
/// [buildWhen] receives the previous and the current selected value and can
/// still veto a rebuild.
class FormidableFieldSelector<T, R> extends StatelessWidget {
  const FormidableFieldSelector({
    super.key,
    required this.field,
    required this.selector,
    required this.builder,
    this.buildWhen,
  });

  final FormidableField<T> field;
  final R Function(FormidableFieldState<T> state) selector;
  final Widget Function(BuildContext context, R selected) builder;
  final FormidableStateCondition<R>? buildWhen;

  @override
  Widget build(BuildContext context) =>
      ObservableSelector<FormidableFieldState<T>, R>(
        observable: field,
        selector: selector,
        builder: builder,
        buildWhen: buildWhen,
      );
}

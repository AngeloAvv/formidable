import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'observable_widgets.dart';

/// Rebuilds with the items of [array], each one keyed by its stable
/// identifier, starting with the current items, so there is no empty first
/// frame.
///
/// [itemBuilder] builds the widget of one item. Every item is wrapped in a
/// widget keyed with the identifier of the item, so adding, removing or moving
/// items keeps the state of each row (text, focus, scroll) with its item
/// instead of handing it to the row that takes its place.
///
/// [builder] lays the rows out and also receives the state of the array: its
/// `errors` are the errors of the array itself (a minimum number of items, for
/// example) and its `items` hold the state of every item, so the layout can
/// react to the value of an item. It defaults to a [Column]; give it a
/// `ListView` or any other layout for long lists.
///
/// [buildWhen] receives the previous and the current state and decides whether
/// to rebuild. Without it every change of the array or of an item rebuilds.
class FormidableFieldArrayBuilder<N extends FormidableNode, T, S>
    extends StatelessWidget {
  const FormidableFieldArrayBuilder({
    super.key,
    required this.array,
    required this.itemBuilder,
    this.builder = _column,
    this.buildWhen,
  });

  final FormidableFieldArray<N, T, S> array;

  /// Builds the widget of one item. [index] is its current position.
  final Widget Function(
    BuildContext context,
    int index,
    FormidableFieldArrayItem<N> item,
  )
  itemBuilder;

  /// Lays out the already keyed [items].
  final Widget Function(
    BuildContext context,
    FormidableFieldArrayState<S> state,
    List<Widget> items,
  )
  builder;

  final FormidableStateCondition<FormidableFieldArrayState<S>>? buildWhen;

  static Widget _column(
    BuildContext context,
    FormidableFieldArrayState<Object?> state,
    List<Widget> items,
  ) => Column(mainAxisSize: MainAxisSize.min, children: items);

  @override
  Widget build(BuildContext context) =>
      ObservableBuilder<FormidableFieldArrayState<S>>(
        observable: array,
        buildWhen: buildWhen,
        builder: (context, state) {
          final items = array.items;
          return builder(context, state, [
            for (var i = 0; i < items.length; i++)
              KeyedSubtree(
                key: ValueKey<int>(items[i].id),
                child: itemBuilder(context, i, items[i]),
              ),
          ]);
        },
      );
}

/// Calls [listener] each time the state of [array] changes, an edit of the
/// value of an item included, never for the state present when it is built.
///
/// [listenWhen] receives the previous and the current state and decides
/// whether to call it.
class FormidableFieldArrayListener<N extends FormidableNode, T, S>
    extends StatelessWidget {
  const FormidableFieldArrayListener({
    super.key,
    required this.array,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final FormidableFieldArray<N, T, S> array;
  final void Function(BuildContext context, FormidableFieldArrayState<S> state)
  listener;
  final FormidableStateCondition<FormidableFieldArrayState<S>>? listenWhen;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ObservableListener<FormidableFieldArrayState<S>>(
        observable: array,
        listener: listener,
        listenWhen: listenWhen,
        child: child,
      );
}

/// Rebuilds [builder] only when what [selector] picks from the state of
/// [array] changes (compared with `==`).
///
/// [buildWhen] receives the previous and the current selected value and can
/// still veto a rebuild.
class FormidableFieldArraySelector<N extends FormidableNode, T, S, R>
    extends StatelessWidget {
  const FormidableFieldArraySelector({
    super.key,
    required this.array,
    required this.selector,
    required this.builder,
    this.buildWhen,
  });

  final FormidableFieldArray<N, T, S> array;
  final R Function(FormidableFieldArrayState<S> state) selector;
  final Widget Function(BuildContext context, R selected) builder;
  final FormidableStateCondition<R>? buildWhen;

  @override
  Widget build(BuildContext context) =>
      ObservableSelector<FormidableFieldArrayState<S>, R>(
        observable: array,
        selector: selector,
        builder: builder,
        buildWhen: buildWhen,
      );
}

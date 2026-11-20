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
/// [builder] lays the rows out and also receives the state of the array, whose
/// `errors` are the errors of the array itself (a minimum number of items, for
/// example). It defaults to a [Column]; give it a `ListView` or any other
/// layout for long lists.
///
/// [buildWhen] receives the previous and the current state and decides whether
/// to rebuild.
class FormidableFieldArrayBuilder<N extends FormidableNode, T>
    extends StatelessWidget {
  const FormidableFieldArrayBuilder({
    super.key,
    required this.array,
    required this.itemBuilder,
    this.builder = _column,
    this.buildWhen,
  });

  final FormidableFieldArray<N, T> array;

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
    FormidableFieldArrayState state,
    List<Widget> items,
  )
  builder;

  final FormidableStateCondition<FormidableFieldArrayState>? buildWhen;

  static Widget _column(
    BuildContext context,
    FormidableFieldArrayState state,
    List<Widget> items,
  ) => Column(mainAxisSize: MainAxisSize.min, children: items);

  @override
  Widget build(BuildContext context) =>
      ObservableBuilder<FormidableFieldArrayState>(
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

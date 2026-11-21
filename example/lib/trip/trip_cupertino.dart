import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'trip.dart';
import 'trip.formidable_scope.dart';

/// The Field Array guide with Cupertino widgets. `FormidableFieldArrayBuilder`
/// is design-system agnostic, so only the rows differ from the Material page.
class TripCupertinoPage extends StatelessWidget {
  const TripCupertinoPage({super.key});

  @override
  Widget build(BuildContext context) => TripFormScope(
    // The builder gets the Form and a context below the scope.
    builder: (context, form) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Trip')),
      child: SafeArea(child: _TripBody(form: form)),
    ),
  );
}

class _TripBody extends StatefulWidget {
  const _TripBody({required this.form});

  final TripForm form;

  @override
  State<_TripBody> createState() => _TripBodyState();
}

class _TripBodyState extends State<_TripBody> {
  String? _result;

  Future<void> _save(TripForm form) async {
    final result = switch (await form.submit()) {
      FormidableSubmitValid(:final value) =>
        'Saved ${value.name}: ${value.stops.map((s) => s.place).join(', ')}.',
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _result = result);
  }

  Widget _error(BuildContext context, FormidableValidationError error) => Text(
    formidableMessageOf(context, error),
    style: const TextStyle(color: CupertinoColors.systemRed),
  );

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FormidableCupertinoTextField(
          key: const Key('name'),
          field: form.name,
          placeholder: 'Trip name',
        ),
        const SizedBox(height: 16),
        const Text('Stops', style: TextStyle(fontWeight: FontWeight.w600)),
        FormidableFieldArrayBuilder(
          array: form.stops,
          itemBuilder: (context, index, item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 3,
                  child: FormidableCupertinoTextField(
                    key: Key('place-${item.id}'),
                    field: item.node.place,
                    placeholder: 'Place',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FormidableCupertinoTextField(
                    key: Key('nights-${item.id}'),
                    field: item.node.nights,
                    placeholder: 'Nights (1)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                CupertinoButton(
                  key: Key('move-up-$index'),
                  padding: EdgeInsets.zero,
                  onPressed: index == 0
                      ? null
                      : () => form.stops.move(index, index - 1),
                  child: const Icon(CupertinoIcons.arrow_up),
                ),
                CupertinoButton(
                  key: Key('remove-$index'),
                  padding: EdgeInsets.zero,
                  onPressed: () => form.stops.remove(item),
                  child: const Icon(CupertinoIcons.delete),
                ),
              ],
            ),
          ),
          builder: (context, state, items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items,
              if (state.dirty || state.submitted)
                for (final error in state.errors) _error(context, error),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: form.stops.add,
                child: const Text('Add stop'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
        FormidableFieldArrayBuilder(
          array: form.tags,
          itemBuilder: (context, index, item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FormidableCupertinoTextField(
                    key: Key('tag-${item.id}'),
                    field: item.node,
                    placeholder: 'Tag',
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => form.tags.remove(item),
                  child: const Icon(CupertinoIcons.xmark),
                ),
              ],
            ),
          ),
          builder: (context, state, items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items,
              if (state.dirty || state.submitted)
                for (final error in state.errors) _error(context, error),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: form.tags.add,
                child: const Text('Add tag'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CupertinoButton.filled(
          onPressed: () => _save(form),
          child: const Text('Save trip'),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Text(_result!, key: const Key('result')),
        ],
      ],
    );
  }
}

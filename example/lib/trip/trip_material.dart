import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'trip.dart';
import 'trip.formidable_scope.dart';

/// Field Arrays with Material widgets: a list of Nested Forms (the stops) and
/// a list of Fields (the tags).
class TripMaterialPage extends StatelessWidget {
  const TripMaterialPage({super.key});

  @override
  Widget build(BuildContext context) => TripFormScope(
    // The builder gets the Form and a context below the scope.
    builder: (context, form) => Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: _TripBody(form: form),
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

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FormidableMaterialTextField(
          key: const Key('name'),
          field: form.name,
          decoration: const InputDecoration(
            labelText: 'Trip name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text('Stops', style: Theme.of(context).textTheme.titleMedium),
        FormidableFieldArrayBuilder(
          array: form.stops,
          itemBuilder: (context, index, item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 3,
                  child: FormidableMaterialTextField(
                    key: Key('place-${item.id}'),
                    field: item.node.place,
                    decoration: const InputDecoration(
                      labelText: 'Place',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FormidableMaterialTextField(
                    key: Key('nights-${item.id}'),
                    field: item.node.nights,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nights',
                      hintText: '1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  key: Key('move-up-$index'),
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: index == 0
                      ? null
                      : () => form.stops.move(index, index - 1),
                ),
                IconButton(
                  key: Key('remove-$index'),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => form.stops.remove(item),
                ),
              ],
            ),
          ),
          builder: (context, state, items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items,
              // The errors of the array itself: its size, or "required".
              if (state.dirty || state.submitted)
                for (final error in state.errors)
                  Text(
                    formidableMessageOf(context, error),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              TextButton(
                onPressed: form.stops.add,
                child: const Text('Add stop'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Tags', style: Theme.of(context).textTheme.titleMedium),
        FormidableFieldArrayBuilder(
          array: form.tags,
          itemBuilder: (context, index, item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FormidableMaterialTextField(
                    key: Key('tag-${item.id}'),
                    field: item.node,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => form.tags.remove(item),
                ),
              ],
            ),
          ),
          builder: (context, state, items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items,
              if (state.dirty || state.submitted)
                for (final error in state.errors)
                  Text(
                    formidableMessageOf(context, error),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              TextButton(
                onPressed: form.tags.add,
                child: const Text('Add tag'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
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

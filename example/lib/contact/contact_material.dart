import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'contact.dart';
import 'contact.formidable_scope.dart';

/// The saved contact, with a button that opens the editor.
class ContactMaterialPage extends StatefulWidget {
  const ContactMaterialPage({super.key});

  @override
  State<ContactMaterialPage> createState() => _ContactMaterialPageState();
}

class _ContactMaterialPageState extends State<ContactMaterialPage> {
  final _store = ContactStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contact')),
    body: ListenableBuilder(
      listenable: _store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _store.contact.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(describeAddress(_store.contact.address)),
          Text('Contact #${_store.contact.id}'),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ContactEditMaterialPage(store: _store),
              ),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    ),
  );
}

/// Edits the saved contact.
///
/// - `ContactForm.from(...)` starts the Form from the saved contact.
/// - The declarative pattern drives the Save button: a Form Selector over
///   `form.value` enables it while the Form is valid and has changes.
/// - `commit()` after a save makes the saved values the new initial state, so
///   the Form is clean again.
/// - `FormidablePopScope` asks before leaving while the Form is dirty.
class ContactEditMaterialPage extends StatelessWidget {
  const ContactEditMaterialPage({super.key, required this.store});

  final ContactStore store;

  @override
  Widget build(BuildContext context) => ContactFormScope(
    create: () => ContactForm.from(store.contact),
    child: FormidablePopScope<ContactForm>(
      confirmLeave: (context) async =>
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit contact')),
        body: _EditBody(store: store),
      ),
    ),
  );
}

class _EditBody extends StatefulWidget {
  const _EditBody({required this.store});

  final ContactStore store;

  @override
  State<_EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends State<_EditBody> {
  bool _saved = false;

  void _save(ContactForm form) {
    // The service has the last word on what no Validator can know.
    if (emailIsInUse(form.email.value)) {
      form.applyErrors(
        fieldErrors: {
          form.email: [const EmailInUseError()],
        },
      );
      // The user may not have left the Field yet: show the error now.
      form.email.markAsTouched();
      return;
    }
    widget.store.save(form.value!);
    form.commit();
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.contactForm;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FormidableMaterialTextField(
          key: const Key('name'),
          field: form.name,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FormidableMaterialTextField(
          key: const Key('email'),
          field: form.email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // A Nested Form: its Fields are typed handles like any other.
        FormidableMaterialTextField(
          key: const Key('street'),
          field: form.address.street,
          decoration: const InputDecoration(
            labelText: 'Street',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FormidableMaterialSegmentedButton<String>(
          field: form.address.country,
          segments: const [
            ButtonSegment(value: 'IT', label: Text('Italy')),
            ButtonSegment(value: 'FR', label: Text('France')),
          ],
        ),
        const SizedBox(height: 16),
        FormidableMaterialTextField(
          key: const Key('province'),
          field: form.address.province,
          decoration: const InputDecoration(
            labelText: 'Province',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          spacing: 12,
          children: [
            ContactFormSelector<bool>(
              selector: (state) => state.form.value != null && state.form.dirty,
              builder: (context, canSave) => FilledButton(
                onPressed: canSave ? () => _save(form) : null,
                child: const Text('Save'),
              ),
            ),
            OutlinedButton(
              onPressed: () => form.patch(name: 'Grace Hopper'),
              child: const Text('Use a sample name'),
            ),
            OutlinedButton(
              onPressed: () {
                form.reset();
                setState(() => _saved = false);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // A disabled button does not say why. Say it next to the button.
        const Text('Save is on while the form is valid and has changes.'),
        if (_saved) const Text('Saved.'),
      ],
    );
  }
}

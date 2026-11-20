import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'contact.dart';
import 'contact.formidable_scope.dart';

/// The saved contact, with a button that opens the editor.
class ContactCupertinoPage extends StatefulWidget {
  const ContactCupertinoPage({super.key});

  @override
  State<ContactCupertinoPage> createState() => _ContactCupertinoPageState();
}

class _ContactCupertinoPageState extends State<ContactCupertinoPage> {
  final _store = ContactStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(middle: Text('Contact')),
    child: SafeArea(
      child: ListenableBuilder(
        listenable: _store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _store.contact.name,
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            Text(describeAddress(_store.contact.address)),
            Text('Contact #${_store.contact.id}'),
            const SizedBox(height: 16),
            CupertinoButton.tinted(
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => ContactEditCupertinoPage(store: _store),
                ),
              ),
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The same edit guide as the Material page: same Schema, same Form, same
/// declarative Save button and the same pop scope.
class ContactEditCupertinoPage extends StatelessWidget {
  const ContactEditCupertinoPage({super.key, required this.store});

  final ContactStore store;

  @override
  Widget build(BuildContext context) => ContactFormScope(
    create: () => ContactForm.from(store.contact),
    child: FormidablePopScope<ContactForm>(
      confirmLeave: (context) async =>
          await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Discard changes?'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Edit contact'),
        ),
        child: SafeArea(child: _EditBody(store: store)),
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
        FormidableCupertinoTextField(
          key: const Key('name'),
          field: form.name,
          placeholder: 'Name',
        ),
        const SizedBox(height: 16),
        FormidableCupertinoTextField(
          key: const Key('email'),
          field: form.email,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        FormidableCupertinoTextField(
          key: const Key('street'),
          field: form.address.street,
          placeholder: 'Street',
        ),
        const SizedBox(height: 16),
        FormidableCupertinoSlidingSegmentedControl<String>(
          field: form.address.country,
          children: const {'IT': Text('Italy'), 'FR': Text('France')},
        ),
        const SizedBox(height: 16),
        FormidableCupertinoTextField(
          key: const Key('province'),
          field: form.address.province,
          placeholder: 'Province',
        ),
        const SizedBox(height: 24),
        Row(
          spacing: 12,
          children: [
            FormidableFormSelector<ContactForm, bool>(
              selector: (form) => form.value != null && form.state.dirty,
              builder: (context, canSave) => CupertinoButton.filled(
                onPressed: canSave ? () => _save(form) : null,
                child: const Text('Save'),
              ),
            ),
            CupertinoButton(
              onPressed: () => form.patch(name: 'Grace Hopper'),
              child: const Text('Use a sample name'),
            ),
            CupertinoButton(
              onPressed: () {
                form.reset();
                setState(() => _saved = false);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Save is on while the form is valid and has changes.'),
        if (_saved) const Text('Saved.'),
      ],
    );
  }
}

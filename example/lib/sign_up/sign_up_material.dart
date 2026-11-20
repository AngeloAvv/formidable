import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'sign_up.dart';
import 'sign_up.formidable_scope.dart';

/// The sign-up guide with Material widgets.
///
/// It uses the imperative pattern: the button is always enabled, and `submit()`
/// returns a sealed result that a `switch` handles. Because every Field is
/// touched by `submit()`, the user sees every error that needs fixing.
class SignUpMaterialPage extends StatelessWidget {
  const SignUpMaterialPage({super.key});

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    // The generated Form takes the instance of every Async Validator.
    create: () => SignUpForm(
      usernameAvailable: UsernameAvailable(const UserRepository()),
    ),
    child: Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _SignUpBody(),
      ),
    ),
  );
}

class _SignUpBody extends StatefulWidget {
  const _SignUpBody();

  @override
  State<_SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<_SignUpBody> {
  String? _greeting;

  Future<void> _submit(SignUpForm form) async {
    final greeting = switch (await form.submit()) {
      FormidableSubmitValid(:final value) => 'Welcome, ${value.username}!',
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _greeting = greeting);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.signUpForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        FormidableMaterialTextField(
          key: const Key('username'),
          field: form.username,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        _Checking(form.username),
        FormidableMaterialTextField(
          key: const Key('password'),
          field: form.password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        FormidableMaterialTextField(
          key: const Key('confirmation'),
          field: form.confirmation,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            border: OutlineInputBorder(),
          ),
        ),
        FormidableMaterialSegmentedButton<AccountType>(
          field: form.type,
          segments: const [
            ButtonSegment(value: AccountType.personal, label: Text('Personal')),
            ButtonSegment(value: AccountType.company, label: Text('Company')),
          ],
        ),
        FormidableMaterialTextField(
          key: const Key('vat'),
          field: form.vat,
          decoration: const InputDecoration(
            labelText: 'VAT number (companies)',
            border: OutlineInputBorder(),
          ),
        ),
        FilledButton(
          onPressed: () => _submit(form),
          child: const Text('Sign up'),
        ),
        if (_greeting != null) Text(_greeting!, key: const Key('greeting')),
      ],
    );
  }
}

/// Shows progress while the Async Validators of a Field are running. `pending`
/// is part of the Field state, so a Field Builder rebuilds when it changes.
class _Checking extends StatelessWidget {
  const _Checking(this.field);

  final FormidableField<String> field;

  @override
  Widget build(BuildContext context) => FormidableFieldBuilder<String>(
    field: field,
    buildWhen: (previous, current) => previous.pending != current.pending,
    builder: (context, state) => state.pending
        ? const Text('Checking username…')
        : const SizedBox.shrink(),
  );
}

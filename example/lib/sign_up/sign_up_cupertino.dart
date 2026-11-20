import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'sign_up.dart';
import 'sign_up.formidable_scope.dart';

/// The sign-up guide with Cupertino widgets: the same Schema and the same
/// Form as the Material page, only the widgets differ.
class SignUpCupertinoPage extends StatelessWidget {
  const SignUpCupertinoPage({super.key});

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    create: () => SignUpForm(
      usernameAvailable: UsernameAvailable(const UserRepository()),
    ),
    child: const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Sign up')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: _SignUpBody(),
        ),
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
        FormidableCupertinoTextField(
          key: const Key('username'),
          field: form.username,
          placeholder: 'Username',
        ),
        _Checking(form.username),
        FormidableCupertinoTextField(
          key: const Key('password'),
          field: form.password,
          placeholder: 'Password',
          obscureText: true,
        ),
        FormidableCupertinoTextField(
          key: const Key('confirmation'),
          field: form.confirmation,
          placeholder: 'Confirm password',
          obscureText: true,
        ),
        FormidableCupertinoSlidingSegmentedControl<AccountType>(
          field: form.type,
          children: const {
            AccountType.personal: Text('Personal'),
            AccountType.company: Text('Company'),
          },
        ),
        FormidableCupertinoTextField(
          key: const Key('vat'),
          field: form.vat,
          placeholder: 'VAT number (companies)',
        ),
        CupertinoButton.filled(
          onPressed: () => _submit(form),
          child: const Text('Sign up'),
        ),
        if (_greeting != null) Text(_greeting!, key: const Key('greeting')),
      ],
    );
  }
}

/// Shows progress while the Async Validators of a Field are running.
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

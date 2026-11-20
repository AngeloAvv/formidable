import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'sign_up.dart';
import 'widgets_page.dart';
import 'sign_up.formidable_scope.dart';

/// Demonstrates one text Field from Schema to widget: the Form Scope creates
/// and disposes the Form, the text field shows the error once it is touched,
/// and `submit()` returns a sealed result.
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const WidgetsPage()),
            ),
            child: const Text('Material widgets'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/cupertino'),
            child: const Text('Cupertino widgets'),
          ),
        ],
      ),
      body: const Padding(padding: EdgeInsets.all(16), child: _SignUpBody()),
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
      children: [
        FormidableTextField(
          field: form.username,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _submit(form),
          child: const Text('Sign up'),
        ),
        if (_greeting != null) ...[
          const SizedBox(height: 16),
          Text(_greeting!, key: const Key('greeting')),
        ],
      ],
    );
  }
}

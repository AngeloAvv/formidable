import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart' hide Localizations;

import 'sign_up.dart';
import 'sign_up.formidable_scope.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'formidable_material example',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    // The delegate localizes the Validation Messages.
    localizationsDelegates: [
      FormidableLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: FormidableLocalizations.supportedLocales,
    home: const SignUpPage(),
  );
}

/// A fake backend, so that the example needs no network.
class _Api {
  const _Api();

  Future<void> signUp({required String email, required String password}) =>
      Future<void>.delayed(const Duration(milliseconds: 300));
}

const _api = _Api();

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Future<void> _onSubmit(SignUpForm form) async {
    switch (await form.submit()) {
      case FormidableSubmitValid(:final value):
        await _api.signUp(email: value.email, password: value.password);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Welcome aboard!')));
      case FormidableSubmitInvalid():
        break; // The errors are already shown on the Fields.
    }
  }

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    create: SignUpForm.new,
    builder: (context, form) => Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormidableMaterialTextField(
            key: const Key('email'),
            field: form.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          FormidableMaterialTextField(
            key: const Key('password'),
            field: form.password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          FormidableMaterialTextField(
            key: const Key('confirmation'),
            field: form.confirmation,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          FormidableMaterialCheckboxListTile(
            key: const Key('acceptedTerms'),
            field: form.acceptedTerms,
            title: const Text('I accept the terms and conditions'),
          ),
          SignUpFormSelector<bool>(
            selector: (state) => state.meta.valid,
            builder: (context, valid) => FilledButton(
              onPressed: valid ? () => _onSubmit(form) : null,
              child: const Text('Sign up'),
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'sign_up.dart';
import 'sign_up.formidable_scope.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => CupertinoApp(
    title: 'formidable_cupertino example',
    // The delegate localizes the Validation Messages.
    localizationsDelegates: [
      FormidableLocalizations.delegate,
      ...GlobalCupertinoLocalizations.delegates,
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
  String? _message;

  Future<void> _onSubmit(SignUpForm form) async {
    switch (await form.submit()) {
      case FormidableSubmitValid(:final value):
        await _api.signUp(email: value.email, password: value.password);
        if (!mounted) return;
        setState(() => _message = 'Welcome aboard!');
      case FormidableSubmitInvalid():
        break; // The errors are already shown on the Fields.
    }
  }

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    create: SignUpForm.new,
    builder: (context, form) => CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Sign up')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FormidableCupertinoTextField(
              key: const Key('email'),
              field: form.email,
              keyboardType: TextInputType.emailAddress,
              placeholder: 'Email',
            ),
            const SizedBox(height: 12),
            FormidableCupertinoTextField(
              key: const Key('password'),
              field: form.password,
              obscureText: true,
              placeholder: 'Password',
            ),
            const SizedBox(height: 12),
            FormidableCupertinoTextField(
              key: const Key('confirmation'),
              field: form.confirmation,
              obscureText: true,
              placeholder: 'Confirm password',
            ),
            const SizedBox(height: 12),
            MergeSemantics(
              child: Row(
                children: [
                  FormidableCupertinoSwitch(
                    key: const Key('acceptedTerms'),
                    field: form.acceptedTerms,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('I accept the terms and conditions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SignUpFormSelector<FormidableStatus>(
              selector: (state) => state.meta.status,
              builder: (context, status) => CupertinoButton.filled(
                onPressed: status == FormidableStatus.valid
                    ? () => _onSubmit(form)
                    : null,
                child: const Text('Sign up'),
              ),
            ),
            if (_message != null) Text(_message!, key: const Key('message')),
          ],
        ),
      ),
    ),
  );
}

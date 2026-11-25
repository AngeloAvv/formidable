import 'package:formidable/formidable.dart';
import 'package:formidable_core_example/sign_up.dart';

Future<void> main() async {
  final form = SignUpForm();

  // The streams only emit changes, never the state the Form is in already.
  final subscriptions = [
    form.valueChanges.listen(
      (state) => print('value changed: email=${state.email.valueOrNull}'),
    ),
    form.statusChanges.listen((status) => print('status: $status')),
    form
        .select((state) => state.password.errors.length)
        .listen((count) => print('password errors: $count')),
  ];

  // Writing from code goes through Normalizers, Validators and Effects.
  form.email.setValue('  ada@example.com ');
  form.password.setValue('short');
  form.password.setValue('Str0ngPassword');
  form.confirmation.setValue('Str0ngPassword');
  form.acceptedTerms.setValue(true);

  // submit() returns a sealed result: the validated Schema or the errors.
  switch (await form.submit()) {
    case FormidableSubmitValid(:final value):
      print('submitted: ${value.email}');
    case FormidableSubmitInvalid():
      print('the Form is invalid');
  }

  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
  form.dispose();
}

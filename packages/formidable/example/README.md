# formidable example

A pure Dart program, with no Flutter: it generates a sign-up Form from a Schema, listens to its streams, writes values from code and submits it.

- [`lib/sign_up.dart`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable/example/lib/sign_up.dart): the Schema.
- [`bin/main.dart`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable/example/bin/main.dart): the program.

Generate the Form, then run it:

```sh
dart run build_runner build
dart run bin/main.dart
```

The core of the program:

```dart
import 'package:formidable/formidable.dart';
import 'package:formidable_core_example/sign_up.dart';

final form = SignUpForm();

form.valueChanges.listen((state) => print(state.email.value));
form.statusChanges.listen((status) => print('status: $status'));

form.email.setValue('ada@example.com');
form.password.setValue('Str0ngPassword');
form.confirmation.setValue('Str0ngPassword');
form.acceptedTerms.setValue(true);

switch (await form.submit()) {
  case FormidableSubmitValid(:final value):
    print('submitted: ${value.email}');
  case FormidableSubmitInvalid():
    print('the Form is invalid');
}
```

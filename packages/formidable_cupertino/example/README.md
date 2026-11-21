# formidable_cupertino example

A sign-up page built with the Cupertino Field Widgets of `formidable_cupertino`: a generated `SignUpFormScope`, an email, a password and its confirmation, the terms, and a submit button that is enabled only while the Form is valid. The backend call is a fake.

- [`lib/sign_up.dart`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_cupertino/example/lib/sign_up.dart): the Schema.
- [`lib/main.dart`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_cupertino/example/lib/main.dart): the app and the page.

Generate the Form, then run the app:

```sh
dart run build_runner build
flutter run
```

The platform folders are not committed, create them with `flutter create .` first.

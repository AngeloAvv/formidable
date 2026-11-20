import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart' hide Localizations;

import 'contact/contact.dart';
import 'sign_up/sign_up.dart';

/// The messages of the Validation Errors the example defines itself.
final exampleMessages = const FormidableMessages()
    .on<UsernameTakenError>(
      (context, error) => '"${error.username}" is already taken.',
    )
    .on<PasswordHasUsernameError>(
      (context, error) => 'The password must not contain the username.',
    )
    .on<EmailInUseError>(
      (context, error) => 'That email is already registered.',
    );

Widget _config(BuildContext context, Widget? child) =>
    FormidableConfig(messages: exampleMessages, child: child!);

/// A Material app around one page. Every guide page of the example is shown in
/// one of these and in a [CupertinoShowcase], side by side.
class MaterialShowcase extends StatelessWidget {
  const MaterialShowcase({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    localizationsDelegates: [
      FormidableLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: FormidableLocalizations.supportedLocales,
    builder: _config,
    home: home,
  );
}

/// A Cupertino app around one page.
class CupertinoShowcase extends StatelessWidget {
  const CupertinoShowcase({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) => CupertinoApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      FormidableLocalizations.delegate,
      ...GlobalCupertinoLocalizations.delegates,
    ],
    supportedLocales: FormidableLocalizations.supportedLocales,
    builder: _config,
    home: home,
  );
}

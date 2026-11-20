import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'profile.dart';
import 'profile.formidable_scope.dart';

/// Mounts a generated [ProfileForm] in a Cupertino app, with [field] building
/// the widget under test. [onForm] receives the Form once it is created. A
/// text field named `other` follows it, so that tests can move the focus away.
Widget profileApp(
  Widget Function(ProfileForm form) field, {
  void Function(ProfileForm form)? onForm,
  ProfileForm Function()? create,
  FormidableCodecs? codecs,
}) {
  final home = CupertinoApp(
    localizationsDelegates: [
      FormidableLocalizations.delegate,
      ...GlobalCupertinoLocalizations.delegates,
    ],
    supportedLocales: FormidableLocalizations.supportedLocales,
    home: ProfileFormScope(
      create: () {
        final form = (create ?? () => ProfileForm(username: 'angelo'))();
        onForm?.call(form);
        return form;
      },
      child: Builder(
        builder: (context) => CupertinoPageScaffold(
          child: SafeArea(
            child: Column(
              children: [
                field(context.profileForm),
                const CupertinoTextField(key: Key('other')),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return codecs == null ? home : FormidableConfig(codecs: codecs, child: home);
}

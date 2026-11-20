import 'package:material_ui/material_ui.dart';

import 'sign_up_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Formidable example',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const SignUpPage(),
  );
}

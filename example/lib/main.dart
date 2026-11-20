import 'package:material_ui/material_ui.dart';

import 'guides.dart';

void main() => runApp(const ExampleApp());

/// The example app: a list of guides, each shown with Material and Cupertino
/// widgets side by side.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Formidable example',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const HomePage(),
  );
}

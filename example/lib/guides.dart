import 'package:material_ui/material_ui.dart';

import 'contact/contact_cupertino.dart';
import 'contact/contact_material.dart';
import 'showcase.dart';
import 'sign_up/sign_up_cupertino.dart';
import 'sign_up/sign_up_material.dart';
import 'survey/survey_cupertino.dart';
import 'survey/survey_material.dart';
import 'trip/trip_cupertino.dart';
import 'trip/trip_material.dart';
import 'widgets/widgets_cupertino.dart';
import 'widgets/widgets_material.dart';
import 'wizard/wizard_cupertino.dart';
import 'wizard/wizard_material.dart';

/// One guide of the example: the same Schema and Form, shown with Material
/// widgets and with Cupertino widgets.
class Guide {
  const Guide({
    required this.title,
    required this.summary,
    required this.material,
    required this.cupertino,
  });

  final String title;
  final String summary;
  final Widget material;
  final Widget cupertino;
}

const guides = [
  Guide(
    title: 'Sign up',
    summary:
        'Imperative submit, an Async Validator, cross-field rules and '
        'Normalizers',
    material: SignUpMaterialPage(),
    cupertino: SignUpCupertinoPage(),
  ),
  Guide(
    title: 'Edit a contact',
    summary:
        'from and commit, a Nested Form, a Form Effect, a declarative Save '
        'button and a pop scope',
    material: ContactMaterialPage(),
    cupertino: ContactCupertinoPage(),
  ),
  Guide(
    title: 'Field Arrays',
    summary: 'Repeatable stops and tags with stable identity and item counts',
    material: TripMaterialPage(),
    cupertino: TripCupertinoPage(),
  ),
  Guide(
    title: 'Wizard',
    summary: 'One Form, one Nested Form per step, submitted step by step',
    material: WizardMaterialPage(),
    cupertino: WizardCupertinoPage(),
  ),
  Guide(
    title: 'Dynamic Form',
    summary: 'Fields registered at runtime from a questionnaire',
    material: SurveyMaterialPage(),
    cupertino: SurveyCupertinoPage(),
  ),
  Guide(
    title: 'Widgets',
    summary: 'Every Material and Cupertino widget bound to a Field',
    material: WidgetsMaterialPage(),
    cupertino: WidgetsCupertinoPage(),
  ),
];

/// The list of guides.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Formidable')),
    body: ListView(
      children: [
        for (final guide in guides)
          ListTile(
            title: Text(guide.title),
            subtitle: Text(guide.summary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => GuidePage(guide: guide)),
            ),
          ),
      ],
    ),
  );
}

/// Shows a guide with Material and Cupertino side by side. A screen too narrow
/// for two panes shows one at a time, with a switch.
class GuidePage extends StatefulWidget {
  const GuidePage({super.key, required this.guide});

  final Guide guide;

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  static const _sideBySideWidth = 900.0;

  bool _cupertino = false;

  @override
  Widget build(BuildContext context) {
    final material = MaterialShowcase(
      key: const Key('material-pane'),
      home: widget.guide.material,
    );
    final cupertino = CupertinoShowcase(
      key: const Key('cupertino-pane'),
      home: widget.guide.cupertino,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.guide.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _sideBySideWidth) {
            return Row(
              children: [
                Expanded(child: material),
                const VerticalDivider(width: 1),
                Expanded(child: cupertino),
              ],
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Material')),
                    ButtonSegment(value: true, label: Text('Cupertino')),
                  ],
                  selected: {_cupertino},
                  onSelectionChanged: (selection) =>
                      setState(() => _cupertino = selection.first),
                ),
              ),
              Expanded(child: _cupertino ? cupertino : material),
            ],
          );
        },
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

/// The line shown below a widget that has no `errorText` of its own, such as a
/// checkbox or a slider. Shows nothing while [text] is null.
///
/// Pass it `binding.errorText` when you build your own widget on a Binding, so
/// that it shows the Validation Message like the widgets of this package do.
class FormidableErrorLine extends StatelessWidget {
  const FormidableErrorLine({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    if (text == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

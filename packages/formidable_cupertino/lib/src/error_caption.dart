import 'package:cupertino_ui/cupertino_ui.dart';

/// Shows [child] with the Validation Message [errorText] under it, once there
/// is one to show. Cupertino widgets have no decoration for errors, so every
/// widget of this package draws the message the same way.
///
/// Pass it `control.errorText` when you build your own widget on a
/// `FormidableFieldWidget`.
class FormidableCupertinoErrorCaption extends StatelessWidget {
  const FormidableCupertinoErrorCaption({
    super.key,
    required this.errorText,
    required this.child,
  });

  /// The message to show, or null to show only [child].
  final String? errorText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    if (errorText == null) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorText,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ),
      ],
    );
  }
}

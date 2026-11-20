import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

/// Shows [child] with the Validation Message of [binding] under it, once there
/// is one to show. Cupertino widgets have no decoration for errors, so every
/// widget of this package draws the message the same way.
class FormidableCupertinoErrorCaption extends StatelessWidget {
  const FormidableCupertinoErrorCaption({
    super.key,
    required this.binding,
    required this.child,
  });

  final FormidableBinding<Object?> binding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final errorText = binding.errorText;
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

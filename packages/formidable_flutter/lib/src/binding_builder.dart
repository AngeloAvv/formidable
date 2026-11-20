import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'binding.dart';
import 'messages.dart';

/// Creates a [FormidableBinding] for [field] and rebuilds [builder] whenever
/// the Field changes.
///
/// This is the headless entry point: [builder] can return any widget.
class FormidableBindingBuilder<T> extends StatefulWidget {
  const FormidableBindingBuilder({
    super.key,
    required this.field,
    required this.builder,
    this.focusNode,
    this.textController,
    this.formatText,
    this.parseText,
  });

  final FormidableField<T> field;

  final Widget Function(BuildContext context, FormidableBinding<T> binding)
  builder;

  /// Used instead of a focus node owned by the Binding. Never disposed by it.
  final FocusNode? focusNode;

  /// Used instead of a text controller owned by the Binding. Never disposed by
  /// it.
  final TextEditingController? textController;

  /// How a value is written in a text widget. Needed for text widgets.
  final String Function(T value)? formatText;

  /// How text is read back into a value, or null for Unset. Needed for text
  /// widgets.
  final T? Function(String text)? parseText;

  @override
  State<FormidableBindingBuilder<T>> createState() =>
      _FormidableBindingBuilderState<T>();
}

class _FormidableBindingBuilderState<T>
    extends State<FormidableBindingBuilder<T>> {
  late FormidableBinding<T> _binding = _createBinding();

  FormidableBinding<T> _createBinding() => FormidableBinding<T>(
    field: widget.field,
    focusNode: widget.focusNode,
    textController: widget.textController,
    formatText: widget.formatText,
    parseText: widget.parseText,
    resolveMessage: (error) => formidableMessageOf(context, error),
  );

  @override
  void didUpdateWidget(FormidableBindingBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field != widget.field ||
        oldWidget.focusNode != widget.focusNode ||
        oldWidget.textController != widget.textController) {
      _binding.dispose();
      _binding = _createBinding();
    }
  }

  @override
  void dispose() {
    _binding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _binding,
    builder: (context, _) => widget.builder(context, _binding),
  );
}

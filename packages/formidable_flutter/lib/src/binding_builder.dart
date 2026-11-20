import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'binding.dart';
import 'config.dart';
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
    this.codec,
    this.messages,
  });

  final FormidableField<T> field;

  final Widget Function(BuildContext context, FormidableBinding<T> binding)
  builder;

  /// Used instead of a focus node owned by the Binding. Never disposed by it.
  final FocusNode? focusNode;

  /// Used instead of a text controller owned by the Binding. Never disposed by
  /// it.
  final TextEditingController? textController;

  /// The Codec between the Field and the text of a text widget. It wins over
  /// the registry of the nearest [FormidableConfig]. Without it, the registry
  /// picks one by the type of the Field.
  final FormidableCodec<T, String>? codec;

  /// Messages for this widget only. They win over the config registry, the
  /// localizations and the string form of the error.
  final FormidableMessages? messages;

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
    codec: _resolveCodec(),
    resolveMessage: _resolveMessage,
  );

  // The codec of the widget, else the one of the config registry, else a
  // built-in one. Reading the config makes this widget depend on it.
  FormidableCodec<T, String>? _resolveCodec() {
    final registry =
        FormidableConfig.maybeOf(context)?.codecs ?? FormidableCodecs.defaults;
    return widget.codec ?? registry.find<T, String>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _binding.updateCodec(_resolveCodec());
  }

  // Looked up when an error is shown, so that this widget depends on the
  // locale and the config only while there is an error to explain.
  String _resolveMessage(FormidableValidationError error) =>
      formidableMessageOf(context, error, overrides: widget.messages);

  @override
  void didUpdateWidget(FormidableBindingBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field != widget.field ||
        oldWidget.focusNode != widget.focusNode ||
        oldWidget.textController != widget.textController) {
      _binding.dispose();
      _binding = _createBinding();
    } else if (oldWidget.codec != widget.codec) {
      _binding.updateCodec(_resolveCodec());
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

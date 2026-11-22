import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'error_display.dart';
import 'messages.dart';
import 'scope.dart';

/// Builds the widget of a [FormidableFieldWidget] from its [control].
typedef FormidableFieldWidgetBuilder<T, V> = Widget Function(
  BuildContext context,
  FormidableFieldWidgetState<T, V> control,
);

/// Turns any widget into a Formidable widget: it keeps one Field and the
/// widget that shows it in sync.
///
/// [T] is the type of the Field. [V] is the type of the value the widget
/// works with, its view value. They are the same unless a [codec] sits between
/// them, as when a Field of `int` is edited with a slider that works with
/// `double`.
///
/// The widget draws nothing itself: [builder] returns it, and receives a
/// [FormidableFieldWidgetState] (called the control) that tells what to show
/// ([FormidableFieldWidgetState.value], [FormidableFieldWidgetState.errorText],
/// [FormidableFieldWidgetState.enabled]) and takes what the user did
/// ([FormidableFieldWidgetState.didChange],
/// [FormidableFieldWidgetState.touch]). It also owns the focus node,
/// makes the Field touched when it loses focus, and takes part in keyboard
/// navigation between Fields.
///
/// Use it ad hoc with a [builder], or subclass it to ship a widget that others
/// use like any other Formidable widget:
///
/// ```dart
/// class FormidableColorPicker extends FormidableFieldWidget<Color?, Color?> {
///   FormidableColorPicker({super.key, required super.field})
///     : super(
///         builder: (context, control) => ColorPicker(
///           selected: control.value,
///           onSelected: (color) => control.didChange(color, touched: true),
///           errorText: control.errorText,
///         ),
///       );
/// }
/// ```
///
/// A subclass that needs more behaviour overrides [createState] with a
/// subclass of [FormidableFieldWidgetState].
class FormidableFieldWidget<T, V> extends StatefulWidget {
  const FormidableFieldWidget({
    super.key,
    required this.field,
    required this.builder,
    this.codec,
    this.messages,
    this.errorDisplay,
    this.focusNode,
  });

  /// The Field the widget shows and writes.
  final FormidableField<T> field;

  /// Builds the widget. It runs again whenever the Field changes.
  final FormidableFieldWidgetBuilder<T, V> builder;

  /// Converts between the Field and the view value. Without it the view value
  /// is the value of the Field, so [V] must be [T] (or a supertype of it).
  final FormidableCodec<T, V>? codec;

  /// Messages for this widget only. They win over the config registry, the
  /// localizations and the string form of the error.
  final FormidableMessages? messages;

  /// When errors are shown. Null follows the Form Scope, then the config.
  final FormidableErrorDisplay? errorDisplay;

  /// Used instead of a focus node owned by the widget. Never disposed by it.
  final FocusNode? focusNode;

  @override
  State<FormidableFieldWidget<T, V>> createState() =>
      FormidableFieldWidgetState<T, V>();
}

/// The control of a [FormidableFieldWidget]: what the widget shows, and how it
/// reports what the user did.
///
/// It is a plain [State], so a subclass can add behaviour and override what
/// it needs, then be returned from `createState`. Inside a subclass of the
/// widget, narrow [widget] to read the parameters the subclass added.
class FormidableFieldWidgetState<T, V>
    extends State<FormidableFieldWidget<T, V>> {
  late FormidableField<T> _field;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late void Function() _unregisterFocus;
  FormidableCodec<T, V>? _codec;
  FormidableErrorDisplay _errorDisplay = FormidableErrorDisplay.touched;
  bool _hadFocus = false;

  /// The Field the widget shows.
  FormidableField<T> get field => _field;

  /// The snapshot of the Field.
  FormidableFieldState<T> get state => _field.state;

  /// Whether the Field holds a value.
  bool get defined => _field.defined;

  /// The Codec between the Field and the view value, or null when there is
  /// none.
  FormidableCodec<T, V>? get codec => _codec;

  /// The value to show: the value of the Field seen through the [codec], or
  /// null while the Field is Unset (or holds null).
  V? get value {
    if (!_field.defined) return null;
    final value = _field.value;
    if (value == null) return null;
    final codec = _codec;
    return codec == null ? value as V : codec.format(value);
  }

  /// Whether the widget accepts input. A disabled Field is not part of the
  /// Form.
  bool get enabled => _field.state.enabled;

  /// Whether an Async Validator is still checking the Field, so a widget can
  /// show progress.
  bool get pending => _field.state.pending;

  /// The focus node of the widget: the one passed in, else one owned here.
  /// Give it to the widget that takes focus, so that the Field is touched on
  /// blur and keyboard navigation can reach it.
  FocusNode get focusNode => _focusNode;

  /// The Validation Message to show, or null when no error should be shown.
  ///
  /// Errors are shown according to the error display policy, and the first
  /// error in the order of the annotations wins. A disabled Field shows only
  /// its presence error (it is Unset and required); its value is not
  /// validated.
  String? get errorText {
    final state = _field.state;
    if (state.errors.isEmpty) return null;
    final shown = _errorDisplay.shows(
      touched: state.touched,
      dirty: state.dirty,
      submitted: state.submitted,
    );
    if (!shown) return null;
    return formidableMessageOf(
      context,
      state.errors.first,
      overrides: widget.messages,
    );
  }

  /// The keyboard action of a text widget: "next" while another Field after
  /// this one can take focus, "done" on the last one.
  ///
  /// Fields no widget shows, disabled Fields and Passthrough Fields are
  /// skipped. The widget rebuilds when this changes, because another widget
  /// was added or removed.
  TextInputAction get textInputAction => _field.nextFocusable == null
      ? TextInputAction.done
      : TextInputAction.next;

  /// The user pressed the keyboard action: focus moves to the next Field in
  /// Schema declaration order, or the keyboard closes on the last one.
  ///
  /// A widget that overrides the focus behaviour does not call it.
  void onEditingComplete() {
    if (!_field.focusNext()) _focusNode.unfocus();
  }

  /// The user produced [value]. It goes through the Codec, if there is one,
  /// and into the Field, which runs its Normalizers and Validators.
  ///
  /// Null means the widget has no value: the Field becomes Unset, unless the
  /// type of the Field admits null and there is no Codec, because then null is
  /// a value the user can choose (a "none" option), and it is not the same as
  /// Unset. Use [clear] to make the Field Unset in that case.
  ///
  /// A Codec can answer that the input has no value, or that it can't be
  /// parsed. A parse error rejects the Field, which becomes invalid even when
  /// it is optional, until the next valid input.
  ///
  /// With [touched], the Field also becomes touched. A widget that has no moment
  /// of "losing focus", such as a color picker or a checkbox, passes it so
  /// that the first interaction counts.
  void didChange(V? value, {bool touched = false}) {
    final codec = _codec;
    if (value == null) {
      if (codec == null && null is T) {
        _field.setValue(null as T);
      } else {
        _field.clear();
      }
    } else if (codec == null) {
      _field.setValue(value as T);
    } else {
      switch (codec.parse(value)) {
        case FormidableParsedValue<T>(:final value):
          _field.setValue(value);
        case FormidableParsedUnset<T>():
          _field.clear();
        case FormidableParseFailure<T>(:final error):
          _field.reject(error);
      }
    }
    if (touched) touch();
  }

  /// The user removed the value: the Field becomes Unset. With [touched] it also
  /// becomes touched.
  void clear({bool touched = false}) {
    _field.clear();
    if (touched) touch();
  }

  /// The user interacted with the widget and left it. The Field becomes
  /// touched, which is what shows its errors under the default policy.
  void touch() => _field.touch();

  /// The Codec to use, called when the dependencies or the widget change.
  /// The default is the [FormidableFieldWidget.codec]; a subclass can look it
  /// up elsewhere (the text widgets consult the config registry).
  @protected
  FormidableCodec<T, V>? resolveCodec() => widget.codec;

  /// The Field changed, before the widget rebuilds.
  @protected
  void didChangeField() {}

  /// The Codec changed, or was resolved for the first time. [initial] is true
  /// for the latter.
  @protected
  void didChangeCodec({required bool initial}) {}

  /// The widget shows another Field now (the old one was already released).
  @protected
  void didReplaceField() {}

  bool _codecResolved = false;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCodec();
  }

  @override
  void didUpdateWidget(FormidableFieldWidget<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field != widget.field ||
        oldWidget.focusNode != widget.focusNode) {
      final replacesField = oldWidget.field != widget.field;
      _detach();
      _attach();
      if (replacesField) didReplaceField();
    }
    _updateCodec();
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _errorDisplay =
        widget.errorDisplay ?? FormidableScope.errorDisplayOf(context);
    return widget.builder(context, this);
  }

  void _attach() {
    _field = widget.field;
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _field.addListener(_onFieldChanged);
    _focusNode.addListener(_onFocusChanged);
    _field.addFocusLayoutListener(_onFocusLayoutChanged);
    _unregisterFocus = _field.registerFocusTarget(_FocusNodeTarget(_focusNode));
    _hadFocus = _focusNode.hasFocus;
  }

  void _detach() {
    _field.removeFocusLayoutListener(_onFocusLayoutChanged);
    _field.removeListener(_onFieldChanged);
    _unregisterFocus();
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _updateCodec() {
    final next = resolveCodec();
    final initial = !_codecResolved;
    if (!initial && next == _codec) return;
    _codecResolved = true;
    _codec = next;
    didChangeCodec(initial: initial);
  }

  void _onFieldChanged() {
    didChangeField();
    if (mounted) setState(() {});
  }

  // Another widget of the Form appeared or went away. It can happen while the
  // tree builds, when setState is not allowed, so a change that arrives
  // mid-frame waits for the end of it.
  void _onFocusLayoutChanged() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      if (mounted) setState(() {});
      return;
    }
    scheduler.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    scheduler.ensureVisualUpdate();
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (_hadFocus && !hasFocus) _field.touch();
    _hadFocus = hasFocus;
  }
}

class _FocusNodeTarget implements FormidableFocusTarget {
  _FocusNodeTarget(this._focusNode);

  final FocusNode _focusNode;

  @override
  void focus() => _focusNode.requestFocus();

  @override
  void unfocus() => _focusNode.unfocus();
}

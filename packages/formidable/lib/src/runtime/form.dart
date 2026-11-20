import '../validation/validation_error.dart';
import 'field.dart';
import 'form_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'status.dart';
import 'submit_result.dart';

/// The live instance generated from a Schema [S].
///
/// A generated Form extends this class, creates its Fields, passes them to
/// [attach] once and implements [buildOutput]. Everything else, including
/// `submit()`, lives here.
abstract class FormidableForm<S>
    with FormidableNotifierMixin
    implements FormidableObservable<FormidableFormState> {
  List<FormidableNode> _nodes = const [];
  FormidableFormState _state = FormidableFormState(
    status: FormidableStatus.valid,
  );
  final List<void Function()> _changeListeners = [];

  /// The children of the Form, in Schema declaration order.
  List<FormidableNode> get nodes => _nodes;

  @override
  FormidableFormState get state => _state;

  /// The Schema instance while the Form is valid and not pending, null
  /// otherwise. It is computed on every read.
  S? get value {
    final state = _state;
    if (state.status != FormidableStatus.valid || state.pending) return null;
    return buildOutput();
  }

  /// Calls [listener] after every change of any child, even one that leaves
  /// [state] equal. A listener of [state] is called only when it differs, so
  /// use this to follow [value], which can change while [state] does not.
  void addChangeListener(void Function() listener) {
    assert(!isDisposed, 'Cannot add a listener to a disposed object.');
    _changeListeners.add(listener);
  }

  void removeChangeListener(void Function() listener) =>
      _changeListeners.remove(listener);

  /// Registers the children of the Form, in Schema declaration order. A
  /// generated Form calls it once from its constructor.
  void attach(List<FormidableNode> nodes) {
    assert(_nodes.isEmpty, 'attach must be called once.');
    _nodes = List.unmodifiable(nodes);
    for (final node in _nodes) {
      node.addListener(_onNodeChanged);
    }
    _state = _computeState();
  }

  /// Builds the Schema instance from the Fields. Called only when every Field
  /// is valid. Implemented by the generated Form.
  S buildOutput();

  /// Decides whether the Form is valid and builds the Schema instance.
  Future<FormidableSubmitResult<S>> submit() async {
    final errors =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    for (final node in _nodes) {
      node.collectErrors(errors);
    }
    if (errors.isNotEmpty) {
      return FormidableSubmitInvalid<S>(Map.unmodifiable(errors));
    }
    return FormidableSubmitValid<S>(buildOutput());
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.removeListener(_onNodeChanged);
      node.dispose();
    }
    _changeListeners.clear();
    super.dispose();
  }

  void _onNodeChanged() {
    final next = _computeState();
    if (next != _state) {
      _state = next;
      notifyListeners();
    }
    if (isDisposed) return;
    for (final listener in List.of(_changeListeners)) {
      if (_changeListeners.contains(listener)) listener();
    }
  }

  FormidableFormState _computeState() => FormidableFormState(
    status: _nodes.every((node) => node.isValid)
        ? FormidableStatus.valid
        : FormidableStatus.invalid,
    dirty: _nodes.any((node) => node.isDirty),
    pending: _nodes.any((node) => node.isPending),
  );
}

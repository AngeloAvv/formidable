import '../validation/validation_error.dart';
import 'effect.dart';
import 'field.dart';
import 'form_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'submit_result.dart';

/// The live instance generated from a Schema [S].
///
/// A generated Form extends this class, creates its Fields, passes them to
/// [attach] once and implements [buildOutput]. Everything else, including
/// `submit()`, lives here.
abstract class FormidableForm<S>
    with FormidableNotifierMixin
    implements FormidableObservable<FormidableFormState>, FormidablePipeline {
  /// How many times the Form Effects may run for one change before they are
  /// considered to be in a loop.
  static const _maxEffectPasses = 100;

  List<FormidableNode> _nodes = const [];
  List<FormidableEffect<FormidableForm<Object?>>> _effects = const [];
  final Set<FormidableNode> _pending = {};
  bool _running = false;
  FormidableFormState _state = const FormidableFormState(
    status: FormidableStatus.valid,
  );

  /// The children of the Form, in Schema declaration order.
  List<FormidableNode> get nodes => _nodes;

  @override
  FormidableFormState get state => _state;

  /// Registers the children of the Form, in Schema declaration order, and its
  /// Form [effects]. A generated Form calls it once from its constructor.
  ///
  /// The Effects run once before it returns, so the Form starts consistent.
  void attach(
    List<FormidableNode> nodes, {
    List<FormidableEffect<FormidableForm<Object?>>> effects = const [],
  }) {
    assert(_nodes.isEmpty, 'attach must be called once.');
    _nodes = List.unmodifiable(nodes);
    _effects = List.unmodifiable(effects);
    for (final node in _nodes) {
      node.bindPipeline(this);
    }
    _run(initial: true);
    for (final node in _nodes) {
      node.addListener(_onNodeChanged);
    }
    _state = _computeState();
  }

  @override
  void change(FormidableNode node, bool Function() mutate) {
    if (!mutate()) return;
    _pending.add(node);
    // An Effect wrote a Field: the running pass picks the change up.
    if (!_running) _run();
  }

  /// Runs the Form Effects until nothing changes, then validates every node.
  void _run({bool initial = false}) {
    _running = true;
    try {
      _runEffects(initial: initial);
    } finally {
      _running = false;
      _pending.clear();
      for (final node in _nodes) {
        node.revalidate();
      }
    }
  }

  void _runEffects({required bool initial}) {
    var changed = initial ? <FormidableNode>{} : _takePending();
    if (_effects.isEmpty) return;
    var passes = 0;
    do {
      if (++passes > _maxEffectPasses) {
        var debug = false;
        assert(debug = true);
        if (debug) {
          throw FormidableEffectLoopError(_effects, _maxEffectPasses);
        }
        return;
      }
      final context = FormidableEffectContext(changed);
      for (final effect in _effects) {
        effect.apply(this, context);
      }
      changed = _takePending();
    } while (changed.isNotEmpty);
  }

  Set<FormidableNode> _takePending() {
    final taken = Set<FormidableNode>.of(_pending);
    _pending.clear();
    return taken;
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
    super.dispose();
  }

  void _onNodeChanged() {
    final next = _computeState();
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  FormidableFormState _computeState() => FormidableFormState(
    status: _nodes.every((node) => node.isValid)
        ? FormidableStatus.valid
        : FormidableStatus.invalid,
  );
}

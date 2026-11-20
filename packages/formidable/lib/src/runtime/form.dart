import '../cross_field/rule.dart';
import '../validation/form_validator.dart';
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
  List<FormidableFormValidator<FormidableForm<Object?>>> _formValidators =
      const [];
  List<FormidableCrossFieldBinding> _crossFieldRules = const [];
  final Set<FormidableNode> _pending = {};
  bool _running = false;
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

  /// Registers the children of the Form, in Schema declaration order, its
  /// Form [effects], the [formValidators] declared on the Schema and the
  /// [crossFieldRules] declared on its Fields. A
  /// generated Form calls it once from its constructor, with itself as [F],
  /// which makes the compiler reject a Form Validator typed for another Form.
  ///
  /// The Effects run once before it returns, so the Form starts consistent.
  void attach<F extends FormidableForm<S>>(
    List<FormidableNode> nodes, {
    List<FormidableEffect<FormidableForm<Object?>>> effects = const [],
    List<FormidableFormValidator<F>> formValidators = const [],
    List<FormidableCrossFieldBinding> crossFieldRules = const [],
  }) {
    assert(_nodes.isEmpty, 'attach must be called once.');
    assert(this is F, 'attach must be given the type of the Form itself.');
    _nodes = List.unmodifiable(nodes);
    _effects = List.unmodifiable(effects);
    _formValidators = formValidators;
    _crossFieldRules = List.unmodifiable(crossFieldRules);
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
      _runFormValidators();
      for (final node in _nodes) {
        node.revalidate();
      }
    }
  }

  /// Runs the Form Validators and gives every Field the errors addressed to
  /// it. Each Field then commits them together with its own errors in
  /// `revalidate`, so listeners see the final errors in one notification.
  void _runFormValidators() {
    if (_formValidators.isEmpty && _crossFieldRules.isEmpty) return;
    final addressed =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    for (final validator in _formValidators) {
      // Safe at runtime: attach() only accepts validators typed on this Form.
      for (final item in validator.validate(this)) {
        assert(
          _nodes.contains(item.field),
          'A Form Validator addressed an error to a Field that is not in '
          'this Form.',
        );
        (addressed[item.field] ??= []).add(item.error);
      }
    }
    for (final binding in _crossFieldRules) {
      for (final error in binding.evaluate()) {
        (addressed[binding.target] ??= []).add(error);
      }
    }
    for (final node in _nodes) {
      if (node is FormidableField<Object?>) {
        node.replaceFormErrors(addressed[node] ?? const []);
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

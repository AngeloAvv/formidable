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
///
/// A Form is also a [FormidableNode], so it can be the child of another Form:
/// that is a Nested Form. A parent follows a Nested Form through
/// [addChangeListener], not [addListener], because it must hear about every
/// change below it, even one that leaves the state of the Nested Form equal.
abstract class FormidableForm<S>
    with FormidableNotifierMixin
    implements
        FormidableObservable<FormidableFormState>,
        FormidablePipeline,
        FormidableNode {
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
  int _batchDepth = 0;
  bool _needsSettle = false;
  int _held = 0;
  bool _heldChange = false;
  FormidableFormState _state = FormidableFormState(
    status: FormidableStatus.valid,
  );
  final List<void Function()> _changeListeners = [];
  FormidablePipeline? _parent;
  bool _optional = false;
  bool _initiallySet = true;
  List<FormidableValidationError> _formErrors = const [];

  /// The children of the Form, in Schema declaration order.
  List<FormidableNode> get nodes => _nodes;

  @override
  FormidableFormState get state => _state;

  /// The Schema instance while the Form is valid and not pending, null
  /// otherwise (and while an optional Nested Form is Unset). It is computed on
  /// every read.
  S? get value {
    final state = _state;
    if (!isSet || state.status != FormidableStatus.valid || state.pending) {
      return null;
    }
    return buildOutput();
  }

  /// Whether the Form holds a value, as opposed to being an Unset optional
  /// Nested Form. It is always true for a Form that is not an optional Nested
  /// Form.
  ///
  /// An optional Nested Form (a nullable Schema Field without `@Required()`)
  /// is Unset until something in it differs from its initial state, unless it
  /// was created from a Schema instance. It becomes Unset again when it is
  /// back at its initial state, so reset and patch need no special case.
  /// While it is Unset it is valid and has no output, whatever its Fields say.
  bool get isSet =>
      !_optional || _initiallySet || _nodes.any((node) => node.isDirty);

  /// The Schema instance a parent Form puts in its own output: [buildOutput],
  /// or null while an optional Nested Form is Unset. Called only when every
  /// Field of a set Form is valid.
  S? get outputOrNull => isSet ? buildOutput() : null;

  /// Makes this Form an optional Nested Form. Called by the generated parent
  /// Form, once, before [attach] of the parent.
  ///
  /// [initiallySet] says whether it starts as set (it was created from a
  /// Schema instance) or Unset.
  void markOptional({required bool initiallySet}) {
    assert(_parent == null, 'markOptional must be called before attach.');
    _optional = true;
    _initiallySet = initiallySet;
    _state = _computeState();
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

  /// Restores every Field to its initial value and presence, and forgets that
  /// it was touched. It notifies once and does not run the Form Effects: the
  /// initial state is already consistent.
  @override
  void reset() => batch(() {
    for (final node in _nodes) {
      node.reset();
    }
  });

  /// Makes the current state the new initial state, so the Form and its
  /// Fields are no longer dirty. It notifies once.
  @override
  void commit() => batch(() {
    // An optional Nested Form that is set now stays set: presence is part of
    // the initial state.
    _initiallySet = isSet;
    for (final node in _nodes) {
      node.commit();
    }
  });

  /// Makes every Field Unset, as one change. A Passthrough Field keeps its
  /// value because it can never be Unset. An optional Nested Form is Unset
  /// afterwards if it was Unset initially.
  void clear() => batch(() {
    for (final node in _nodes) {
      if (node is FormidableField<Object?>) {
        node.clear();
      } else if (node is FormidableForm<Object?>) {
        node.clear();
      }
    }
  });

  /// Runs [writes], which write Fields, as one change: the Form Effects run
  /// once after the last write and every listener is notified at most once.
  ///
  /// Generated `patch` and `replace` are built on it.
  void batch(void Function() writes) {
    // A Nested Form writes as part of its parent's change.
    final parent = _parent;
    if (parent is FormidableForm<Object?>) return parent.batch(writes);
    if (_batchDepth > 0 || _running) {
      writes();
      return;
    }
    _batchDepth++;
    try {
      writes();
    } finally {
      _batchDepth--;
      final settle = _needsSettle;
      _needsSettle = false;
      if (_pending.isNotEmpty) {
        _run();
      } else if (settle) {
        _settle();
      }
    }
  }

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
    // The initial state is what exists once the creation-time Effects ran.
    commit();
    for (final node in _nodes) {
      _follow(node);
    }
    _state = _computeState();
  }

  void _follow(FormidableNode node) => node is FormidableForm<Object?>
      ? node.addChangeListener(_onNodeChanged)
      : node.addListener(_onNodeChanged);

  void _unfollow(FormidableNode node) => node is FormidableForm<Object?>
      ? node.removeChangeListener(_onNodeChanged)
      : node.removeListener(_onNodeChanged);

  @override
  void change(FormidableNode node, bool Function() mutate) {
    // A Nested Form has no pipeline of its own: its parent runs everyone's
    // Effects, so one change settles the whole tree.
    final parent = _parent;
    if (parent != null) {
      return parent.change(node, () {
        if (!mutate()) return false;
        _formErrors = const [];
        return true;
      });
    }
    if (!mutate()) return;
    _formErrors = const [];
    _pending.add(node);
    // An Effect wrote a Field: the running pass picks the change up.
    if (!_running && _batchDepth == 0) _run();
  }

  @override
  List<FormidableField<Object?>> get focusOrder => [
    for (final node in _nodes)
      if (node is FormidableField<Object?>) node,
  ];

  @override
  void focusLayoutChanged() {
    for (final field in focusOrder) {
      field.notifyFocusLayout();
    }
  }

  @override
  void settle() {
    final parent = _parent;
    if (parent != null) return parent.settle();
    if (_running) return;
    if (_batchDepth > 0) {
      _needsSettle = true;
    } else {
      _settle();
    }
  }

  /// Runs the Form Effects until nothing changes, then validates every node.
  void _run({bool initial = false}) {
    _running = true;
    try {
      _runEffects(initial: initial);
    } finally {
      _running = false;
      _pending.clear();
      _settle();
    }
  }

  /// Runs the Form Validators, then revalidates every node, so every path that
  /// revalidates (a write, a batch, a reset, a commit) ends with up-to-date
  /// Form errors. Node notifications are held back and the Form notifies once
  /// afterwards.
  void _settle() {
    _holdTree(1);
    try {
      _runFormValidators();
      for (final node in _nodes) {
        node.revalidate();
      }
    } finally {
      _holdTree(-1);
    }
    _flushTree();
  }

  /// Holds back (or releases) the notifications of this Form and of its Nested
  /// Forms, so the whole tree notifies once per settle.
  void _holdTree(int delta) {
    _held += delta;
    for (final node in _nodes) {
      if (node is FormidableForm<Object?>) node._holdTree(delta);
    }
  }

  /// Publishes the state of the Nested Forms, then of this Form. A parent
  /// stays held while its children publish, so it publishes only once.
  void _flushTree() {
    _held++;
    try {
      for (final node in _nodes) {
        if (node is FormidableForm<Object?>) node._flushTree();
      }
    } finally {
      _held--;
    }
    _flush();
  }

  /// Runs the Form Validators of this Form and of its Nested Forms and gives
  /// every Field below this Form the errors addressed to it. Each Field then
  /// commits them together with its own errors in `revalidate`, so listeners
  /// see the final errors in one notification.
  ///
  /// A Form Validator can address any Field below its Form, Nested Forms
  /// included. An Unset optional Nested Form runs none: it is not validated.
  void _runFormValidators() {
    if (!_hasFormValidators) return;
    final addressed =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    _collectFormErrors(addressed);
    for (final field in _fieldsBelow()) {
      field.replaceFormErrors(addressed[field] ?? const []);
    }
  }

  bool get _hasFormValidators =>
      _formValidators.isNotEmpty ||
      _crossFieldRules.isNotEmpty ||
      _nodes.any(
        (node) => node is FormidableForm<Object?> && node._hasFormValidators,
      );

  void _collectFormErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {
    if (!isSet) return;
    if (_formValidators.isNotEmpty) {
      final fields = _fieldsBelow().toSet();
      for (final validator in _formValidators) {
        // Safe at runtime: attach() only accepts validators typed on this Form.
        for (final item in validator.validate(this)) {
          assert(
            fields.contains(item.field),
            'A Form Validator addressed an error to a Field that is not in '
            'this Form.',
          );
          (into[item.field] ??= []).add(item.error);
        }
      }
    }
    for (final binding in _crossFieldRules) {
      for (final error in binding.evaluate()) {
        (into[binding.target] ??= []).add(error);
      }
    }
    for (final node in _nodes) {
      if (node is FormidableForm<Object?>) node._collectFormErrors(into);
    }
  }

  /// Every Field of this Form and of its Nested Forms, in declaration order.
  Iterable<FormidableField<Object?>> _fieldsBelow() sync* {
    for (final node in _nodes) {
      if (node is FormidableField<Object?>) {
        yield node;
      } else if (node is FormidableForm<Object?>) {
        yield* node._fieldsBelow();
      }
    }
  }

  void _runEffects({required bool initial}) {
    var changed = initial ? <FormidableNode>{} : _takePending();
    if (!_hasEffects) return;
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
      _applyEffects(FormidableEffectContext(changed));
      changed = _takePending();
    } while (changed.isNotEmpty);
  }

  bool get _hasEffects =>
      _effects.isNotEmpty ||
      _nodes.any((node) => node is FormidableForm<Object?> && node._hasEffects);

  /// Runs the Effects of this Form, then those of its Nested Forms.
  void _applyEffects(FormidableEffectContext context) {
    for (final effect in _effects) {
      effect.apply(this, context);
    }
    for (final node in _nodes) {
      if (node is FormidableForm<Object?>) node._applyEffects(context);
    }
  }

  Set<FormidableNode> _takePending() {
    final taken = Set<FormidableNode>.of(_pending);
    _pending.clear();
    return taken;
  }

  /// Builds the Schema instance from the Fields. Called only when every Field
  /// is valid. Implemented by the generated Form.
  S buildOutput();

  /// Adds errors that only the caller can find, usually the answer of a
  /// server.
  ///
  /// [fieldErrors] are applied to their Fields, see
  /// [FormidableField.applyErrors]; the errors of a Field are replaced, and a
  /// Field that is missing from the map keeps its own. [formErrors] belong to
  /// the Form as a whole and show in [FormidableFormState.errors]; they replace
  /// the Form errors applied before.
  ///
  /// Both make the Form invalid. Field errors clear on the next change to that
  /// Field. Form errors clear on the next change to any Field, and when
  /// `submit()` starts.
  void applyErrors({
    Map<FormidableField<Object?>, List<FormidableValidationError>> fieldErrors =
        const {},
    List<FormidableValidationError> formErrors = const [],
  }) {
    _formErrors = List.unmodifiable(formErrors);
    fieldErrors.forEach((field, errors) => field.applyErrors(errors));
    _onNodeChanged();
  }

  /// Decides whether the Form is valid and builds the Schema instance.
  ///
  /// It first makes every Field touched and submitted, so that every error can
  /// show. When the Form is invalid it moves the focus to the first invalid
  /// Field in Schema declaration order that is enabled and shown by a widget.
  Future<FormidableSubmitResult<S>> submit() async {
    markSubmitted();
    final errors =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    collectErrors(errors);
    if (errors.isNotEmpty) {
      errors.keys.where((field) => field.canFocus).firstOrNull?.focus();
      return FormidableSubmitInvalid<S>(Map.unmodifiable(errors));
    }
    return FormidableSubmitValid<S>(buildOutput());
  }

  // FormidableNode, for a Form that is nested in another one.

  @override
  bool get isValid =>
      !isSet || (_formErrors.isEmpty && _nodes.every((node) => node.isValid));

  @override
  bool get isDirty => _nodes.any((node) => node.isDirty);

  @override
  bool get isPending => isSet && _nodes.any((node) => node.isPending);

  /// Marks every Field of a set Nested Form as touched and submitted, and
  /// drops its applied Form errors, like `submit()` does for the root Form. An
  /// Unset optional Nested Form is left alone, so it does not show errors for
  /// Fields the user never meant to fill in.
  @override
  void markSubmitted() {
    if (!isSet) return;
    if (_formErrors.isNotEmpty) {
      _formErrors = const [];
      _onNodeChanged();
    }
    for (final node in _nodes) {
      node.markSubmitted();
    }
  }

  /// Adds the errors of every Field below this Form to [into]. An Unset
  /// optional Nested Form has none: it is not part of the output.
  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {
    if (!isSet) return;
    for (final node in _nodes) {
      node.collectErrors(into);
    }
  }

  /// Makes this Form a Nested Form of the Form that owns [pipeline]: from now
  /// on its writes run through the parent. Called by the parent's [attach].
  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_parent == null, 'bindPipeline must be called once.');
    _parent = pipeline;
  }

  @override
  void revalidate() {
    for (final node in _nodes) {
      node.revalidate();
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      _unfollow(node);
      node.dispose();
    }
    _changeListeners.clear();
    super.dispose();
  }

  void _onNodeChanged() {
    _heldChange = true;
    if (_held == 0) _flush();
  }

  /// Publishes the Form state and calls the change listeners, if anything
  /// changed since the last time.
  void _flush() {
    final next = _computeState();
    final stateChanged = next != _state;
    if (!stateChanged && !_heldChange) return;
    _heldChange = false;
    if (stateChanged) {
      _state = next;
      notifyListeners();
    }
    if (isDisposed) return;
    for (final listener in List.of(_changeListeners)) {
      if (_changeListeners.contains(listener)) listener();
    }
  }

  FormidableFormState _computeState() => FormidableFormState(
    status: isValid ? FormidableStatus.valid : FormidableStatus.invalid,
    dirty: isDirty,
    pending: isPending,
    errors: _formErrors,
  );
}

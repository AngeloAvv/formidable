import 'dart:async';

import 'package:meta/meta.dart';

import '../cross_field/rule.dart';
import '../validation/async_form_validator.dart';
import '../validation/async_validator.dart';
import '../validation/form_validator.dart';
import '../validation/validation_error.dart';
import 'dynamic_form.dart';
import 'effect.dart';
import 'field.dart';
import 'field_array.dart';
import 'form_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'streams.dart';
import 'submit_result.dart';

/// The live instance generated from a Schema [S].
///
/// A generated Form extends this class, creates its Fields, passes them to
/// [attach] once and implements [buildOutput]. Everything else, including
/// `submit()`, lives here.
///
/// A Form is also a [FormidableNode], so it can be the child of another Form:
/// that is a Nested Form. Its [state] holds the state of every child, so a
/// listener of a Form hears about every change below it, and a parent follows a
/// Nested Form with [addListener] like it follows a Field.
///
/// A generated Form publishes a typed subclass of [FormidableFormState] (see
/// [buildState]) and narrows [state] to it.
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
  List<_AsyncFormRun> _asyncRuns = const [];
  final List<Completer<void>> _waiters = [];
  final Set<FormidableNode> _pending = {};
  bool _running = false;
  int _batchDepth = 0;
  bool _needsSettle = false;
  int _held = 0;
  FormidableFormState? _state;
  FormidablePipeline? _parent;
  bool _optional = false;
  bool _initiallyDefined = true;
  List<FormidableValidationError> _formErrors = const [];

  /// The children of the Form, in Schema declaration order.
  List<FormidableNode> get nodes => _nodes;

  /// The snapshot of the Form: its status, dirty and pending flags, its
  /// Form-level errors, its Schema value and the state of every child. It
  /// changes, and listeners are called, whenever anything below the Form
  /// changes.
  @override
  FormidableFormState get state => _state ??= _computeState();

  FormidableStreamHub? _streamHub;

  FormidableStreamHub get _hub =>
      _streamHub ??= FormidableStreamHub(this, () => isDisposed);

  /// Every state of the Form, as it changes: any Field below it, but also
  /// touched, errors, pending and the rest.
  ///
  /// It is a broadcast stream that delivers synchronously, right after the
  /// change, like [addListener]. It never emits the state the Form is in when
  /// you listen, it listens to the Form only while it has subscribers, and it
  /// closes when the Form is disposed. The same holds for [valueChanges],
  /// [statusChanges] and [select]. A generated Form types it after its state
  /// (`Stream<SignUpFormState>`).
  Stream<FormidableFormState> get changes =>
      _hub.derive(() => state, (state) => state, same: (_, _) => false);

  /// The state of the Form, each time the value or presence of a Field below
  /// it changes, including the Fields of Nested Forms, Field Arrays and Dynamic
  /// Forms: an item added, removed, moved or edited, a Field registered or
  /// removed, an optional Nested Form that becomes set or Unset.
  ///
  /// Touching a Field, submitting, focus, errors and pending are not value
  /// changes, and neither is the Form becoming valid on its own: it is not tied
  /// to [value], which has no value until the Form is valid. The event is the state,
  /// so the listener reads the Fields it cares about (`state.email.value`), or
  /// `state.meta.value` for the Schema instance when the Form is valid. A
  /// generated Form types it after its state.
  ///
  /// ```dart
  /// form.valueChanges.listen((state) => print(state.from.value));
  /// ```
  Stream<FormidableFormState> get valueChanges =>
      _hub.derive<List<Object?>, FormidableFormState>(
        () => valueKeyOf(this),
        (_) => state,
        same: sameValueKey,
      );

  /// The status of the Form, each time it changes between valid, invalid and
  /// pending.
  Stream<FormidableStatus> get statusChanges =>
      _hub.derive(() => state.meta.status, (status) => status);

  /// What [selector] returns for the state of the Form, each time it differs
  /// (by `==`) from what it returned before. The first selection is computed
  /// when you listen, so the first event is a real change. A generated Form
  /// hands the selector its typed state.
  ///
  /// ```dart
  /// form.select((state) => (state.from.value, state.to.value));
  /// ```
  Stream<R> select<R>(R Function(FormidableFormState state) selector) =>
      _hub.derive(() => selector(state), (selection) => selection);

  /// The Schema instance of the Form.
  ///
  /// Throws a [StateError] unless the Form is valid, not pending and set: an
  /// invalid Form has no value. Check `state.meta.valid` first, take the value
  /// from [submit], or read [valueOrNull]. It is the
  /// [FormidableFormMeta.value] of the current [state], so the Schema
  /// constructor runs on the first read after a change, not on every change.
  S get value => (state.meta as FormidableFormMeta<S>).value;

  /// The Schema instance while the Form is valid and not pending, null
  /// otherwise (and while an optional Nested Form is Unset). It is the
  /// [FormidableFormMeta.valueOrNull] of the current [state].
  S? get valueOrNull => (state.meta as FormidableFormMeta<S>).valueOrNull;

  /// Whether the Form holds a value, as opposed to being an Unset optional
  /// Nested Form. It is always true for a Form that is not an optional Nested
  /// Form.
  ///
  /// An optional Nested Form (a nullable Schema Field without `@Required()`)
  /// is Unset until something in it differs from its initial state, unless it
  /// was created from a Schema instance. It becomes Unset again when it is
  /// back at its initial state, so reset and patch need no special case.
  /// While it is Unset it is valid and has no output, whatever its Fields say.
  bool get defined =>
      !_optional || _initiallyDefined || _nodes.any((node) => node.isDirty);

  /// The Schema instance a parent Form puts in its own output: [buildOutput],
  /// or null while an optional Nested Form is Unset. Called only when every
  /// Field of a set Form is valid.
  S? get outputOrNull => defined ? buildOutput() : null;

  /// Makes this Form an optional Nested Form. Called by the generated parent
  /// Form, once, before [attach] of the parent.
  ///
  /// [initiallyDefined] says whether it starts as set (it was created from a
  /// Schema instance) or Unset.
  void markOptional({required bool initiallyDefined}) {
    assert(_parent == null, 'markOptional must be called before attach.');
    _optional = true;
    _initiallyDefined = initiallyDefined;
    _state = _computeState();
  }

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
    _initiallyDefined = defined;
    for (final node in _nodes) {
      node.commit();
    }
  });

  /// Makes every Field Unset, as one change. A Passthrough Field keeps its
  /// value because it can never be Unset. An optional Nested Form is Unset
  /// afterwards if it was Unset initially.
  void clear() => batch(() {
    for (final node in _flatNodes) {
      if (node is FormidableField<Object?>) {
        node.clear();
      } else if (node is FormidableForm<Object?>) {
        node.clear();
      } else if (node
          is FormidableFieldArray<FormidableNode, Object?, Object?>) {
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
  /// Form [effects], the [formValidators] declared on the Schema, the
  /// [crossFieldRules] declared on its Fields and its [asyncFormValidators]. A
  /// generated Form calls it once from its constructor, with itself as [F],
  /// which makes the compiler reject a Form Validator typed for another Form.
  ///
  /// The Effects run once before it returns, so the Form starts consistent.
  void attach<F extends FormidableForm<S>>(
    List<FormidableNode> nodes, {
    List<FormidableEffect<FormidableForm<Object?>>> effects = const [],
    List<FormidableFormValidator<F>> formValidators = const [],
    List<FormidableCrossFieldBinding> crossFieldRules = const [],
    List<FormidableAsyncFormValidator<F>> asyncFormValidators = const [],
  }) {
    assert(_nodes.isEmpty, 'attach must be called once.');
    assert(this is F, 'attach must be given the type of the Form itself.');
    _nodes = List.unmodifiable(nodes);
    _effects = List.unmodifiable(effects);
    _formValidators = formValidators;
    _crossFieldRules = List.unmodifiable(crossFieldRules);
    _asyncRuns = [
      for (final validator in asyncFormValidators)
        _AsyncFormRun(this, validator),
    ];
    for (final node in _nodes) {
      node.bindPipeline(this);
    }
    _run(initial: true);
    // The initial state is what exists once the creation-time Effects ran.
    commit();
    for (final node in _nodes) {
      node.addListener(_onNodeChanged);
    }
    _state = _computeState();
  }

  /// The children of the Form with every Dynamic Form replaced by what is
  /// registered in it, so the walks below see Fields and Nested Forms
  /// registered at runtime like declared ones, in registration order. Field
  /// Arrays stay one node: [_fieldsOf] and [_childForms] look into their items.
  Iterable<FormidableNode> get _flatNodes sync* {
    for (final node in _nodes) {
      if (node is FormidableDynamicForm) {
        yield* node.children;
      } else {
        yield node;
      }
    }
  }

  /// The Nested Forms right below this Form: its Nested Form children (also
  /// the ones registered in a Dynamic Form) and the Form items of its Field
  /// Arrays, in order.
  Iterable<FormidableForm<Object?>> get _childForms sync* {
    for (final node in _flatNodes) {
      switch (node) {
        case FormidableForm<Object?>():
          yield node;
        case FormidableFieldArray<FormidableNode, Object?, Object?>():
          for (final item in node.items) {
            if (item.node case final FormidableForm<Object?> form) yield form;
          }
        default:
      }
    }
  }

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

  /// Every Field of the whole Form in tree order: Schema declaration order,
  /// descending into Nested Forms and into the items of Field Arrays where
  /// they stand. A Nested Form hands out the order of the Form that owns it.
  @override
  List<FormidableField<Object?>> get focusOrder =>
      _parent?.focusOrder ?? _fieldsBelow().toList();

  @override
  void focusLayoutChanged() {
    final parent = _parent;
    if (parent != null) return parent.focusLayoutChanged();
    for (final field in _fieldsBelow().toList()) {
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
      if (_driveAsyncFormValidators()) {
        for (final node in _nodes) {
          node.revalidate();
        }
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
    for (final form in _childForms) {
      form._holdTree(delta);
    }
  }

  /// Publishes the state of the Nested Forms, then of this Form. A parent
  /// stays held while its children publish, so it publishes only once.
  void _flushTree() {
    _held++;
    try {
      for (final form in _childForms) {
        form._flushTree();
      }
    } finally {
      _held--;
    }
    _flush();
  }

  /// Runs the Form Validators of this Form and of its Nested Forms, after the
  /// Field Validators, and gives every Field below this Form the errors
  /// addressed to it. Each Field then
  /// commits them together with its own errors in `revalidate`, so listeners
  /// see the final errors in one notification.
  ///
  /// A Form Validator can address any Field below its Form, Nested Forms
  /// included. An Unset optional Nested Form runs none: it is not validated.
  void _runFormValidators() {
    if (!_hasFormValidators) return;
    final addressed =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    final fields = _fieldsBelow().toList();
    // The Field Validators run first: a Form Validator that reads the state of
    // a Field sees the errors of the current values.
    for (final field in fields) {
      field.refreshOwnState();
    }
    _collectFormErrors(addressed);
    for (final field in fields) {
      field.replaceFormErrors(addressed[field] ?? const []);
    }
  }

  bool get _hasFormValidators =>
      _formValidators.isNotEmpty ||
      _crossFieldRules.isNotEmpty ||
      _childForms.any((form) => form._hasFormValidators);

  void _collectFormErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
  ) {
    if (!defined) return;
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
    for (final form in _childForms) {
      form._collectFormErrors(into);
    }
  }

  /// Every Field of this Form, its Nested Forms and the items of its Field
  /// Arrays, in tree order. An Unset optional Nested Form counts: its Fields
  /// exist, whether or not a widget shows them.
  Iterable<FormidableField<Object?>> _fieldsBelow() sync* {
    for (final node in _flatNodes) {
      yield* _fieldsOf(node);
    }
  }

  static Iterable<FormidableField<Object?>> _fieldsOf(
    FormidableNode node,
  ) sync* {
    switch (node) {
      case FormidableField<Object?>():
        yield node;
      case FormidableForm<Object?>():
        yield* node._fieldsBelow();
      case FormidableFieldArray<FormidableNode, Object?, Object?>():
        for (final item in node.items) {
          yield* _fieldsOf(item.node);
        }
      default:
    }
  }

  /// The asynchronous Form Validators of this Form and of its Nested Forms.
  Iterable<_AsyncFormRun> _runsBelow() sync* {
    yield* _asyncRuns;
    for (final form in _childForms) {
      yield* form._runsBelow();
    }
  }

  /// Starts, keeps or cancels the check of every asynchronous Form Validator
  /// of this Form and its Nested Forms so that it matches the current values
  /// of its dependencies, then gives every Field the errors and the pending
  /// flag that result from it. Returns whether any Field has to be
  /// revalidated.
  bool _driveAsyncFormValidators() {
    final runs = _runsBelow().toList();
    if (runs.isEmpty) return false;
    for (final run in runs) {
      final owner = run.owner;
      final dependencies = run.validator.dependencies(owner);
      assert(
        dependencies.isNotEmpty,
        'An asynchronous Form Validator must depend on at least one Field.',
      );
      run.dependencies = dependencies;
      // An Unset optional Nested Form is not validated.
      if (!owner.defined ||
          !dependencies.every((field) => field.readyForFormCheck)) {
        run.cancel();
        continue;
      }
      final input = [for (final field in dependencies) field.valueOrNull];
      if (run.input != null && _sameValues(run.input!, input)) continue;
      run.cancel();
      run.input = input;
      run.pending = true;
      final token = run.token;
      run.timer = Timer(
        run.validator.debounce,
        () => owner._executeAsyncForm(run, token),
      );
    }
    var changed = false;
    for (final field in _fieldsBelow()) {
      final errors = <FormidableValidationError>[];
      var pending = false;
      for (final run in runs) {
        if (run.dependencies.contains(field) && run.pending) pending = true;
        for (final item in run.errors) {
          if (item.field == field) errors.add(item.error);
        }
      }
      field.replaceAsyncFormResult(errors, pending: pending);
      changed = true;
    }
    return changed;
  }

  Future<void> _executeAsyncForm(_AsyncFormRun run, int token) async {
    List<FormidableFieldError> errors;
    try {
      errors = await run.validator.validate(this);
    } on Object catch (error) {
      errors = [
        FormidableFieldError(
          run.dependencies.first,
          FormidableAsyncCheckFailedError(error),
        ),
      ];
    }
    // A newer value, a cancel or dispose made this result stale.
    if (token != run.token || isDisposed) return;
    run.timer = null;
    run.pending = false;
    run.errors = errors;
    final fields = _fieldsBelow().toSet();
    for (final item in errors) {
      assert(
        fields.contains(item.field),
        'An asynchronous Form Validator addressed an error to a Field that '
        'is not in this Form.',
      );
    }
    settle();
  }

  static bool _sameValues(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
      _effects.isNotEmpty || _childForms.any((form) => form._hasEffects);

  /// Runs the Effects of this Form, then those of its Nested Forms.
  void _applyEffects(FormidableEffectContext context) {
    for (final effect in _effects) {
      effect.apply(this, context);
    }
    for (final form in _childForms) {
      form._applyEffects(context);
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
    batch(
      () => fieldErrors.forEach((field, errors) => field.applyErrors(errors)),
    );
    _onNodeChanged();
  }

  /// Decides whether the Form is valid and builds the Schema instance.
  ///
  /// It first makes every Field touched and submitted, so that every error can
  /// show, then waits for every pending Async Validator, so that a value that
  /// was not checked yet never passes. The wait includes the debounce of the
  /// check, and it lasts until nothing is pending, even when a Field changes
  /// meanwhile. If the Form is disposed while it waits, the result is invalid
  /// with no errors. When the Form is invalid it moves the focus to the first invalid
  /// Field in Schema declaration order that is enabled and shown by a widget.
  Future<FormidableSubmitResult<S>> submit() async {
    markSubmitted();
    await _untilSettled();
    if (isDisposed) return FormidableSubmitInvalid<S>(const {});
    markSubmitted();
    final errors = <FormidableNode, List<FormidableValidationError>>{};
    collectErrors(errors);
    if (errors.isNotEmpty) {
      errors.keys
          .whereType<FormidableField<Object?>>()
          .where((field) => field.canFocus)
          .firstOrNull
          ?.focus();
      return FormidableSubmitInvalid<S>(Map.unmodifiable(errors));
    }
    return FormidableSubmitValid<S>(buildOutput());
  }

  /// Completes when no node is pending.
  Future<void> _untilSettled() async {
    while (_nodes.any((node) => node.isPending) && !isDisposed) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      void check() {
        if (!_nodes.any((node) => node.isPending) && !waiter.isCompleted) {
          waiter.complete();
        }
      }

      addListener(check);
      try {
        await waiter.future;
      } finally {
        removeListener(check);
        _waiters.remove(waiter);
      }
    }
  }

  // FormidableNode, for a Form that is nested in another one.

  @override
  @internal
  bool get isValid =>
      !defined || (_formErrors.isEmpty && _nodes.every((node) => node.isValid));

  @override
  @internal
  bool get isDirty => _nodes.any((node) => node.isDirty);

  @override
  @internal
  bool get isPending => defined && _nodes.any((node) => node.isPending);

  /// Marks every Field of a set Nested Form as touched and submitted, and
  /// drops its applied Form errors, like `submit()` does for the root Form. An
  /// Unset optional Nested Form is left alone, so it does not show errors for
  /// Fields the user never meant to fill in.
  @override
  void markSubmitted() {
    if (!defined) return;
    // Every Field changes, and the Form notifies once.
    _holdTree(1);
    try {
      if (_formErrors.isNotEmpty) {
        _formErrors = const [];
        _onNodeChanged();
      }
      for (final node in _nodes) {
        node.markSubmitted();
      }
    } finally {
      _holdTree(-1);
    }
    _flushTree();
  }

  /// Adds the errors of every Field and Field Array below this Form to [into].
  /// An Unset optional Nested Form has none: it is not part of the output.
  @override
  void collectErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
  ) {
    if (!defined) return;
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
    for (final run in _asyncRuns) {
      run.cancel();
    }
    for (final waiter in List.of(_waiters)) {
      if (!waiter.isCompleted) waiter.complete();
    }
    for (final node in _nodes) {
      node.removeListener(_onNodeChanged);
      node.dispose();
    }
    _streamHub?.close();
    super.dispose();
  }

  void _onNodeChanged() {
    if (_held == 0) _flush();
  }

  /// Publishes the Form state, and notifies, if it changed since the last
  /// time.
  void _flush() {
    final next = _computeState();
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  FormidableFormState _computeState() => buildState(
    status: !isValid
        ? FormidableStatus.invalid
        : isPending
        ? FormidableStatus.pending
        : FormidableStatus.valid,
    dirty: isDirty,
    pending: isPending,
    defined: defined,
    errors: _formErrors,
  );

  /// Builds the snapshot of the Form from the flags the runtime computed.
  ///
  /// A generated Form overrides it to return its own subclass of
  /// [FormidableFormState], adding the state of every child, which it reads
  /// from its Field handles, and a [FormidableFormMeta] whose value is built
  /// from those child states, so the snapshot never reads a Form that has
  /// moved on. The snapshot must be equal to the previous one when nothing
  /// below the Form changed, and must not run the Schema constructor: the
  /// value is lazy.
  ///
  /// The default builds a plain [FormidableFormState] whose value reads the
  /// Form when it is first asked for.
  FormidableFormState buildState({
    required FormidableStatus status,
    required bool dirty,
    required bool pending,
    required bool defined,
    required List<FormidableValidationError> errors,
  }) => FormidableFormState(
    meta: FormidableFormMeta<S>(
      status: status,
      dirty: dirty,
      pending: pending,
      defined: defined,
      errors: errors,
      buildValue: buildOutput,
    ),
  );
}

/// The state of one asynchronous Form Validator: the values it is checking or
/// has checked, its timer and its result.
final class _AsyncFormRun {
  _AsyncFormRun(this.owner, this.validator);

  final FormidableForm<Object?> owner;
  final FormidableAsyncFormValidator<FormidableForm<Object?>> validator;
  List<FormidableField<Object?>> dependencies = const [];
  Timer? timer;
  // Grows whenever the check is cancelled or restarted, so that the result of
  // an older check can tell that it is stale.
  int token = 0;
  List<Object?>? input;
  bool pending = false;
  List<FormidableFieldError> errors = const [];

  void cancel() {
    timer?.cancel();
    timer = null;
    token++;
    input = null;
    pending = false;
    errors = const [];
  }
}

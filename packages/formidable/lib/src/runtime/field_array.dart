import 'package:meta/meta.dart';
import '../validation/required_error.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field.dart';
import 'field_array_state.dart';
import 'form.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'streams.dart';

/// One entry of a [FormidableFieldArray]: the Nested Form or the Field that
/// holds the data, with an identifier that never changes and is never reused.
///
/// Use [id] as the key of the widget that shows the item, so that adding,
/// removing or moving items never hands the state of one row to another.
final class FormidableFieldArrayItem<N extends FormidableNode> {
  const FormidableFieldArrayItem(this.id, this.node);

  /// The stable identifier of the item, unique within its array.
  final int id;

  /// The Nested Form or the Field of the item.
  final N node;
}

/// An ordered collection of Nested Forms or Fields that can grow and shrink.
///
/// [N] is the type of every item (a generated Form or a [FormidableField]), [T]
/// is the type of the value of an item, so the output is a `List<T>`, and [S]
/// is the type of the state of an item (the generated state of a Nested Form or
/// a [FormidableFieldState]), which the array state holds.
///
/// An empty array is Unset, like a Field: it is required unless it is nullable
/// or has a default. It is a [FormidableNode] and follows the same rules as a
/// Nested Form: its writes run through the pipeline of its Form.
final class FormidableFieldArray<N extends FormidableNode, T, S>
    with FormidableNotifierMixin
    implements
        FormidableNode,
        FormidableObservable<FormidableFieldArrayState<S>> {
  /// Creates a Field Array.
  ///
  /// - [create] makes an item, from a value or, when it is null, empty.
  /// - [read] returns the value of an item. It is called only when the item is
  ///   valid.
  /// - [itemState] returns the current state of an item, which the state of
  ///   the array holds.
  /// - [readState] returns the value of an item from its state, like [read]
  ///   does from the item. The state of the array uses it to build the output
  ///   from the item states it holds, so a snapshot never reads an array that
  ///   has moved on.
  /// - [validators] judge the array as a whole while it has items. They receive
  ///   one entry per item: its value, or null while the item has none (an Unset
  ///   Field or a Nested Form that is not valid yet).
  /// - [required] is `@Required()`: an empty array blocks submit even if
  ///   [nullable] is true or [defaultValue] exists.
  /// - [defaultValue] is the list the array starts with when [initial] is null,
  ///   and the output while the array is empty.
  /// - [initial] is the starting list. Null starts the array empty (or with the
  ///   default).
  FormidableFieldArray({
    required N Function(T? initial) create,
    required T Function(N node) read,
    required S Function(N node) itemState,
    required T Function(S state) readState,
    List<FormidableValidator<Object?>> validators = const [],
    bool required = false,
    bool nullable = false,
    List<T>? defaultValue,
    List<T>? initial,
  }) : _create = create,
       _read = read,
       _itemState = itemState,
       _readState = readState,
       _validators = validators,
       _required = required,
       _nullable = nullable,
       _defaultValue = defaultValue {
    for (final value in initial ?? defaultValue ?? const []) {
      _items.add(_make(value));
    }
    _initialItems = List.of(_items);
    for (final item in _items) {
      _follow(item.node);
    }
    _state = _stateFor();
    _notified = _state;
  }

  final N Function(T? initial) _create;
  final T Function(N node) _read;
  final S Function(N node) _itemState;
  final T Function(S state) _readState;
  final List<FormidableValidator<Object?>> _validators;
  final bool _required;
  final bool _nullable;
  final List<T>? _defaultValue;
  final List<FormidableFieldArrayItem<N>> _items = [];
  late List<FormidableFieldArrayItem<N>> _initialItems;
  FormidablePipeline? _pipeline;
  int _nextId = 0;
  bool _touched = false;
  bool _submitted = false;
  bool _stale = false;
  late FormidableFieldArrayState<S> _state;
  late FormidableFieldArrayState<S> _notified;

  @override
  FormidableFieldArrayState<S> get state => _state;

  FormidableStreamHub? _streamHub;

  FormidableStreamHub get _hub =>
      _streamHub ??= FormidableStreamHub(this, () => isDisposed);

  /// Every state of the array, as it changes: its items, but also touched,
  /// errors and everything the states of its items hold.
  ///
  /// It is a broadcast stream that delivers synchronously, right after the
  /// change, like [addListener]. It never emits the state the array is in when
  /// you listen, it listens to the array only while it has subscribers, and it
  /// closes when the array is disposed. The same holds for [valueChanges],
  /// [statusChanges] and [select].
  Stream<FormidableFieldArrayState<S>> get changes =>
      _hub.derive(() => _state, (state) => state, same: (_, _) => false);

  /// The state of the array, each time an item is added, removed, moved or
  /// edited: the value or presence of any Field in any item changes, or the
  /// items or their order do. Touching, submitting and errors are not value
  /// changes.
  Stream<FormidableFieldArrayState<S>> get valueChanges =>
      _hub.derive<List<Object?>, FormidableFieldArrayState<S>>(
        () => valueKeyOf(this),
        (_) => _state,
        same: sameValueKey,
      );

  /// The status of the array, each time it changes between valid and invalid.
  /// The array is invalid when it has errors of its own or any item has.
  Stream<FormidableStatus> get statusChanges => _hub.derive(
    () => isValid ? FormidableStatus.valid : FormidableStatus.invalid,
    (status) => status,
  );

  /// What [selector] returns for the state of the array, each time it differs
  /// (by `==`) from what it returned before. The first selection is computed
  /// when you listen, so the first event is a real change.
  Stream<R> select<R>(
    R Function(FormidableFieldArrayState<S> state) selector,
  ) => _hub.derive(() => selector(_state), (selection) => selection);

  /// The items in order, each with its stable identifier. The list is a copy:
  /// it does not change when the array does.
  List<FormidableFieldArrayItem<N>> get items => List.unmodifiable(_items);

  /// How many items there are.
  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// The item at [index].
  FormidableFieldArrayItem<N> operator [](int index) => _items[index];

  /// Adds an item at the end, empty or from [value].
  void add([T? value]) => insert(_items.length, value);

  /// Adds an item at [index] (0 to [length]), empty or from [value].
  void insert(int index, [T? value]) {
    RangeError.checkValueInInterval(index, 0, _items.length, 'index');
    _write(() {
      _items.insert(index, _make(value));
      _follow(_items[index].node);
      return true;
    });
  }

  /// Removes the item at [index].
  void removeAt(int index) {
    RangeError.checkValidIndex(index, _items, 'index');
    _write(() {
      _release(_items.removeAt(index));
      return true;
    });
  }

  /// Removes [item]. Nothing happens when it is not in the array any more.
  void remove(FormidableFieldArrayItem<N> item) {
    final index = _items.indexOf(item);
    if (index >= 0) removeAt(index);
  }

  /// Moves the item at [from] so that it ends up at [to], and keeps its
  /// identifier.
  void move(int from, int to) {
    RangeError.checkValidIndex(from, _items, 'from');
    RangeError.checkValidIndex(to, _items, 'to');
    if (from == to) return;
    _write(() {
      _items.insert(to, _items.removeAt(from));
      return true;
    });
  }

  /// Removes every item, which makes the array Unset.
  void clear() {
    if (_items.isEmpty) return;
    _write(() {
      _items.toList().forEach(_release);
      _items.clear();
      return true;
    });
  }

  /// Replaces every item with a new one made from [values].
  void setValue(List<T> values) {
    if (_items.isEmpty && values.isEmpty) return;
    _write(() {
      _items.toList().forEach(_release);
      _items.clear();
      for (final value in values) {
        _items.add(_make(value));
        _follow(_items.last.node);
      }
      return true;
    });
  }

  /// Whether the array has items. An empty array is Unset.
  bool get defined => _items.isNotEmpty;

  /// The list the array contributes to the Schema instance: the value of every
  /// item. An empty array produces its default. Call it only when the array is
  /// valid: if an empty array has no default and is not nullable it has a
  /// required error and this throws.
  List<T> get output =>
      outputOrNull ??
      (throw StateError('A required Field Array is empty and has no output.'));

  /// Like [output], but null for an empty array without a default, which is
  /// what a nullable Schema field receives.
  List<T>? get outputOrNull {
    if (_items.isNotEmpty) return [for (final item in _items) _read(item.node)];
    final fallback = _defaultValue;
    return fallback == null ? null : List.of(fallback);
  }

  /// Records that the user interacted with the array.
  void touch() {
    if (_touched) return;
    _touched = true;
    _refresh();
  }

  // FormidableNode.

  @override
  @internal
  bool get isValid =>
      _state.errors.isEmpty && _items.every((item) => item.node.isValid);

  @override
  @internal
  bool get isDirty => _structureChanged || _items.any((i) => i.node.isDirty);

  @override
  @internal
  bool get isPending => _items.any((item) => item.node.isPending);

  @override
  void collectErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
  ) {
    if (_state.errors.isNotEmpty) into[this] = _state.errors;
    for (final item in _items) {
      item.node.collectErrors(into);
    }
  }

  @override
  void markSubmitted() {
    _touched = true;
    _submitted = true;
    for (final item in _items) {
      item.node.markSubmitted();
    }
    _refresh();
  }

  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_pipeline == null, 'bindPipeline must be called once.');
    _pipeline = pipeline;
    for (final item in {..._items, ..._initialItems}) {
      item.node.bindPipeline(pipeline);
    }
  }

  /// Puts back the items the array had at the start (or since the last
  /// [commit]), each at its initial state, and forgets that it was touched.
  /// Items added since are dropped. Form Effects do not run.
  @override
  void reset() {
    for (final item in _items) {
      _unfollow(item.node);
      if (!_initialItems.contains(item)) item.node.dispose();
    }
    _items
      ..clear()
      ..addAll(_initialItems);
    for (final item in _items) {
      item.node.reset();
      _follow(item.node);
    }
    _touched = false;
    _submitted = false;
    _stale = true;
    _settle();
  }

  /// Makes the current items and their values the new initial state.
  @override
  void commit() {
    for (final item in _initialItems) {
      if (!_items.contains(item)) item.node.dispose();
    }
    _initialItems = List.of(_items);
    for (final item in _items) {
      item.node.commit();
    }
    _stale = true;
    _settle();
  }

  @override
  void revalidate() {
    if (_stale) _refresh();
    for (final item in _items) {
      item.node.revalidate();
    }
  }

  @override
  void dispose() {
    for (final item in {..._items, ..._initialItems}) {
      _unfollow(item.node);
      item.node.dispose();
    }
    _streamHub?.close();
    super.dispose();
  }

  // Internals.

  FormidableFieldArrayItem<N> _make(T? value) {
    final item = FormidableFieldArrayItem<N>(_nextId++, _create(value));
    final pipeline = _pipeline;
    if (pipeline != null) item.node.bindPipeline(pipeline);
    return item;
  }

  /// Drops an item that left the array. One the array started with is kept
  /// aside, so that [reset] can bring it back.
  void _release(FormidableFieldArrayItem<N> item) {
    _unfollow(item.node);
    if (!_initialItems.contains(item)) item.node.dispose();
  }

  // The state of the array holds the state of its items, so following their
  // state is following every change below the array.
  void _follow(N node) => node.addListener(_onItemChanged);

  void _unfollow(N node) => node.removeListener(_onItemChanged);

  void _onItemChanged() => _refresh();

  bool get _structureChanged {
    if (_items.length != _initialItems.length) return true;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i] != _initialItems[i]) return true;
    }
    return false;
  }

  /// Runs [mutate], which changes the items and returns whether it did,
  /// through the Form pipeline, or on its own when the array is not part of a
  /// Form.
  void _write(bool Function() mutate) {
    final pipeline = _pipeline;
    bool structural() {
      final changed = mutate();
      if (changed) _stale = true;
      return changed;
    }

    if (pipeline == null) {
      if (structural()) _refresh();
    } else {
      pipeline.change(this, structural);
    }
  }

  void _settle() {
    final pipeline = _pipeline;
    if (pipeline == null) {
      _refresh();
    } else {
      pipeline.settle();
    }
  }

  void _refresh() {
    _stale = false;
    _state = _stateFor();
    final changed = _state != _notified;
    _notified = _state;
    if (changed) notifyListeners();
  }

  FormidableFieldArrayState<S> _stateFor() {
    final states = [for (final item in _items) _itemState(item.node)];
    final fallback = _defaultValue;
    return FormidableFieldArrayState<S>(
      ids: [for (final item in _items) item.id],
      items: states,
      errors: _errors(),
      touched: _touched,
      submitted: _submitted,
      dirty: isDirty,
      outputOrNull: () => states.isNotEmpty
          ? <T>[for (final state in states) _readState(state)]
          : fallback == null
          ? null
          : List<T>.of(fallback),
    );
  }

  List<FormidableValidationError> _errors() {
    if (_items.isEmpty) {
      final supplied = _defaultValue != null || _nullable;
      return _required || !supplied
          ? const [FormidableRequiredError()]
          : const [];
    }
    final values = [for (final item in _items) _peek(item.node)];
    return [for (final validator in _validators) ...validator.validate(values)];
  }

  /// The value of an item if it has one right now.
  static Object? _peek(FormidableNode node) => switch (node) {
    FormidableField<Object?>() => node.value,
    FormidableForm<Object?>() => node.value,
    _ => null,
  };
}

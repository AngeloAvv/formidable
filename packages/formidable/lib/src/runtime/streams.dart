import 'dart:async';
import 'dart:collection';

import 'dynamic_form.dart';
import 'field.dart';
import 'field_array.dart';
import 'form.dart';
import 'node.dart';
import 'notifier.dart';
import 'passthrough.dart';

/// Builds the streams of one node (a Field, a Form, a Field Array, a Dynamic
/// Form) out of the node's own listeners.
///
/// There is no notification channel of its own: every stream is one listener
/// of the node, added when the stream gets its first subscriber and removed
/// when it loses the last one, so a stream nobody listens to costs nothing. A
/// stream is broadcast and synchronous, like the listeners it rides on, and it
/// never emits the state the node was in when it was subscribed.
///
/// It is the machinery behind `changes`, `valueChanges`, `statusChanges` and
/// `select`, and it is internal: the library does not export it.
final class FormidableStreamHub {
  /// Creates the hub of [source], a node that notifies its listeners whenever
  /// its state changes. [isDisposed] says whether the node was disposed.
  FormidableStreamHub(this._source, this._isDisposed);

  final FormidableObservable<Object?> _source;
  final bool Function() _isDisposed;
  // The feeds that have subscribers. A feed nobody listens to is not kept, so
  // that a `select` that is created and dropped cannot leak.
  final Set<_Feed<Object?, Object?>> _active = {};
  bool _closed = false;

  /// Makes a stream that emits each time [key] returns something different
  /// from the last time, which is checked after every change of the node.
  ///
  /// - [key] reads what the stream follows. It is called when the stream gets
  ///   its first subscriber (that is the baseline, never an event) and then
  ///   after every change of the node.
  /// - [emit] makes the event out of the new key.
  /// - [same] says whether two keys are the same one; it defaults to `==`.
  ///   Pass `(_, _) => false` to emit after every change of the node.
  Stream<R> derive<K, R>(
    K Function() key,
    R Function(K key) emit, {
    bool Function(K previous, K next)? same,
  }) {
    if (_closed || _isDisposed()) return Stream<R>.empty(broadcast: true);
    return _Feed<K, R>(this, key, emit, same ?? (a, b) => a == b)._stream;
  }

  /// Closes every stream that has subscribers, and every stream made later.
  /// Called when the node is disposed.
  void close() {
    _closed = true;
    for (final feed in List.of(_active)) {
      feed._close();
    }
    _active.clear();
  }
}

/// One stream of a [FormidableStreamHub].
final class _Feed<K, R> {
  _Feed(this._hub, this._key, this._emit, this._same) {
    _controller = StreamController<R>.broadcast(
      sync: true,
      onListen: _attach,
      onCancel: _detach,
    );
  }

  final FormidableStreamHub _hub;
  final K Function() _key;
  final R Function(K key) _emit;
  final bool Function(K previous, K next) _same;
  late final StreamController<R> _controller;
  // Events that were made while another one was being delivered. A listener
  // may write to the node, which changes it again before the controller is done
  // with the first event, and a synchronous controller cannot take an event
  // while it is firing. The queue keeps the order and the event stays
  // synchronous for whoever made the first write.
  final Queue<R> _queue = Queue();
  late K _previous;
  bool _attached = false;
  bool _delivering = false;

  Stream<R> get _stream => _controller.stream;

  void _attach() {
    if (_hub._closed) {
      // Subscribed after the node was disposed: end right away.
      scheduleMicrotask(_controller.close);
      return;
    }
    _attached = true;
    _previous = _key();
    _hub._active.add(this);
    _hub._source.addListener(_onChange);
  }

  void _detach() {
    if (!_attached) return;
    _attached = false;
    _hub._source.removeListener(_onChange);
    _hub._active.remove(this);
    _queue.clear();
  }

  void _close() {
    _detach();
    _controller.close();
  }

  void _onChange() {
    final next = _key();
    if (_same(_previous, next)) return;
    _previous = next;
    _queue.add(_emit(next));
    if (_delivering) return;
    _delivering = true;
    try {
      while (_queue.isNotEmpty) {
        _controller.add(_queue.removeFirst());
      }
    } finally {
      _delivering = false;
    }
  }
}

/// What `valueChanges` compares for [node]: the value and presence of every
/// Field at or below it, and the shape of what holds them (the items of a Field
/// Array and their order, the keys of a Dynamic Form, whether a Nested Form is
/// set), flattened in tree order into [into].
///
/// It reads the published states, so it only sees what a listener sees, and it
/// leaves out everything that is not a value: touched, submitted, dirty,
/// pending, enabled and errors.
void collectValueKey(FormidableNode node, List<Object?> into) {
  switch (node) {
    case FormidableField<Object?>():
      into
        ..add(node.state.defined)
        ..add(node.state.value);
    case FormidablePassthrough<Object?>():
      into.add(node.value);
    case FormidableForm<Object?>():
      into.add(node.defined);
      for (final child in node.nodes) {
        collectValueKey(child, into);
      }
    case FormidableFieldArray<FormidableNode, Object?, Object?>():
      final items = node.items;
      into.add(items.length);
      for (final item in items) {
        into.add(item.id);
        collectValueKey(item.node, into);
      }
    case FormidableDynamicForm():
      final keys = node.keys;
      into.add(keys.length);
      final children = node.children.iterator;
      for (final key in keys) {
        children.moveNext();
        into.add(key);
        collectValueKey(children.current, into);
      }
    default:
  }
}

/// The key that `valueChanges` follows for [node], see [collectValueKey].
List<Object?> valueKeyOf(FormidableNode node) {
  final key = <Object?>[];
  collectValueKey(node, key);
  return key;
}

/// Whether two keys made by [valueKeyOf] are the same one.
bool sameValueKey(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

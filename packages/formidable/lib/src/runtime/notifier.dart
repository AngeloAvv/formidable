/// Something that holds an immutable state snapshot and notifies listeners
/// synchronously when that snapshot changes.
///
/// It has the same shape as Flutter's `ValueListenable`, which is what lets
/// `formidable_flutter` adapt it without any dependency here (ADR-0002).
abstract interface class FormidableObservable<S> {
  /// The current snapshot. Reading it never triggers a notification.
  S get state;

  void addListener(void Function() listener);

  void removeListener(void Function() listener);
}

/// Listener bookkeeping shared by Fields and Forms.
mixin FormidableNotifierMixin {
  final List<void Function()> _listeners = [];
  bool _disposed = false;

  /// Whether [dispose] has been called.
  bool get isDisposed => _disposed;

  void addListener(void Function() listener) {
    assert(!_disposed, 'Cannot add a listener to a disposed object.');
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// Calls every listener synchronously.
  void notifyListeners() {
    if (_disposed) return;
    for (final listener in List.of(_listeners)) {
      if (_listeners.contains(listener)) listener();
    }
  }

  /// Drops every listener. The object must not be used afterwards.
  void dispose() {
    _disposed = true;
    _listeners.clear();
  }
}

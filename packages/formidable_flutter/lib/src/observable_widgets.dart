import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

/// Whether [current] differs from [previous] enough to act on.
typedef FormidableStateCondition<S> = bool Function(S previous, S current);

/// Adapts any [FormidableObservable] to Flutter's [ValueListenable].
///
/// Notification stays synchronous: the adapter forwards the listener as is.
extension FormidableObservableAsValueListenable<S> on FormidableObservable<S> {
  /// A [ValueListenable] over the state of this Field or Form.
  ValueListenable<S> asValueListenable() => _ObservableListenable<S>(this);
}

final class _ObservableListenable<S> implements ValueListenable<S> {
  const _ObservableListenable(this._observable);

  final FormidableObservable<S> _observable;

  @override
  S get value => _observable.state;

  @override
  void addListener(VoidCallback listener) => _observable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _observable.removeListener(listener);

  @override
  bool operator ==(Object other) =>
      other is _ObservableListenable<S> && other._observable == _observable;

  @override
  int get hashCode => _observable.hashCode;
}

/// Rebuilds [builder] with the state of [observable] whenever it changes and
/// [buildWhen] agrees. Shared by the Field and Form Builders.
class ObservableBuilder<S> extends StatefulWidget {
  const ObservableBuilder({
    super.key,
    required this.observable,
    required this.builder,
    this.buildWhen,
  });

  final FormidableObservable<S> observable;
  final Widget Function(BuildContext context, S state) builder;
  final FormidableStateCondition<S>? buildWhen;

  @override
  State<ObservableBuilder<S>> createState() => _ObservableBuilderState<S>();
}

class _ObservableBuilderState<S> extends State<ObservableBuilder<S>> {
  late S _previous = widget.observable.state;
  late S _shown = _previous;

  @override
  void initState() {
    super.initState();
    widget.observable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(ObservableBuilder<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      oldWidget.observable.removeListener(_onChanged);
      widget.observable.addListener(_onChanged);
      _previous = _shown = widget.observable.state;
    }
  }

  @override
  void dispose() {
    widget.observable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final current = widget.observable.state;
    final previous = _previous;
    _previous = current;
    if (!mounted) return;
    if (widget.buildWhen?.call(previous, current) ?? true) {
      setState(() => _shown = current);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _shown);
}

/// Calls [listener] with each new state of [observable] while [listenWhen]
/// agrees. It never fires for the state present when it is first built.
class ObservableListener<S> extends StatefulWidget {
  const ObservableListener({
    super.key,
    required this.observable,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  final FormidableObservable<S> observable;
  final void Function(BuildContext context, S state) listener;
  final FormidableStateCondition<S>? listenWhen;
  final Widget child;

  @override
  State<ObservableListener<S>> createState() => _ObservableListenerState<S>();
}

class _ObservableListenerState<S> extends State<ObservableListener<S>> {
  late S _previous = widget.observable.state;

  @override
  void initState() {
    super.initState();
    widget.observable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(ObservableListener<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      oldWidget.observable.removeListener(_onChanged);
      widget.observable.addListener(_onChanged);
      _previous = widget.observable.state;
    }
  }

  @override
  void dispose() {
    widget.observable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final current = widget.observable.state;
    final previous = _previous;
    _previous = current;
    if (!mounted) return;
    if (widget.listenWhen?.call(previous, current) ?? true) {
      widget.listener(context, current);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Rebuilds [builder] only when `selector(state)` produces a different value
/// and [buildWhen] agrees.
class ObservableSelector<S, R> extends StatefulWidget {
  const ObservableSelector({
    super.key,
    required this.observable,
    required this.selector,
    required this.builder,
    this.buildWhen,
  });

  final FormidableObservable<S> observable;
  final R Function(S state) selector;
  final Widget Function(BuildContext context, R selected) builder;
  final FormidableStateCondition<R>? buildWhen;

  @override
  State<ObservableSelector<S, R>> createState() =>
      _ObservableSelectorState<S, R>();
}

class _ObservableSelectorState<S, R> extends State<ObservableSelector<S, R>> {
  late R _selected = widget.selector(widget.observable.state);

  @override
  void initState() {
    super.initState();
    widget.observable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(ObservableSelector<S, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      oldWidget.observable.removeListener(_onChanged);
      widget.observable.addListener(_onChanged);
    }
    _selected = widget.selector(widget.observable.state);
  }

  @override
  void dispose() {
    widget.observable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final next = widget.selector(widget.observable.state);
    if (!mounted || next == _selected) return;
    final previous = _selected;
    if (widget.buildWhen?.call(previous, next) ?? true) {
      setState(() => _selected = next);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _selected);
}

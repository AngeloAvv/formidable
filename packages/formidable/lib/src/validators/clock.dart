/// Where the date Validators read the current time.
///
/// Validators are const annotations, so they cannot receive a clock as a
/// constructor argument. They read [now] instead, and tests (or an app that
/// wants a server-synchronized time) replace the [source].
///
/// ```dart
/// setUp(() => FormidableClock.source = () => DateTime(2024, 6, 15));
/// tearDown(FormidableClock.reset);
/// ```
abstract final class FormidableClock {
  /// The function that returns the current time. It defaults to
  /// [DateTime.now].
  static DateTime Function() source = DateTime.now;

  /// The current time, as the Validators see it.
  static DateTime now() => source();

  /// Goes back to [DateTime.now].
  static void reset() => source = DateTime.now;

  /// Runs [body] with [clock] as the [source], then restores the previous one,
  /// even when [body] throws. It is for synchronous code only.
  static T withClock<T>(DateTime Function() clock, T Function() body) {
    final previous = source;
    source = clock;
    try {
      return body();
    } finally {
      source = previous;
    }
  }
}

import 'codec.dart';
import 'text_codecs.dart';

/// A registry of Codecs, chosen by the pair of types (the type of the Field
/// and the type the widget shows).
///
/// [defaults] covers `String`, `int`, `double`, `num` and `DateTime` to and
/// from text. A Field of a nullable type (`int?`) uses the Codec of its
/// non-nullable type. The registry is immutable: [add] returns a new one.
final class FormidableCodecs {
  const FormidableCodecs._(this._codecs);

  /// A registry with no Codec at all.
  const FormidableCodecs.empty() : _codecs = const [];

  /// The built-in Codecs, all to and from text.
  static const FormidableCodecs defaults = FormidableCodecs._([
    FormidableStringTextCodec(),
    FormidableIntTextCodec(),
    FormidableDoubleTextCodec(),
    FormidableNumTextCodec(),
    FormidableDateTimeTextCodec(),
  ]);

  final List<FormidableCodec<Object?, Object?>> _codecs;

  /// A registry with [codec] added. It wins over the Codecs already here for
  /// the same pair of types, and the Codec added last wins over the others.
  FormidableCodecs add(FormidableCodec<Object?, Object?> codec) =>
      FormidableCodecs._([..._codecs, codec]);

  /// The Codec between a Field of type [T] and a view of type [V], or null
  /// when none is registered.
  FormidableCodec<T, V>? find<T, V>() {
    for (final codec in _codecs.reversed) {
      final matches = codec.visit<bool>(
        <A, B>(_) => _same<B, V>() && (_same<A, T>() || _same<A?, T>()),
      );
      if (matches) return codec as FormidableCodec<T, V>;
    }
    return null;
  }

  static bool _same<X, Y>() => X == Y;

  /// Two registries are equal when they hold the same Codecs in the same
  /// order, so that a config rebuilt with the same registry is not a change.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormidableCodecs || other._codecs.length != _codecs.length) {
      return false;
    }
    for (var i = 0; i < _codecs.length; i++) {
      if (_codecs[i] != other._codecs[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_codecs);
}

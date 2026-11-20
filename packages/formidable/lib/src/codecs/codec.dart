import 'parse_result.dart';

/// A pure two-way conversion between the value of a Field ([T]) and the value
/// a widget shows and edits ([V]).
///
/// A Codec holds no state. [format] writes a value for the view and [parse]
/// reads what the view produced, which can be a value, nothing (Unset) or a
/// typed parse error.
///
/// To register a Codec for the whole app, add it to the `codecs` of a
/// `FormidableConfig`. To use one in a single widget, pass it to the widget.
abstract class FormidableCodec<T, V> {
  const FormidableCodec();

  /// What the view shows for [value].
  V format(T value);

  /// The result of reading [input] from the view.
  FormidableParseResult<T> parse(V input);

  /// Calls [visitor] with the type arguments of this Codec, which lets the
  /// registry compare them exactly instead of through subtyping.
  R visit<R>(R Function<A, B>(FormidableCodec<A, B> codec) visitor) =>
      visitor<T, V>(this);
}

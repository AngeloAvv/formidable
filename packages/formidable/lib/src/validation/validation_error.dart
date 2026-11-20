/// A typed description of why a Field is invalid.
///
/// It carries the data needed to explain the problem and it is separate from
/// the text shown to the user. [toString] is the last resort of the message
/// lookup, so it should read as a plain English sentence.
///
/// Two errors are equal when they have the same runtime type and the same
/// [props]. Subclasses that carry data override [props].
abstract class FormidableValidationError {
  const FormidableValidationError();

  /// The data that identifies this error, used for equality.
  List<Object?> get props => const [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormidableValidationError ||
        other.runtimeType != runtimeType) {
      return false;
    }
    final a = props;
    final b = other.props;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(props));
}

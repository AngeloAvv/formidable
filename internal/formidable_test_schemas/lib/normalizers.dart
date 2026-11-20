import 'package:formidable/formidable.dart';

part 'normalizers.formidable.dart';

/// Normalizer coverage: `@Trim()` on required, optional and validated Fields.
@Formidable()
class Contact {
  const Contact({
    required this.name,
    this.nickname,
    required this.handle,
    this.note,
  });

  /// Required text that is trimmed.
  @Trim()
  final String name;

  /// Optional text that is trimmed: whitespace only becomes Unset.
  @Trim()
  final String? nickname;

  /// Trimmed before the Validator sees it.
  @Trim()
  @MinLength(3)
  final String handle;

  /// No Normalizer: whitespace is a value.
  final String? note;
}

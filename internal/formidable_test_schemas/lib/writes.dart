import 'package:formidable/formidable.dart';

part 'writes.formidable.dart';

/// Programmatic writes coverage: patch, replace, reset and commit over a
/// Passthrough Field, a normalized Field and nullable Fields.
@Formidable()
class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.phone,
    this.note = 'none',
  });

  @Passthrough()
  final int id;

  @Trim()
  @MinLength(2)
  final String name;

  final String? phone;

  final String note;
}

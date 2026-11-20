import 'package:formidable/formidable.dart';

part 'passthrough.formidable.dart';

/// Passthrough coverage: required, defaulted and nullable Passthrough Fields.
@Formidable()
class EditUser {
  const EditUser({
    required this.id,
    required this.name,
    this.revision = 1,
    this.parentId,
  });

  /// Non-nullable without a default: a required constructor parameter.
  @Passthrough()
  final int id;

  final String name;

  /// With a default: optional parameter, starts at the default.
  @Passthrough()
  final int revision;

  /// Nullable: optional parameter, null when omitted.
  @Passthrough()
  final int? parentId;
}

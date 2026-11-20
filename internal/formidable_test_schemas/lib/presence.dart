import 'package:formidable/formidable.dart';

part 'presence.formidable.dart';

/// Presence coverage: every way a Field can be required or optional.
@Formidable()
class Presence {
  const Presence({
    this.nickname,
    this.bio = 'none',
    this.mood,
    required this.email,
    this.age = 18,
  });

  /// Nullable: optional, Unset produces null.
  final String? nickname;

  /// Default: Unset produces the default.
  final String bio;

  /// Nullable but `@Required()`: must be chosen, and null is a choice.
  @Required()
  final bool? mood;

  /// Non-nullable without a default: required.
  final String email;

  /// Non-nullable with a default and `@Required()`-less: optional.
  final int age;
}

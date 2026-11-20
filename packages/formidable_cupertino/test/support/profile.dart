import 'package:formidable/formidable.dart';

part 'profile.formidable.dart';

/// A custom Validation Error for a switch that must end up on.
final class MustBeOnError extends FormidableValidationError {
  const MustBeOnError();

  @override
  String toString() => 'Must be on.';
}

class MustBeOn extends FormidableValidator<bool> {
  const MustBeOn();

  @override
  List<FormidableValidationError> validate(bool value) =>
      value ? const [] : const [MustBeOnError()];
}

/// One Field per kind of widget, so that every widget has a Field to show.
@Formidable()
class Profile {
  const Profile({
    required this.username,
    this.age,
    required this.terms,
    required this.plan,
    required this.volume,
    this.born,
    this.alarm,
  });

  @MinLength(4)
  final String username;
  final int? age;
  @MustBeOn()
  final bool terms;
  final String plan;
  final double volume;
  final DateTime? born;
  final Duration? alarm;
}

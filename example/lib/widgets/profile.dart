import 'package:formidable/formidable.dart';
import 'package:material_ui/material_ui.dart';

part 'profile.formidable.dart';

enum Plan { free, plus, pro }

enum Layout { grid, list }

/// A Schema with one Field for every Material widget of `formidable_material`.
@Formidable()
class Profile {
  const Profile({
    required this.acceptedTerms,
    required this.notifications,
    required this.plan,
    required this.contactByEmail,
    required this.volume,
    required this.country,
    required this.birthday,
    required this.reminder,
    required this.layout,
  });

  /// A checkbox.
  final bool acceptedTerms;

  /// A switch.
  final bool notifications;

  /// A radio group of an enum.
  final Plan plan;

  /// A radio group where null means "no preference". `@Required()` makes the
  /// user choose one of the three options.
  @Required()
  final bool? contactByEmail;

  /// A slider.
  final double volume;

  /// A dropdown.
  final String country;

  /// A date picker.
  final DateTime birthday;

  /// A time picker.
  final TimeOfDay reminder;

  /// A segmented control.
  final Layout layout;
}

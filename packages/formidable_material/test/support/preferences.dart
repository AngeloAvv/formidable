import 'package:formidable/formidable.dart';
import 'package:material_ui/material_ui.dart';

part 'preferences.formidable.dart';

enum Plan { free, plus, pro }

/// One Field per kind of non-text widget. Every Field without a default is
/// required, so an Unset Field shows the required error once touched.
@Formidable()
class Preferences {
  const Preferences({
    required this.terms,
    required this.beta,
    required this.notifications,
    required this.size,
    required this.contact,
    required this.volume,
    required this.rating,
    required this.country,
    required this.birthday,
    required this.reminder,
    required this.layout,
    required this.graduation,
    required this.alarm,
  });

  /// A checkbox.
  final bool terms;

  /// A tristate checkbox: null is a choice.
  @Required()
  final bool? beta;

  /// A switch.
  final bool notifications;

  /// A radio group of an enum.
  final Plan size;

  /// A radio group where null is a choice ("no preference").
  @Required()
  final bool? contact;

  /// A slider on a double.
  final double volume;

  /// A slider on an int.
  final int rating;

  /// A dropdown.
  final String country;

  /// A date picker.
  final DateTime birthday;

  /// A time picker.
  final TimeOfDay reminder;

  /// A segmented control.
  final Plan layout;

  /// An optional date picker: null is a value.
  final DateTime? graduation;

  /// An optional time picker: null is a value.
  final TimeOfDay? alarm;
}

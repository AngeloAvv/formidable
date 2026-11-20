import 'package:formidable/formidable.dart';

part 'cupertino_preferences.formidable.dart';

/// The Schema behind the Cupertino widgets page: one Field for each widget.
@Formidable()
class CupertinoPreferences {
  const CupertinoPreferences({
    required this.name,
    this.age,
    required this.notifications,
    required this.newsletter,
    required this.plan,
    required this.billing,
    required this.size,
    required this.volume,
    this.born,
    this.alarm,
  });

  @MinLength(3)
  final String name;
  final int? age;
  final bool notifications;
  final bool newsletter;
  final String plan;
  final String billing;
  final String size;
  final double volume;
  final DateTime? born;
  final Duration? alarm;
}

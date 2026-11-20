import 'status.dart';

/// An immutable snapshot of a Form.
final class FormidableFormState {
  const FormidableFormState({required this.status});

  final FormidableStatus status;

  @override
  bool operator ==(Object other) =>
      other is FormidableFormState && other.status == status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'FormidableFormState(status: $status)';
}

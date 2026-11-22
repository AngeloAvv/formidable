import '../runtime/field.dart';
import '../runtime/form.dart';
import 'validation_error.dart';

/// An error addressed to one Field of a Form.
final class FormidableFieldError {
  const FormidableFieldError(this.field, this.error);

  /// The Field that receives [error].
  final FormidableField<Object?> field;

  final FormidableValidationError error;
}

/// A rule that reads several Fields of a Form and addresses errors to
/// specific Fields.
///
/// A Form Validator is a const class typed on the generated Form [F]. Declare
/// it as an annotation on the Schema class, next to `@Formidable()`.
///
/// It runs after the synchronous Field Validators, whenever any Field changes
/// and once when the Form is created. The errors it returns are added after
/// the Field's own errors and never replace them. Unlike a Field Validator it
/// runs whether or not the Fields have a value, so check `defined` on the
/// handles it reads.
abstract class FormidableFormValidator<F extends FormidableForm<Object?>> {
  const FormidableFormValidator();

  /// Returns the errors found in [form], or an empty list when it is valid.
  List<FormidableFieldError> validate(F form);
}

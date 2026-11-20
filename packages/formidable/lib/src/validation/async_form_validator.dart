import '../runtime/field.dart';
import '../runtime/form.dart';
import 'form_validator.dart';

/// An asynchronous Form Validator: a rule that reads several Fields and needs
/// time or an external service, for example "does this postal code belong to
/// this city?".
///
/// Like a [FormidableAsyncValidator] it is not const: you write the class with
/// its dependencies as constructor parameters and declare it on the Schema
/// with `@AsyncFormValidator<YourValidator>()`. The generated Form takes one
/// required, typed parameter for it.
///
/// It follows the lifecycle of a Field's Async Validators. It runs only while
/// every Field of [dependencies] has a value and passes its other Validators,
/// after [debounce] has elapsed without a change to any of them. Only the
/// latest result counts. Every dependency is pending while it runs, and
/// `submit()` waits for it. When a dependency becomes Unset or invalid the
/// check is cancelled and its errors go away.
abstract class FormidableAsyncFormValidator<F extends FormidableForm<Object?>> {
  const FormidableAsyncFormValidator();

  /// The Fields the check reads. A change to the value of any of them restarts
  /// the check. It must return the same Fields every time and at least one.
  List<FormidableField<Object?>> dependencies(F form);

  /// Returns the errors found in [form], addressed to Fields of the Form, or
  /// an empty list when it is valid. It reads the values of [dependencies]. If
  /// it throws, the first dependency gets a `FormidableAsyncCheckFailedError`.
  Future<List<FormidableFieldError>> validate(F form);

  /// How long the dependencies have to stay unchanged before the check starts.
  Duration get debounce => const Duration(milliseconds: 500);
}

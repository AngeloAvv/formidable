import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/custom_validators.dart';
import 'package:test/test.dart';

RegistrationForm _form() => RegistrationForm(
  password: 'long-enough',
  confirmation: 'long-enough',
  nickname: 'nickname1',
  handle: 'h',
);

void main() {
  group('custom Validator', () {
    test('runs on a chosen value and returns its typed error', () {
      final form = _form()..lucky.setValue(3);

      expect(form.lucky.state.errors, [const OddError(3)]);
    });

    test('does not run while the Field is Unset', () {
      final form = _form();

      expect(form.lucky.isSet, isFalse);
      expect(form.lucky.state.errors, isEmpty);
    });

    test('is skipped when null is chosen for a nullable Field', () {
      final form = _form()..lucky.setValue(null);

      expect(form.lucky.state.errors, isEmpty);
    });

    test('typed for a supertype of the Field type is applied', () {
      final form = _form()..handle.setValue('');

      expect(form.handle.state.errors, [const NoSpacesError()]);
    });
  });

  group('order of errors', () {
    test('follows the order of the annotations', () {
      final form = _form()
        ..password.setValue('a b')
        ..nickname.setValue('a b');

      expect(form.password.state.errors, [
        isA<FormidableMinLengthError>(),
        isA<NoSpacesError>(),
      ]);
      expect(form.nickname.state.errors, [
        isA<NoSpacesError>(),
        isA<FormidableMinLengthError>(),
      ]);
    });
  });

  group('Form Validator', () {
    test('adds an error to the Field handle it addresses', () {
      final form = _form()..confirmation.setValue('different-pass');

      expect(form.confirmation.state.errors, [
        const PasswordMismatchError(),
      ]);
      expect(form.password.state.errors, isEmpty);
    });

    test('keeps the Field errors and puts its own after them', () {
      final form = _form()..confirmation.setValue('short');

      expect(form.confirmation.state.errors, [
        isA<FormidableMinLengthError>(),
        const PasswordMismatchError(),
      ]);
    });

    test('re-runs when another Field it reads changes', () {
      final form = _form()..password.setValue('another-one');

      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);

      form.password.setValue('long-enough');

      expect(form.confirmation.state.errors, isEmpty);
    });

    test('is evaluated when the Form is created', () {
      final form = RegistrationForm(
        password: 'long-enough',
        confirmation: 'different-pass',
        nickname: 'nickname1',
        handle: 'h',
      );

      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
    });

    test('notifies the Form when only its errors change', () {
      final form = _form();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.password.setValue('another-one');

      expect(form.state.status, FormidableStatus.invalid);
      expect(notifications, greaterThan(0));
    });

    test('blocks submit and reports the error on the handle', () async {
      final form = _form()..confirmation.setValue('different-pass');

      final result = await form.submit() as FormidableSubmitInvalid<Registration>;

      expect(result.fieldErrors[form.confirmation], [
        const PasswordMismatchError(),
      ]);
    });

    test('submits once the Fields agree', () async {
      final form = _form();

      expect(await form.submit(), isA<FormidableSubmitValid<Registration>>());
    });
  });
}

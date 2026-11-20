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
    test('is updated after patch, with one notification', () {
      final form = _form();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.patch(confirmation: 'different-pass');

      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
      expect(notifications, 1);

      form.patch(password: 'different-pass');

      expect(form.confirmation.state.errors, isEmpty);
      expect(notifications, 2);
    });

    test('is updated after replace', () {
      final form = _form();

      form.replace(
        const Registration(
          password: 'long-enough',
          confirmation: 'different-pass',
          nickname: 'nickname1',
          handle: 'h',
        ),
      );

      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
    });

    test('is updated after reset', () {
      final form = _form()..confirmation.setValue('different-pass');
      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.reset();

      expect(form.confirmation.state.errors, isEmpty);
      expect(form.state.form.status, FormidableStatus.valid);
      expect(notifications, 1);
    });

    test('is updated after commit', () {
      final form = _form()..confirmation.setValue('different-pass');

      form.commit();
      form.reset();

      // The mismatching value is the committed one: reset keeps the error.
      expect(form.confirmation.value, 'different-pass');
      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
    });

    test('adds an error to the Field handle it addresses', () {
      final form = _form()..confirmation.setValue('different-pass');

      expect(form.confirmation.state.errors, [const PasswordMismatchError()]);
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

      expect(form.state.form.status, FormidableStatus.invalid);
      expect(notifications, greaterThan(0));
    });

    test('blocks submit and reports the error on the handle', () async {
      final form = _form()..confirmation.setValue('different-pass');

      final result =
          await form.submit() as FormidableSubmitInvalid<Registration>;

      expect(result.errors[form.confirmation], [const PasswordMismatchError()]);
    });

    test('submits once the Fields agree', () async {
      final form = _form();

      expect(await form.submit(), isA<FormidableSubmitValid<Registration>>());
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/profile.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:test/test.dart';

void main() {
  group('tracer bullet: one text Field end to end', () {
    test('a non-nullable Field without a default is required', () async {
      final form = SignUpForm();

      final result = await form.submit();

      expect(result, isA<FormidableSubmitInvalid<SignUp>>());
      final invalid = result as FormidableSubmitInvalid<SignUp>;
      expect(invalid.fieldErrors[form.username], [
        isA<FormidableRequiredError>(),
      ]);
    });

    test(
      '@MinLength produces a typed error when the value is too short',
      () async {
        final form = SignUpForm()..username.setValue('ab');

        final result = await form.submit();

        final invalid = result as FormidableSubmitInvalid<SignUp>;
        expect(invalid.fieldErrors[form.username], [
          const FormidableMinLengthError(minLength: 4, actualLength: 2),
        ]);
      },
    );

    test('a valid Form submits the Schema instance', () async {
      final form = SignUpForm()..username.setValue('angelo');

      final result = await form.submit();

      final valid = result as FormidableSubmitValid<SignUp>;
      expect(valid.value.username, 'angelo');
    });

    test(
      'the sealed result can be handled with an exhaustive switch',
      () async {
        final form = SignUpForm(username: 'angelo');

        final message = switch (await form.submit()) {
          FormidableSubmitValid(:final value) => 'valid ${value.username}',
          FormidableSubmitInvalid(:final fieldErrors) =>
            'invalid ${fieldErrors.length}',
        };

        expect(message, 'valid angelo');
      },
    );

    group('the Form constructors', () {
      test('from an existing Schema instance sets every Field', () {
        final form = SignUpForm.from(const SignUp(username: 'angelo'));

        expect(form.username.isSet, isTrue);
        expect(form.username.value, 'angelo');
      });

      test('the partial constructor prefills only the given Fields', () {
        final prefilled = SignUpForm(username: 'angelo');
        final omitted = SignUpForm();

        expect(prefilled.username.value, 'angelo');
        expect(omitted.username.isSet, isFalse);
        expect(omitted.username.value, isNull);
      });
    });

    group('Field state', () {
      test(
        'is an immutable snapshot with value, presence, errors and touched',
        () {
          final form = SignUpForm();
          final before = form.username.state;

          form.username.setValue('ab');

          expect(before.isSet, isFalse);
          expect(before.touched, isFalse);
          expect(before.errors, [isA<FormidableRequiredError>()]);
          final after = form.username.state;
          expect(after.value, 'ab');
          expect(after.isSet, isTrue);
          expect(after.status, FormidableStatus.invalid);
          expect(after.errors, [
            const FormidableMinLengthError(minLength: 4, actualLength: 2),
          ]);
        },
      );

      test('a valid value has no errors', () {
        final form = SignUpForm(username: 'angelo');

        expect(form.username.state.status, FormidableStatus.valid);
        expect(form.username.state.errors, isEmpty);
      });

      test('clear returns the Field to Unset', () {
        final form = SignUpForm(username: 'angelo')..username.clear();

        expect(form.username.isSet, isFalse);
        expect(form.username.state.errors, [isA<FormidableRequiredError>()]);
      });

      test('becomes touched once marked as touched', () {
        final form = SignUpForm();

        form.username.markAsTouched();

        expect(form.username.state.touched, isTrue);
      });
    });

    group('notifications', () {
      test('are synchronous and happen only when the state changes', () {
        final form = SignUpForm();
        var fieldNotifications = 0;
        var formNotifications = 0;
        form.username.addListener(() => fieldNotifications++);
        form.addListener(() => formNotifications++);

        form.username.setValue('ab');
        form.username.setValue('ab');
        form.username.markAsTouched();
        form.username.markAsTouched();

        expect(fieldNotifications, 2);
        // The Form became dirty once; touching changes nothing it reports.
        expect(formNotifications, 1);

        form.username.setValue('angelo');

        expect(fieldNotifications, 3);
        expect(formNotifications, 2);
        expect(form.state.status, FormidableStatus.valid);
      });

      test('stop after a listener is removed or the Form is disposed', () {
        final form = SignUpForm();
        var count = 0;
        void listener() => count++;
        form.username.addListener(listener);

        form.username.removeListener(listener);
        form.username.setValue('ab');
        expect(count, 0);

        form.username.addListener(listener);
        form.dispose();
        form.username.setValue('angelo');
        expect(count, 0);
      });
    });

    group('presence', () {
      test('a nullable Field left Unset produces null', () async {
        final form = ProfileForm(email: 'a@b.c');

        final valid = await form.submit() as FormidableSubmitValid<Profile>;

        expect(valid.value.nickname, isNull);
      });

      test(
        'a Field with a default starts with it and falls back to it',
        () async {
          final form = ProfileForm(email: 'a@b.c');
          expect(form.bio.value, '');
          expect(form.bio.isSet, isTrue);

          form.bio.setValue('hello');
          form.bio.clear();
          final valid = await form.submit() as FormidableSubmitValid<Profile>;

          expect(valid.value.bio, '');
        },
      );

      test('a Field set to null is different from an Unset Field', () {
        final form = ProfileForm(email: 'a@b.c')..nickname.setValue(null);

        expect(form.nickname.isSet, isTrue);
        expect(form.nickname.value, isNull);
        expect(ProfileForm(email: 'a@b.c').nickname.isSet, isFalse);
      });
    });
  });
}

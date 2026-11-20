import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/submit_flow.dart';
import 'package:test/test.dart';

final class _Taken extends FormidableValidationError {
  const _Taken();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'taken';
}

final class _Down extends FormidableValidationError {
  const _Down();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'down';
}

AccountForm _valid() =>
    AccountForm(username: 'angelo', password: 'secret-123', code: 'x');

void main() {
  group('applyErrors on a Field', () {
    test('adds the errors to the snapshot and makes the Field invalid', () {
      final form = _valid();

      form.applyErrors(
        fieldErrors: {
          form.username: [const _Taken()],
        },
      );

      expect(form.username.state.errors, [const _Taken()]);
      expect(form.username.state.status, FormidableStatus.invalid);
      expect(form.state.form.status, FormidableStatus.invalid);
      expect(form.value, isNull);
    });

    test('are added after the errors of the Validators', () {
      final form = _valid()..username.setValue('ab');

      form.username.applyErrors([const _Taken()]);

      expect(form.username.state.errors, hasLength(2));
      expect(form.username.state.errors.last, const _Taken());
    });

    test('blocks submit until the Field changes', () async {
      final form = _valid()..username.applyErrors([const _Taken()]);

      final result = await form.submit() as FormidableSubmitInvalid<Account>;
      expect(result.errors[form.username], [const _Taken()]);

      form.username.setValue('other');

      expect(await form.submit(), isA<FormidableSubmitValid<Account>>());
    });

    test('clear when that Field changes, and only then', () {
      final form = _valid()..username.applyErrors([const _Taken()]);

      form.password.setValue('another-secret');
      expect(form.username.state.errors, [const _Taken()]);

      form.username.setValue('other');
      expect(form.username.state.errors, isEmpty);
    });

    test('clear when the Field becomes Unset', () {
      final form = _valid()
        ..note.setValue('hi')
        ..note.applyErrors([const _Taken()]);

      form.note.clear();
      expect(form.note.state.errors, isEmpty);
    });

    test('survive a write that does not change the value', () {
      final form = _valid()..username.applyErrors([const _Taken()]);

      form.username.setValue('angelo');

      expect(form.username.state.errors, [const _Taken()]);
    });

    test('survive being touched', () {
      final form = _valid()..username.applyErrors([const _Taken()]);

      form.username.markAsTouched();

      expect(form.username.state.errors, [const _Taken()]);
    });

    test('notify the Field and the Form', () {
      final form = _valid();
      var fieldCount = 0;
      var formCount = 0;
      form.username.addListener(() => fieldCount++);
      form.addListener(() => formCount++);

      form.username.applyErrors([const _Taken()]);

      expect(fieldCount, 1);
      expect(formCount, 1);
    });

    test('are replaced by a later call, an empty list removes them', () {
      final form = _valid()
        ..username.applyErrors([const _Taken()])
        ..username.applyErrors([const _Down()]);
      expect(form.username.state.errors, [const _Down()]);

      form.username.applyErrors(const []);
      expect(form.username.state.errors, isEmpty);
    });

    test('are not shown while the Field is disabled', () {
      final form = _valid()
        ..username.applyErrors([const _Taken()])
        ..username.disable();

      expect(form.username.state.errors, isEmpty);
    });
  });

  group('applyErrors on the Form', () {
    test('adds Field errors and Form errors in one call', () {
      final form = _valid();

      form.applyErrors(
        fieldErrors: {
          form.username: [const _Taken()],
        },
        formErrors: [const _Down()],
      );

      expect(form.username.state.errors, [const _Taken()]);
      expect(form.state.form.errors, [const _Down()]);
      expect(form.state.form.status, FormidableStatus.invalid);
    });

    test('Form errors alone make the Form invalid and notify once', () {
      final form = _valid();
      var count = 0;
      form.addListener(() => count++);

      form.applyErrors(formErrors: [const _Down()]);

      expect(count, 1);
      expect(form.state.form.status, FormidableStatus.invalid);
      expect(form.value, isNull);
    });

    test('Form errors clear when any Field changes', () {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      form.note.setValue('hello');

      expect(form.state.form.errors, isEmpty);
      expect(form.state.form.status, FormidableStatus.valid);
    });

    test('Form errors survive a write that changes nothing', () {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      form.note.clear();
      form.username.setValue('angelo');

      expect(form.state.form.errors, [const _Down()]);
    });

    test('Form errors do not block a new submit, which clears them', () async {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      final result = await form.submit();

      expect(result, isA<FormidableSubmitValid<Account>>());
      expect(form.state.form.errors, isEmpty);
    });
  });
}

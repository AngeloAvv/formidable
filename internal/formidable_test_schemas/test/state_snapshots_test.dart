import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/passthrough.dart';
import 'package:formidable_test_schemas/profile.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:test/test.dart';

void main() {
  group('Field state snapshot', () {
    test('is dirty when the value differs from the initial state', () {
      final form = SignUpForm(username: 'angelo');
      expect(form.username.state.dirty, isFalse);

      form.username.setValue('other');
      expect(form.username.state.dirty, isTrue);

      form.username.setValue('angelo');
      expect(form.username.state.dirty, isFalse);
    });

    test('is dirty when presence differs from the initial state', () {
      final form = SignUpForm();
      expect(form.username.state.dirty, isFalse);

      form.username.setValue('a');
      expect(form.username.state.dirty, isTrue);

      form.username.clear();
      expect(form.username.state.dirty, isFalse);
    });

    test('a Field with a default starts clean and is dirty once cleared', () {
      final form = ProfileForm(email: 'a@b.c');
      expect(form.bio.state.dirty, isFalse);

      form.bio.clear();

      expect(form.bio.state.dirty, isTrue);
    });

    test('is enabled', () {
      expect(SignUpForm().username.state.enabled, isTrue);
    });

    test('equal snapshots compare equal and differ in dirty and enabled', () {
      final a = SignUpForm(username: 'x').username.state;
      final b = SignUpForm(username: 'x').username.state;
      final c = (SignUpForm(
        username: 'x',
      )..username.setValue('y')).username.state;

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('notifies when only dirty changes', () {
      final form = SignUpForm(username: 'angelo');
      var count = 0;
      form.username.addListener(() => count++);

      form.username.setValue('angelo');
      expect(count, 0);

      form.username.setValue('angelo2');
      form.username.setValue('angelo');
      expect(count, 2);
    });
  });

  group('Form state snapshot', () {
    test('has status, dirty, pending and Form-level errors', () {
      final form = SignUpForm();

      expect(form.state.form.status, FormidableStatus.invalid);
      expect(form.state.form.dirty, isFalse);
      expect(form.state.form.pending, isFalse);
      expect(form.state.form.errors, isEmpty);
    });

    test('is dirty while any Field is dirty and clean again afterwards', () {
      final form = ProfileForm(email: 'a@b.c');
      expect(form.state.form.dirty, isFalse);

      form.nickname.setValue('ange');
      expect(form.state.form.dirty, isTrue);

      form.nickname.clear();
      expect(form.state.form.dirty, isFalse);
    });

    test('a Passthrough Field makes the Form dirty when it changes', () {
      final form = EditUserForm(id: 1, name: 'a');
      expect(form.state.form.dirty, isFalse);

      form.id.setValue(2);
      expect(form.state.form.dirty, isTrue);

      form.id.setValue(1);
      expect(form.state.form.dirty, isFalse);
    });

    test('notifies on every change of the Form, in order', () {
      final form = SignUpForm();
      final seen = <FormidableFormState>[];
      form.addListener(() => seen.add(form.state));

      form.username.setValue('ab'); // dirty changes
      form.username.setValue('abc'); // still dirty and invalid
      form.username.setValue('angelo'); // valid
      form.username.markAsTouched(); // touched is part of the state now

      expect(seen.map((s) => (s.form.status, s.form.dirty)), [
        (FormidableStatus.invalid, true),
        (FormidableStatus.invalid, true),
        (FormidableStatus.valid, true),
        (FormidableStatus.valid, true),
      ]);
    });

    test('snapshots are immutable values', () {
      final form = SignUpForm();
      final before = form.state;

      form.username.setValue('angelo');

      expect(before.form.status, FormidableStatus.invalid);
      expect(form.state, isNot(before));
      expect(
        () => before.form.errors.add(const FormidableRequiredError()),
        throwsUnsupportedError,
      );
    });

    test('notifications are synchronous', () {
      final form = SignUpForm();
      FormidableStatus? seen;
      form.addListener(() => seen = form.state.form.status);

      form.username.setValue('angelo');

      expect(seen, FormidableStatus.valid);
    });
  });

  group('form.value', () {
    test('is null while the Form is invalid', () {
      final form = SignUpForm(username: 'ab');

      expect(form.value, isNull);
    });

    test('is the Schema instance while the Form is valid', () {
      final form = SignUpForm(username: 'angelo');

      expect(form.value?.username, 'angelo');
    });

    test('follows the Fields', () {
      final form = SignUpForm();
      expect(form.value, isNull);

      form.username.setValue('angelo');
      expect(form.value?.username, 'angelo');

      form.username.setValue('x');
      expect(form.value, isNull);
    });

    test('uses defaults and null for Unset optional Fields', () {
      final form = ProfileForm(email: 'a@b.c');

      final value = form.value!;

      expect(value.bio, '');
      expect(value.nickname, isNull);
      expect(value.email, 'a@b.c');
    });
  });
}

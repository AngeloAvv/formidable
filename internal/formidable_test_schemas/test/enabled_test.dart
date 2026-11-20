import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/submit_flow.dart';
import 'package:test/test.dart';

AccountForm _valid() =>
    AccountForm(username: 'angelo', password: 'secret-123', code: 'x');

void main() {
  group('Disabled Field', () {
    test('is enabled by default and can be disabled and enabled again', () {
      final form = _valid();
      expect(form.username.state.enabled, isTrue);

      form.username.disable();
      expect(form.username.state.enabled, isFalse);

      form.username.enable();
      expect(form.username.state.enabled, isTrue);
    });

    test('skips Validators', () {
      final form = _valid()..password.setValue('short');
      expect(form.password.state.errors, hasLength(1));

      form.password.disable();

      expect(form.password.state.errors, isEmpty);
      expect(form.state.status, FormidableStatus.valid);
    });

    test('validates again when it is enabled', () {
      final form = _valid()
        ..password.setValue('short')
        ..password.disable()
        ..password.enable();

      expect(form.password.state.errors, hasLength(1));
      expect(form.state.status, FormidableStatus.invalid);
    });

    test('keeps its value in the output', () async {
      final form = _valid()..username.disable();

      final result = await form.submit();

      expect(result, isA<FormidableSubmitValid<Account>>());
      expect(
        (result as FormidableSubmitValid<Account>).value.username,
        'angelo',
      );
      expect(form.value?.username, 'angelo');
    });

    test(
      'keeps its value in the output even when it would be invalid',
      () async {
        final form = _valid()
          ..password.setValue('short')
          ..password.disable();

        final result = await form.submit();

        expect(
          (result as FormidableSubmitValid<Account>).value.password,
          'short',
        );
      },
    );

    test('that is a Required Field and Unset still blocks submit', () async {
      final form = AccountForm(username: 'angelo', password: 'secret-123')
        ..code.disable();

      final result = await form.submit();

      expect(result, isA<FormidableSubmitInvalid<Account>>());
      expect(form.code.state.errors, [const FormidableRequiredError()]);
    });

    test(
      'that is a non-nullable Field and Unset still blocks submit',
      () async {
        final form = AccountForm(password: 'secret-123', code: 'x')
          ..username.disable();

        final result = await form.submit();

        expect(result, isA<FormidableSubmitInvalid<Account>>());
      },
    );

    test('that is optional and Unset produces null', () async {
      final form = _valid()..note.disable();

      final result = await form.submit() as FormidableSubmitValid<Account>;

      expect(result.value.note, isNull);
    });

    test('still accepts writes from code', () {
      final form = _valid()
        ..username.disable()
        ..username.setValue('other');

      expect(form.username.value, 'other');
    });

    test('notifies once and only when the state changes', () {
      final form = _valid();
      var count = 0;
      form.username.addListener(() => count++);

      form.username.enable();
      expect(count, 0);

      form.username.disable();
      expect(count, 1);

      form.username.disable();
      expect(count, 1);
    });

    test('is part of equal snapshots', () {
      final a = _valid();
      final b = _valid()..username.disable();

      expect(a.username.state, isNot(b.username.state));
    });
  });
}

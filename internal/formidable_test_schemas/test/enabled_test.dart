import 'package:fake_async/fake_async.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/async_validation.dart' as async_schema;
import 'package:formidable_test_schemas/cross_field.dart';
import 'package:formidable_test_schemas/custom_validators.dart';
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
  group('Disabled Field and rules that span Fields', () {
    test('drops the error of a cross-field rule', () {
      final form = PasswordChangeForm(password: 'a', confirmation: 'b');
      expect(form.confirmation.state.errors, [isA<FormidableMustMatchError>()]);

      form.confirmation.disable();

      expect(form.confirmation.state.errors, isEmpty);
      expect(form.state.status, FormidableStatus.valid);

      form.confirmation.enable();

      expect(form.confirmation.state.errors, [isA<FormidableMustMatchError>()]);
    });

    test('drops the error of a Form Validator', () {
      final form = RegistrationForm(
        password: 'password-1',
        confirmation: 'password-2',
        nickname: 'nick',
        handle: 'h',
      );
      expect(
        form.confirmation.state.errors,
        contains(const PasswordMismatchError()),
      );

      form.confirmation.disable();

      expect(form.confirmation.state.errors, isEmpty);
    });

    test('drops the error of an asynchronous Form Validator', () {
      fakeAsync((async) {
        final validator = async_schema.PostalCodeMatchesCity();
        final form = async_schema.ShippingForm(
          postalCode: '70121',
          city: 'Roma',
          note: 'n',
          postalCodeMatchesCity: validator,
        );
        async.elapse(const Duration(milliseconds: 300));
        validator.answer('70121/Roma', mismatch: true);
        async.flushMicrotasks();
        expect(form.city.state.errors, [
          const async_schema.CityMismatchError(),
        ]);

        form.city.disable();

        expect(form.city.state.errors, isEmpty);
        expect(form.city.state.pending, isFalse);
      });
    });

    test('still follows the presence rules when it is Unset and required', () {
      final form = PasswordChangeForm(password: 'a');

      form.confirmation.disable();

      expect(form.confirmation.state.errors, [isA<FormidableRequiredError>()]);
      expect(form.state.status, FormidableStatus.invalid);
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/nested.dart';
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
      expect(form.state.meta.status, FormidableStatus.invalid);
      expect(form.valueOrNull, isNull);
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

      form.username.touch();

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
      expect(form.state.meta.errors, [const _Down()]);
      expect(form.state.meta.status, FormidableStatus.invalid);
    });

    test('Form errors alone make the Form invalid and notify once', () {
      final form = _valid();
      var count = 0;
      form.addListener(() => count++);

      form.applyErrors(formErrors: [const _Down()]);

      expect(count, 1);
      expect(form.state.meta.status, FormidableStatus.invalid);
      expect(form.valueOrNull, isNull);
    });

    test('Form errors clear when any Field changes', () {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      form.note.setValue('hello');

      expect(form.state.meta.errors, isEmpty);
      expect(form.state.meta.status, FormidableStatus.valid);
    });

    test('Form errors survive a write that changes nothing', () {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      form.note.clear();
      form.username.setValue('angelo');

      expect(form.state.meta.errors, [const _Down()]);
    });

    test('Form errors do not block a new submit, which clears them', () async {
      final form = _valid()..applyErrors(formErrors: [const _Down()]);

      final result = await form.submit();

      expect(result, isA<FormidableSubmitValid<Account>>());
      expect(form.state.meta.errors, isEmpty);
    });
  });

  group('applyErrors with clearOn', () {
    test('clear when a listed Field changes, and not before', () {
      final form = _valid();
      form.password.applyErrors(
        const [_Taken()],
        clearOn: [form.username, form.note],
      );

      form.code.setValue('y');
      expect(form.password.state.errors, [const _Taken()]);

      form.username.touch();
      expect(form.password.state.errors, [const _Taken()]);

      form.username.setValue('other');
      expect(form.password.state.errors, isEmpty);
    });

    test('the second listed Field clears them too', () {
      final form = _valid();
      form.password.applyErrors(
        const [_Taken()],
        clearOn: [form.username, form.note],
      );

      form.note.setValue('hi');

      expect(form.password.state.errors, isEmpty);
    });

    test('still clear on the own change of the Field', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.password.setValue('another-secret');

      expect(form.password.state.errors, isEmpty);
      expect(form.password.clearOnCount, 0);
    });

    test('a write that changes nothing does not clear them', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.username.setValue('angelo');

      expect(form.password.state.errors, [const _Taken()]);
    });

    test('clearing notifies the Form once', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      var count = 0;
      form.addListener(() => count++);

      form.username.setValue('other');

      expect(count, 1);
      expect(form.state.meta.status, FormidableStatus.valid);
    });

    test('clear inside a batch', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.batch(() => form.username.setValue('other'));

      expect(form.password.state.errors, isEmpty);
    });

    test('replacing the errors drops the old subscriptions', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      form.password.applyErrors(const [_Down()], clearOn: [form.note]);

      form.username.setValue('other');
      expect(form.password.state.errors, [const _Down()]);

      form.note.setValue('hi');
      expect(form.password.state.errors, isEmpty);
    });

    test('replacing the errors without clearOn drops them all', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      form.password.applyErrors(const [_Down()]);

      form.username.setValue('other');

      expect(form.password.state.errors, [const _Down()]);
    });

    test('release every listener when the errors go away or are replaced', () {
      final form = _valid();
      final base = form.username.hasListeners;
      expect(base, isTrue); // the Form itself.

      var listeners = 0;
      void count() => listeners++;
      form.username.addListener(count);
      form.username.removeListener(count);

      for (var i = 0; i < 5; i++) {
        form.password.applyErrors(
          const [_Taken()],
          clearOn: [form.username, form.note],
        );
        expect(form.password.clearOnCount, 2);
      }
      form.password.applyErrors(const []);
      expect(form.password.clearOnCount, 0);

      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      form.username.setValue('other');
      expect(form.password.clearOnCount, 0);

      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      form.password.setValue('another-secret');
      expect(form.password.clearOnCount, 0);
      expect(listeners, 0);
    });

    test('no listener is left on the listed node', () {
      final form = _valid();
      final lone = FormidableField<String>();
      final target = FormidableField<String>(initial: (value: 'x'));
      final before = lone.hasListeners;

      target.applyErrors(const [_Taken()], clearOn: [lone]);
      expect(lone.hasListeners, isTrue);

      target.applyErrors(const []);
      expect(lone.hasListeners, before);

      target.applyErrors(const [_Taken()], clearOn: [lone]);
      lone.setValue('y');
      expect(target.state.errors, isEmpty);
      expect(lone.hasListeners, before);
      form.dispose();
    });

    test('dispose releases the subscriptions', () {
      final lone = FormidableField<String>();
      final target = FormidableField<String>(initial: (value: 'x'));
      target.applyErrors(const [_Taken()], clearOn: [lone]);
      expect(lone.hasListeners, isTrue);

      target.dispose();

      expect(lone.hasListeners, isFalse);
      expect(target.clearOnCount, 0);
    });

    test('disposing the Form releases them and a later change is harmless', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.dispose();

      expect(form.password.clearOnCount, 0);
    });

    test('a Field listed in its own clearOn is ignored', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.password]);

      expect(form.password.clearOnCount, 0);
      expect(form.password.state.errors, [const _Taken()]);
    });

    test('no errors, no subscription', () {
      final form = _valid();
      form.password.applyErrors(const [], clearOn: [form.username]);

      expect(form.password.clearOnCount, 0);
    });

    test('a Nested Form is a source: a change below it clears them', () {
      final form = OrderForm(
        title: 'x',
        owner: const Contact(
          name: 'Ann',
          home: Address(street: 'Main'),
        ),
      );
      form.title.applyErrors(const [_Taken()], clearOn: [form.owner]);

      form.owner.name.touch();
      expect(form.title.state.errors, [const _Taken()]);

      form.owner.home.street.setValue('Other');
      expect(form.title.state.errors, isEmpty);
    });

    test('a Field Array is a source: add and edit clear them', () {
      final form = CompanyForm(name: 'Acme');
      form.name.applyErrors(const [_Taken()], clearOn: [form.teams]);
      expect(form.name.state.errors, [const _Taken()]);

      form.teams.add();
      expect(form.name.state.errors, isEmpty);

      form.name.applyErrors(const [_Taken()], clearOn: [form.teams]);
      form.teams.remove(form.teams.items.first);
      expect(form.name.state.errors, isEmpty);
    });

    test('survive disabling and enabling the Form, and hide meanwhile', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.disable();
      expect(form.password.state.errors, isEmpty);
      expect(form.password.clearOnCount, 1);

      form.enable();
      expect(form.password.state.errors, [const _Taken()]);
    });

    test('a change of a listed Field clears them while disabled', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);
      form.disable();

      form.username.setValue('other');
      form.enable();

      expect(form.password.state.errors, isEmpty);
      expect(form.password.clearOnCount, 0);
    });

    test('touch and untouch of the Form do not clear them', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.touch();
      form.untouch();

      expect(form.password.state.errors, [const _Taken()]);
      expect(form.password.clearOnCount, 1);
    });

    test('reset drops them and releases the subscriptions', () {
      final form = _valid();
      form.password.applyErrors(const [_Taken()], clearOn: [form.username]);

      form.reset();

      expect(form.password.state.errors, isEmpty);
      expect(form.password.clearOnCount, 0);
    });

    test('reset(to:) drops them and releases the subscriptions', () {
      final form = _valid();
      form.password.applyErrors(
        const [_Taken()],
        clearOn: [form.username, form.note],
      );

      // The password keeps its value: only the reset clears the errors.
      form.reset(
        to: const Account(
          username: 'angelo',
          password: 'secret-123',
          code: 'x',
        ),
      );

      expect(form.password.state.errors, isEmpty);
      expect(form.password.clearOnCount, 0);
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:formidable_test_schemas/submit_flow.dart';
import 'package:test/test.dart';

void main() {
  group('Disabled Form', () {
    late AccountForm form;

    setUp(() {
      form = AccountForm(username: 'angelo', password: 'secret-123', code: 'x');
    });

    tearDown(() => form.dispose());

    test('is enabled by default and reports it in meta', () {
      expect(form.state.meta.enabled, isTrue);
      expect(form.username.state.enabled, isTrue);
    });

    test('disables every Field without touching their own flags', () {
      form.disable();

      expect(form.state.meta.enabled, isFalse);
      expect(form.username.state.enabled, isFalse);
      expect(form.password.state.enabled, isFalse);
      expect(form.note.state.enabled, isFalse);
    });

    test('enable() restores a Field that was disabled on its own', () {
      form.username.disable();
      form.disable();
      form.enable();

      expect(form.state.meta.enabled, isTrue);
      expect(form.username.state.enabled, isFalse);
      expect(form.password.state.enabled, isTrue);
    });

    test('a Field enabled while the Form is disabled stays disabled', () {
      form.username.disable();
      form.disable();
      form.username.enable();

      expect(form.username.state.enabled, isFalse);

      form.enable();

      expect(form.username.state.enabled, isTrue);
    });

    test('behaves like a Field disabled on its own', () async {
      form.password.setValue('short');
      expect(form.state.meta.status, FormidableStatus.invalid);

      form.disable();

      expect(form.password.state.errors, isEmpty);
      expect(form.state.meta.status, FormidableStatus.valid);

      form.enable();

      expect(form.password.state.errors, hasLength(1));
      expect(form.state.meta.status, FormidableStatus.invalid);
    });

    test('hides applied errors and shows them again once enabled', () {
      form.username.applyErrors(const [FormidableRequiredError()]);
      expect(form.username.state.errors, isNotEmpty);

      form.disable();
      expect(form.username.state.errors, isEmpty);

      form.enable();
      expect(form.username.state.errors, isNotEmpty);
    });

    test('an Unset required Field still blocks submit', () async {
      final unset = AccountForm(username: 'angelo', password: 'secret-123')
        ..disable();

      final result = await unset.submit();

      expect(result, isA<FormidableSubmitInvalid<Account>>());
      unset.dispose();
    });

    test('keeps the values in the output', () async {
      form.disable();

      final result = await form.submit();

      expect(
        (result as FormidableSubmitValid<Account>).value.username,
        'angelo',
      );
    });

    test('notifies once per call', () {
      var calls = 0;
      form.addListener(() => calls++);

      form.disable();
      expect(calls, 1);

      form.disable();
      expect(calls, 1, reason: 'already disabled');

      form.enable();
      expect(calls, 2);
    });

    test('a Field listener is notified once too', () {
      var calls = 0;
      form.username.addListener(() => calls++);

      form.disable();

      expect(calls, 1);
    });

    test('a disabled Field is not focusable', () {
      form.disable();

      expect(form.username.canFocus, isFalse);
    });
  });

  group('Disabled containers', () {
    late ItineraryForm form;

    setUp(() {
      form = ItineraryForm();
      form.phones.add();
      form.extras.register<String>('note');
    });

    tearDown(() => form.dispose());

    test('disabling a Nested Form disables its Fields only', () {
      form.contact.disable();

      expect(form.contact.state.meta.enabled, isFalse);
      expect(form.contact.street.state.enabled, isFalse);
      expect(form.title.state.enabled, isTrue);
      expect(form.state.meta.enabled, isTrue);

      form.contact.enable();

      expect(form.contact.street.state.enabled, isTrue);
    });

    test(
      'a Nested Form inside a disabled Form reports the effective value',
      () {
        form.disable();

        expect(form.contact.state.meta.enabled, isFalse);
        expect(form.contact.street.state.enabled, isFalse);

        // Its own flag is still on: enabling the parent brings it back.
        form.enable();

        expect(form.contact.state.meta.enabled, isTrue);
        expect(form.contact.street.state.enabled, isTrue);
      },
    );

    test('a Nested Form disabled on its own stays disabled after the parent '
        'is enabled', () {
      form.contact.disable();
      form.disable();
      form.enable();

      expect(form.contact.state.meta.enabled, isFalse);
      expect(form.contact.street.state.enabled, isFalse);
    });

    test('a Field Array inside a disabled Form is disabled with its items', () {
      form.disable();

      expect(form.phones.state.enabled, isFalse);
      expect(form.phones.items.single.node.number.state.enabled, isFalse);

      form.enable();

      expect(form.phones.state.enabled, isTrue);
      expect(form.phones.items.single.node.number.state.enabled, isTrue);
    });

    test('a Field Array can be disabled on its own', () {
      form.phones.disable();

      expect(form.phones.state.enabled, isFalse);
      expect(form.phones.items.single.node.number.state.enabled, isFalse);
      expect(form.title.state.enabled, isTrue);

      form.phones.enable();

      expect(form.phones.items.single.node.number.state.enabled, isTrue);
    });

    test('an item added to a disabled Field Array is disabled', () {
      form.phones.disable();
      form.phones.add();
      final added = form.phones.items.last;

      expect(added.node.number.state.enabled, isFalse);

      form.phones.enable();

      expect(added.node.number.state.enabled, isTrue);
    });

    test('an item added to a disabled Form is disabled', () {
      form.disable();
      form.phones.add();
      final added = form.phones.items.last;

      expect(added.node.number.state.enabled, isFalse);
    });

    test('an item Field disabled on its own survives the Field Array', () {
      final number = form.phones.items.single.node.number..disable();
      form.phones.disable();
      form.phones.enable();

      expect(number.state.enabled, isFalse);
    });

    test('a Dynamic Form can be disabled and so does its Fields', () {
      final note = form.extras.field<String>('note');

      form.extras.disable();

      expect(form.extras.state.enabled, isFalse);
      expect(note.state.enabled, isFalse);

      form.extras.enable();

      expect(note.state.enabled, isTrue);
    });

    test('a Field registered later in a disabled Dynamic Form is disabled', () {
      form.extras.disable();
      final later = form.extras.register<String>('later');

      expect(later.state.enabled, isFalse);

      form.extras.enable();

      expect(later.state.enabled, isTrue);
    });

    test('disabling the Form disables the Dynamic Form and its Fields', () {
      final note = form.extras.field<String>('note');

      form.disable();

      expect(form.extras.state.enabled, isFalse);
      expect(note.state.enabled, isFalse);

      form.enable();

      expect(form.extras.state.enabled, isTrue);
      expect(note.state.enabled, isTrue);
    });

    test('the whole tree notifies once', () {
      var calls = 0;
      form.addListener(() => calls++);

      form.disable();
      expect(calls, 1);

      form.enable();
      expect(calls, 2);
    });

    test('a Nested Form or a Field Array notifies once', () {
      var calls = 0;
      form.addListener(() => calls++);

      form.contact.disable();
      form.phones.disable();

      expect(calls, 2);
    });

    test('disabled Fields skip their Validators, Unset ones keep presence', () {
      form.title.setValue('a');
      form.contact.street.setValue('b');
      expect(form.title.state.errors, isNotEmpty);
      expect(form.contact.street.state.errors, isNotEmpty);

      form.disable();

      expect(form.title.state.errors, isEmpty);
      expect(form.contact.street.state.errors, isEmpty);

      form.enable();

      expect(form.title.state.errors, isNotEmpty);
    });
  });

  group('a Field Array in a disabled Form', () {
    test('drops the rules that judge its items', () {
      final form = LabelsForm();
      addTearDown(form.dispose);
      for (final tag in ['aa', 'bb', 'cc', 'dd']) {
        form.tags.add(tag);
      }
      expect(form.tags.state.errors, isNotEmpty);
      expect(form.state.meta.valid, isFalse);

      form.disable();

      expect(form.tags.state.errors, isEmpty);
      expect(form.state.meta.valid, isTrue);

      form.enable();

      expect(form.tags.state.errors, isNotEmpty);
      expect(form.state.meta.valid, isFalse);
    });
  });
}

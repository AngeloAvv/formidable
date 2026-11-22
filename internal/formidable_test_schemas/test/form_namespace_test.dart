import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:formidable_test_schemas/state_names.dart';
import 'package:test/test.dart';

void main() {
  group('the state.meta namespace', () {
    test('holds the metadata of the Form, typed after the Schema', () {
      final form = SignUpForm(username: 'angelo');

      final FormidableFormMeta<SignUp> meta = form.state.meta;

      expect(meta.status, FormidableStatus.valid);
      expect(meta.dirty, isFalse);
      expect(meta.pending, isFalse);
      expect(meta.defined, isTrue);
      expect(meta.errors, isEmpty);
      expect(meta.value?.username, 'angelo');
    });

    test('is also on the plain state, where the value is the Schema', () {
      final FormidableFormState state = SignUpForm(username: 'angelo').state;

      expect(state.meta.status, FormidableStatus.valid);
      expect(state.meta.value, isA<SignUp>());
    });

    test('valid follows the status', () {
      expect(SignUpForm(username: 'angelo').state.meta.valid, isTrue);
      expect(SignUpForm(username: 'ab').state.meta.valid, isFalse);
    });

    test('has a value of null while the Form is invalid', () {
      final form = SignUpForm(username: 'ab');

      expect(form.state.meta.status, FormidableStatus.invalid);
      expect(form.state.meta.value, isNull);
    });

    test('is equal, with the same hash code, when nothing differs', () {
      final a = SignUpForm(username: 'angelo').state.meta;
      final b = SignUpForm(username: 'angelo').state.meta;

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(SignUpForm(username: 'ab').state.meta));
    });

    test('keeps the value out of equality', () {
      final a = SignUpForm(username: 'angelo').state.meta;
      final b = SignUpForm(username: 'angelo').state.meta;

      expect(a.value, isNot(same(b.value)));
      expect(a, b);
    });

    test('reaches the Form-level errors', () async {
      final form = SignUpForm(username: 'angelo');
      form.applyErrors(
        formErrors: const [FormidableRequiredError()],
        fieldErrors: const {},
      );

      expect(form.state.meta.errors, [isA<FormidableRequiredError>()]);
      expect(form.state.meta.status, FormidableStatus.invalid);
    });
  });

  group('the lazy value', () {
    setUp(() => countedBuilds = 0);

    test('is not built when the state is published', () {
      final form = CountedForm(name: 'ab');

      form.name.setValue('abc');
      form.name.setValue('abcd');
      form.name.touch();

      expect(countedBuilds, 0);
    });

    test('is built on the first read and cached', () {
      final form = CountedForm(name: 'ab');
      final state = form.state;

      final first = state.meta.value;
      final second = state.meta.value;

      expect(countedBuilds, 1);
      expect(first, same(second));
    });

    test('is built again for the next state, once', () {
      final form = CountedForm(name: 'ab');
      expect(form.state.meta.value?.name, 'ab');

      form.name.setValue('abc');
      expect(form.state.meta.value?.name, 'abc');
      expect(form.value?.name, 'abc');

      expect(countedBuilds, 2);
    });

    test('is never built while the Form is invalid', () {
      final form = CountedForm(name: 'a');

      expect(form.state.meta.value, isNull);
      expect(form.value, isNull);
      expect(countedBuilds, 0);
    });

    test('follows the state it was read from, not the Form', () {
      final form = CountedForm(name: 'ab');
      final before = form.state;

      form.name.setValue('abc');

      // The first read happens after the Form moved on.
      expect(before.meta.value?.name, 'ab');
      expect(form.state.meta.value?.name, 'abc');
    });

    test(
      'of a stale state is the value of that state, for every node kind',
      () async {
        final form = ItineraryForm();
        form.title.setValue('Trip');
        form.contact.street.setValue('Main street');
        form.phones.add();
        form.phones.items.single.node.number.setValue('123');
        form.extras.register<String>('note').setValue('hello');
        final before = form.state;

        form.title.setValue('Other');
        form.contact.street.setValue('Side street');
        form.phones.items.single.node.number.setValue('345');
        form.extras.field<String>('note').setValue('bye');
        form.phones.add();
        form.phones.items.last.node.number.setValue('567');

        final old = before.meta.value!;
        expect(old.title, 'Trip');
        expect(old.contact.street, 'Main street');
        expect(old.phones.map((p) => p.number), ['123']);
        expect(old.extras, {'note': 'hello'});

        final now = form.state.meta.value!;
        expect(now.title, 'Other');
        expect(now.contact.street, 'Side street');
        expect(now.phones.map((p) => p.number), ['345', '567']);
        expect(now.extras, {'note': 'bye'});
      },
    );
  });

  group('Schema fields named like the metadata', () {
    test('status, dirty, pending and errors are Fields of the Form', () {
      final form = StateNamesForm(status: 'ok', dirty: true, pending: 3);

      expect(form.status.value, 'ok');
      expect(form.dirty.value, isTrue);
      expect(form.errors.value, isNull);
    });

    test('and of the state, next to the metadata', () {
      final form = StateNamesForm(status: 'ok', dirty: true, pending: 3);

      expect(form.state.status.value, 'ok');
      expect(form.state.dirty.value, isTrue);
      expect(form.state.pending, 3);
      expect(form.state.errors.value, isNull);
      expect(form.state.meta.status, FormidableStatus.valid);
      expect(form.state.meta.dirty, isFalse);
    });

    test('write through the Fields, build the Schema and notify', () {
      final form = StateNamesForm(status: 'ok', dirty: false, pending: 3);
      final seen = <StateNamesFormState>[];
      form.addListener(() => seen.add(form.state));

      form.dirty.setValue(true);
      form.errors.setValue('boom');
      form.status.setValue('x');

      expect(seen.length, 3);
      expect(seen[1].errors.value, 'boom');
      expect(seen.last.meta.status, FormidableStatus.invalid);
      expect(seen.last.meta.value, isNull);
      expect(seen[1].meta.value?.errors, 'boom');
      expect(seen[1].meta.value?.dirty, isTrue);
      expect(seen[1].meta.value?.pending, 3);
    });
  });
}

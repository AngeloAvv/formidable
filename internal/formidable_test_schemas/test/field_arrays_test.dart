import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:test/test.dart';

void main() {
  group('Field Array of Nested Forms', () {
    test('starts empty and adds items typed as the nested Form', () {
      final form = PersonForm();

      expect(form.phones.length, 0);

      form.phones.add();
      form.phones.add(const Telephone(number: '555'));

      expect(form.phones.length, 2);
      final first = form.phones.items[0].node;
      expect(first, isA<TelephoneForm>());
      expect(first.number.isSet, isFalse);
      expect(form.phones.items[1].node.number.value, '555');
    });

    test('builds the list of Schemas as output', () async {
      final form = PersonForm()..name.setValue('Angelo');
      form.phones.add(const Telephone(number: '555', label: 'home'));
      form.phones.add(const Telephone(number: '777'));

      final result = await form.submit();

      final valid = result as FormidableSubmitValid<Person>;
      expect(valid.value.phones.map((p) => p.number), ['555', '777']);
      expect(valid.value.phones.first.label, 'home');
    });
  });

  group('identity', () {
    test('every item has a stable identifier, kept by a move', () {
      final form = PersonForm();
      form.phones
        ..add()
        ..add()
        ..add();
      final ids = form.phones.items.map((i) => i.id).toList();
      final second = form.phones.items[1].node;

      expect(ids.toSet(), hasLength(3));

      form.phones.move(1, 2);

      expect(form.phones.items.map((i) => i.id), [ids[0], ids[2], ids[1]]);
      expect(form.phones.items[2].node, same(second));
    });

    test('an identifier is never reused after a removal', () {
      final form = PersonForm();
      form.phones
        ..add()
        ..add();
      final removed = form.phones.items.last.id;

      form.phones.removeAt(1);
      form.phones.add();

      expect(form.phones.items.map((i) => i.id), isNot(contains(removed)));
    });

    test('insert places the item at the index and keeps the others', () {
      final form = PersonForm();
      form.phones
        ..add(const Telephone(number: 'aaa'))
        ..add(const Telephone(number: 'ccc'))
        ..insert(1, const Telephone(number: 'bbb'));

      expect(form.phones.items.map((i) => i.node.number.value), [
        'aaa',
        'bbb',
        'ccc',
      ]);
    });

    test('remove by item and removeAt drop the right one', () {
      final form = PersonForm();
      form.phones
        ..add(const Telephone(number: 'aaa'))
        ..add(const Telephone(number: 'bbb'))
        ..add(const Telephone(number: 'ccc'));

      form.phones.removeAt(0);
      form.phones.remove(form.phones.items.last);

      expect(form.phones.items.map((i) => i.node.number.value), ['bbb']);
    });

    test('indexes out of range throw', () {
      final form = PersonForm()..phones.add();

      expect(() => form.phones.removeAt(1), throwsRangeError);
      expect(() => form.phones.insert(3), throwsRangeError);
      expect(() => form.phones.move(0, 1), throwsRangeError);
    });

    test('clear empties the array', () {
      final form = PersonForm();
      form.phones
        ..add()
        ..add();

      form.phones.clear();

      expect(form.phones.length, 0);
      expect(form.phones.isSet, isFalse);
    });
  });

  group('state and notifications', () {
    test('listeners hear about adds, removes and moves, not about no-ops', () {
      final form = PersonForm();
      var calls = 0;
      form.phones.addListener(() => calls++);

      form.phones.add();
      form.phones.add();
      expect(calls, 2);

      form.phones.move(0, 1);
      expect(calls, 3);

      form.phones.move(1, 1);
      form.phones.clear();
      form.phones.clear();
      expect(calls, 4);
      expect(form.phones.state.length, 0);
    });

    test('the Form notifies when an item changes', () {
      final form = PersonForm()..name.setValue('A');
      form.phones.add(const Telephone(number: '555'));
      final states = <FormidableFormState>[];
      form.addListener(() => states.add(form.state));

      form.phones.items.first.node.number.setValue('5');

      expect(states, hasLength(1));
      expect(states.single.status, FormidableStatus.invalid);
    });

    test('a Form change listener hears every item edit', () {
      final form = PersonForm();
      form.phones.add(const Telephone(number: '555'));
      var calls = 0;
      form.addChangeListener(() => calls++);

      form.phones.items.first.node.label.setValue('home');
      form.phones.items.first.node.label.setValue('work');

      expect(calls, 2);
    });
  });

  group('validation', () {
    test('an invalid item makes the Form invalid, a fixed one valid again', () {
      final form = PersonForm()..name.setValue('A');
      form.phones.add(const Telephone(number: '555'));
      expect(form.state.status, FormidableStatus.valid);

      form.phones.add();
      expect(form.state.status, FormidableStatus.invalid);
      expect(form.value, isNull);

      form.phones.removeAt(1);
      expect(form.state.status, FormidableStatus.valid);
      expect(form.value!.phones.single.number, '555');
    });

    test('item errors are addressed by item handle, in tree order', () async {
      final form = PersonForm();
      form.phones
        ..add(const Telephone(number: 'ok1'))
        ..add(const Telephone(number: '1'))
        ..add(const Telephone(number: '2'));

      final result = await form.submit() as FormidableSubmitInvalid<Person>;

      expect(result.fieldErrors.keys.toList(), [
        form.name,
        form.phones.items[1].node.number,
        form.phones.items[2].node.number,
      ]);
    });
  });

  group('item-count Validators and presence', () {
    test('an empty required array is Unset and invalid', () {
      final form = TeamForm();

      expect(form.members.isSet, isFalse);
      expect(form.members.state.errors, [const FormidableRequiredError()]);
      expect(form.state.status, FormidableStatus.invalid);
    });

    test('MinItems and MaxItems judge the number of items', () {
      final form = TeamForm();
      form.members
        ..add(const Telephone(number: '555'))
        ..add(const Telephone(number: '666'))
        ..add(const Telephone(number: '777'));
      expect(form.members.state.errors, isEmpty);

      form.members.add(const Telephone(number: '888'));
      expect(form.members.state.errors, [
        const FormidableMaxItemsError(max: 3, actual: 4),
      ]);
    });

    test('the array errors come back in the submit result', () async {
      final form = TeamForm();
      form.members.add(const Telephone(number: '555'));
      form.members.clear();
      form.members
        ..add(const Telephone(number: '1'))
        ..add(const Telephone(number: '2'))
        ..add(const Telephone(number: '3'))
        ..add(const Telephone(number: '4'));

      final result = await form.submit() as FormidableSubmitInvalid<Team>;

      expect(result.arrayErrors[form.members], [
        const FormidableMaxItemsError(max: 3, actual: 4),
      ]);
    });

    test('an array error alone blocks submit', () async {
      final form = TeamForm();
      form.members.add(const Telephone(number: '555'));
      form.members.clear();

      final result = await form.submit();

      expect(result, isA<FormidableSubmitInvalid<Team>>());
    });

    test('a nullable empty array is valid and produces null', () async {
      final form = TeamForm();
      form.members.add(const Telephone(number: '555'));

      final result = await form.submit() as FormidableSubmitValid<Team>;

      expect(result.value.backups, isNull);
      expect(form.backups.state.errors, isEmpty);
    });

    test('an empty array with a default produces the default', () async {
      final form = PersonForm()..name.setValue('A');

      final result = await form.submit() as FormidableSubmitValid<Person>;

      expect(result.value.phones, isEmpty);
    });
  });

  group('creation, writes, dirty and reset', () {
    test('from(schema) makes one item per list entry', () {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [
            Telephone(number: '555'),
            Telephone(number: '666', label: 'x'),
          ],
        ),
      );

      expect(form.phones.length, 2);
      expect(form.phones.items[1].node.label.value, 'x');
      expect(form.state.dirty, isFalse);
    });

    test('the partial constructor takes a list', () {
      final form = PersonForm(phones: const [Telephone(number: '555')]);

      expect(form.phones.length, 1);
    });

    test('adding an item makes the Form dirty and reset undoes it', () {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [Telephone(number: '555')],
        ),
      );
      final original = form.phones.items.first.node;

      form.phones.add();
      expect(form.state.dirty, isTrue);

      form.phones.removeAt(0);
      form.reset();

      expect(form.state.dirty, isFalse);
      expect(form.phones.length, 1);
      expect(form.phones.items.first.node, same(original));
      expect(original.number.value, '555');
    });

    test('moving items is a change and reset puts them back', () {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [
            Telephone(number: 'aaa'),
            Telephone(number: 'bbb'),
          ],
        ),
      );

      form.phones.move(0, 1);
      expect(form.state.dirty, isTrue);

      form.reset();
      expect(form.state.dirty, isFalse);
      expect(form.phones.items.map((i) => i.node.number.value), ['aaa', 'bbb']);
    });

    test('editing an item makes the Form dirty, commit makes it clean', () {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [Telephone(number: '555')],
        ),
      );

      form.phones.items.first.node.number.setValue('777');
      expect(form.state.dirty, isTrue);

      form.commit();
      expect(form.state.dirty, isFalse);

      form.reset();
      expect(form.phones.items.first.node.number.value, '777');
    });

    test('commit forgets removed items, reset keeps the committed ones', () {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [Telephone(number: 'aaa')],
        ),
      );
      form.phones.add(const Telephone(number: 'bbb'));
      form.commit();
      form.phones.removeAt(0);

      form.reset();

      expect(form.phones.items.map((i) => i.node.number.value), ['aaa', 'bbb']);
    });

    test('patch and replace write the list as one change', () {
      final form = PersonForm();
      var calls = 0;
      form.addListener(() => calls++);

      form.patch(
        phones: const [
          Telephone(number: 'aaa'),
          Telephone(number: 'bbb'),
        ],
      );
      expect(form.phones.length, 2);
      expect(calls, 1);

      form.replace(
        const Person(
          name: 'B',
          phones: [Telephone(number: 'ccc')],
        ),
      );
      expect(form.name.value, 'B');
      expect(form.phones.items.map((i) => i.node.number.value), ['ccc']);
    });

    test('Form.clear empties the arrays', () {
      final form = PersonForm();
      form.phones.add();

      form.clear();

      expect(form.phones.length, 0);
    });

    test('submit marks every item submitted', () async {
      final form = PersonForm();
      form.phones.add();

      await form.submit();

      expect(form.phones.items.first.node.number.state.submitted, isTrue);
      expect(form.phones.state.submitted, isTrue);
    });
  });

  group('Field Array of primitive values', () {
    test('lists, sets and maps are one Field by default', () {
      final form = LabelsForm();

      expect(form.single, isA<FormidableField<List<String>>>());
      expect(form.flags, isA<FormidableField<Set<String>>>());
      expect(form.counts, isA<FormidableField<Map<String, int>>>());

      form.single.setValue(['a', 'b']);
      expect(form.single.value, ['a', 'b']);
    });

    test('@FieldArray makes one Field per item', () {
      final form = LabelsForm();

      expect(
        form.tags,
        isA<FormidableFieldArray<FormidableField<String>, String>>(),
      );
      form.tags
        ..add('flutter')
        ..add();

      expect(form.tags.length, 2);
      expect(form.tags.items.first.node.value, 'flutter');
      expect(form.tags.items.last.node.isSet, isFalse);
    });

    test('items use the each Validators and Normalizers', () {
      final form = LabelsForm();
      form.tags.add('a');
      form.tags.add('  dart  ');

      expect(form.tags.items[0].node.state.errors, hasLength(1));
      expect(form.tags.items[1].node.value, 'dart');
      expect(form.tags.items[1].node.state.errors, isEmpty);
    });

    test(
      'an Unset item blocks the output, and the output is the list',
      () async {
        final form = LabelsForm();
        form.tags
          ..add('flutter')
          ..add('dart');

        final result = await form.submit() as FormidableSubmitValid<Labels>;

        expect(result.value.tags, ['flutter', 'dart']);
        expect(result.value.notes, isNull);

        form.tags.add();
        expect(await form.submit(), isA<FormidableSubmitInvalid<Labels>>());
      },
    );

    test('list level Validators judge the item count', () {
      final form = LabelsForm();
      for (final tag in ['aa', 'bb', 'cc', 'dd']) {
        form.tags.add(tag);
      }

      expect(form.tags.state.errors, [
        const FormidableMaxItemsError(max: 3, actual: 4),
      ]);
    });

    test('nullable items can be null', () async {
      final form = LabelsForm();
      form.notes.add();

      final result = await form.submit() as FormidableSubmitValid<Labels>;

      expect(result.value.notes, [null]);
    });
  });

  group('Field Arrays inside Field Arrays', () {
    test('items can hold arrays, and errors are found at any depth', () async {
      final form = CompanyForm()..name.setValue('Acme');
      form.teams.add();
      form.teams.items.first.node.members.add(const Telephone(number: '1'));

      final result = await form.submit() as FormidableSubmitInvalid<Company>;

      final deep = form.teams.items.first.node.members.items.first.node.number;
      expect(result.fieldErrors.keys, [deep]);
    });

    test('a deep array error is reported with its handle', () async {
      final form = CompanyForm()..name.setValue('Acme');
      form.teams.add();

      final result = await form.submit() as FormidableSubmitInvalid<Company>;

      expect(
        result.arrayErrors.keys.single,
        same(form.teams.items.first.node.members),
      );
    });

    test('builds nested lists as output', () async {
      final form = CompanyForm()..name.setValue('Acme');
      form.teams.add(const Team(members: [Telephone(number: '555')]));

      final result = await form.submit() as FormidableSubmitValid<Company>;

      expect(result.value.teams.single.members.single.number, '555');
    });
  });

  group('items run their own Form Effects and Form Validators', () {
    test('an Effect of the item reacts only to its own Fields', () {
      final form = DirectoryForm();
      form.places
        ..add(const Place(street: 'A', zip: '1'))
        ..add(const Place(street: 'B', zip: '2'));

      form.places.items[0].node.street.setValue('C');

      expect(form.places.items[0].node.zip.isSet, isFalse);
      expect(form.places.items[1].node.zip.value, '2');
    });

    test('a Form Validator of the item addresses its own Fields', () {
      final form = DirectoryForm();
      form.logins.add(const Credentials(password: 'a', confirmation: 'b'));

      final item = form.logins.items.first.node;

      expect(item.confirmation.state.errors, [const PasswordMismatch()]);

      item.confirmation.setValue('a');
      expect(item.confirmation.state.errors, isEmpty);
    });

    test('a Form Validator of the parent addresses an item Field', () {
      final form = DirectoryForm();
      form.places.add();

      final street = form.places.items.first.node.street;
      expect(street.state.errors, [const PasswordMismatch()]);

      street.setValue('Via Roma');
      expect(street.state.errors, isEmpty);
    });

    test('a removed item no longer takes part in validation', () {
      final form = DirectoryForm();
      form.logins.add(const Credentials(password: 'a', confirmation: 'b'));
      expect(form.state.status, FormidableStatus.invalid);

      form.logins.removeAt(0);

      expect(form.state.status, FormidableStatus.valid);
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/dynamic.dart' as dynamic_schemas;
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:formidable_test_schemas/passthrough.dart';
import 'package:formidable_test_schemas/profile.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:test/test.dart';

/// Records every state a Form publishes.
List<S> _watch<S extends FormidableFormState>(
  FormidableForm<Object?> form,
  S Function() read,
) {
  final seen = <S>[];
  form.addListener(() => seen.add(read()));
  return seen;
}

void main() {
  group('the typed Form state', () {
    test('is typed after the Form and holds the state of every Field', () {
      final form = SignUpForm(username: 'ab');

      final SignUpFormState state = form.state;

      expect(state.username, form.username.state);
      expect(state.username.value, 'ab');
      expect(state.meta.status, FormidableStatus.invalid);
      expect(state.meta.dirty, isFalse);
      expect(state.meta.pending, isFalse);
      expect(state.meta.errors, isEmpty);
    });

    test('holds the Schema value, null while the Form is invalid', () {
      final form = SignUpForm(username: 'ab');
      expect(form.state.meta.valueOrNull, isNull);

      form.username.setValue('angelo');

      expect(form.state.meta.valueOrNull?.username, 'angelo');
      expect(form.state.meta.status, FormidableStatus.valid);
    });

    test('differs after a change that keeps the Form valid', () {
      final form = SignUpForm(username: 'angelo');
      final before = form.state;

      form.username.setValue('angelo2');

      expect(form.state, isNot(before));
      expect(form.state.meta.status, before.meta.status);
    });

    test('differs when only touched changes', () {
      final form = SignUpForm(username: 'angelo');
      final before = form.state;

      form.username.touch();

      expect(form.state, isNot(before));
      expect(form.state.username.touched, isTrue);
    });

    test('is equal, with the same hash code, when nothing differs', () {
      final a = SignUpForm(username: 'angelo').state;
      final b = SignUpForm(username: 'angelo').state;

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(SignUpForm(username: 'other').state));
    });

    test('is not equal to a plain Form state', () {
      final state = SignUpForm(username: 'angelo').state;

      expect(
        state ==
            FormidableFormState(
              meta: FormidableFormMeta<Object?>(status: FormidableStatus.valid),
            ),
        isFalse,
      );
    });

    test('does not compare the Schema value, which may have no equality', () {
      // `SignUp` has no `==`: every build is a new instance, and the state must
      // still be equal to the previous one when nothing changed.
      final form = SignUpForm(username: 'angelo');
      final before = form.state;
      var notifications = 0;
      form.addListener(() => notifications++);

      form.username.touch();
      form.username.touch();

      expect(notifications, 1);
      expect(form.state.meta.value, isNot(same(before.meta.value)));
    });

    test('toString names the state and its Fields', () {
      final text = SignUpForm(username: 'angelo').state.toString();

      expect(text, contains('SignUpFormState'));
      expect(text, contains('username'));
    });

    test('is immutable', () {
      final form = SignUpForm(username: 'angelo');
      final before = form.state;

      form.username.setValue('x');

      expect(before.username.value, 'angelo');
    });
  });

  group('Form notifications', () {
    test('plain addListener fires on every change, values included', () {
      final form = SignUpForm(username: 'angelo');
      final seen = _watch(form, () => form.state);

      form.username.setValue('angelo2'); // valid -> valid
      form.username.setValue('angelo3'); // nothing the old state reported
      form.username.touch();
      form.username.touch(); // already touched: no change

      expect(seen.map((s) => s.username.value), [
        'angelo2',
        'angelo3',
        'angelo3',
      ]);
      expect(seen.last.username.touched, isTrue);
    });

    test('a write notifies once with the final state', () {
      final form = ProfileForm(email: 'a@b.c');
      final seen = _watch(form, () => form.state);

      form.patch(nickname: 'ange', bio: 'hello');

      expect(seen, hasLength(1));
      expect(seen.single.nickname.value, 'ange');
      expect(seen.single.bio.value, 'hello');
    });
  });

  group('Nested Form state', () {
    test('holds the generated state of the Nested Form', () {
      final form = ContactForm(
        name: 'Angelo',
        home: const Address(street: 'Via Roma'),
      );

      final AddressFormState home = form.state.home;

      expect(home, form.home.state);
      expect(home.street.value, 'Via Roma');
    });

    test('differs when a Field of a Nested Form changes', () {
      final form = ContactForm(
        name: 'Angelo',
        home: const Address(street: 'Via Roma'),
      );
      final before = form.state;
      final seen = _watch(form, () => form.state);

      form.home.street.setValue('Via Milano');

      expect(form.state, isNot(before));
      expect(seen, hasLength(1));
      expect(seen.single.home.street.value, 'Via Milano');
    });

    test('shows whether an optional Nested Form is set', () {
      final form = ContactForm(
        name: 'Angelo',
        home: const Address(street: 'Via Roma'),
      );
      expect(form.state.work.meta.defined, isFalse);
      expect(form.state.home.meta.defined, isTrue);

      form.work.street.setValue('Via Torino');

      expect(form.state.work.meta.defined, isTrue);
      expect(form.state.work.meta.dirty, isTrue);
    });

    test('the Schema value holds the Nested Form value', () {
      final form = ContactForm(
        name: 'Angelo',
        home: const Address(street: 'Via Roma'),
        billing: const Address(street: 'Via Po'),
      );

      expect(form.state.meta.valueOrNull?.home.street, 'Via Roma');
      expect(form.state.home.meta.valueOrNull?.street, 'Via Roma');
    });
  });

  group('Field Array state', () {
    PersonForm person() => PersonForm(
      name: 'Angelo',
      phones: const [
        Telephone(number: '123'),
        Telephone(number: '456'),
      ],
    );

    test('holds the typed state of every item', () {
      final form = person();

      final FormidableFieldArrayState<TelephoneFormState> phones =
          form.state.phones;

      expect(phones.length, 2);
      expect(phones.ids, [0, 1]);
      expect(phones.items[1].number.value, '456');
      expect(phones.items[0], form.phones[0].node.state);
    });

    test('differs when an item is edited', () {
      final form = person();
      final before = form.state;
      final seen = _watch(form, () => form.state);

      form.phones[1].node.number.setValue('789');

      expect(form.state, isNot(before));
      expect(form.state.phones, isNot(before.phones));
      expect(seen, hasLength(1));
      expect(seen.single.phones.items[1].number.value, '789');
    });

    test('differs when an item is added, removed or moved', () {
      final form = person();
      var previous = form.state.phones;

      form.phones.add(const Telephone(number: '000'));
      expect(form.state.phones, isNot(previous));
      expect(form.state.phones.length, 3);
      previous = form.state.phones;

      form.phones.move(0, 2);
      expect(form.state.phones, isNot(previous));
      expect(form.state.phones.ids, [1, 2, 0]);
      expect(form.state.phones.items.last.number.value, '123');
      previous = form.state.phones;

      form.phones.removeAt(0);
      expect(form.state.phones, isNot(previous));
      expect(form.state.phones.length, 2);
    });

    test('an array state notifies its own listeners when an item changes', () {
      final form = person();
      final seen = <FormidableFieldArrayState<TelephoneFormState>>[];
      form.phones.addListener(() => seen.add(form.phones.state));

      form.phones[0].node.number.setValue('999');

      expect(seen, hasLength(1));
      expect(seen.single.items[0].number.value, '999');
    });

    test('equal arrays are equal and hash the same', () {
      expect(person().state.phones, person().state.phones);
      expect(person().state.phones.hashCode, person().state.phones.hashCode);
    });

    test('an array of Fields holds Field states', () {
      final form = LabelsForm(tags: const ['one', 'two']);

      final FormidableFieldArrayState<FormidableFieldState<String>> tags =
          form.state.tags;

      expect(tags.items.map((i) => i.value), ['one', 'two']);

      form.tags[0].node.setValue('uno');

      expect(form.state.tags.items.first.value, 'uno');
      expect(form.state, isNot(LabelsForm(tags: const ['one', 'two']).state));
    });

    test('an item of a nested array changes the root state', () {
      final form = CompanyForm(
        name: 'Acme',
        teams: const [
          Team(members: [Telephone(number: '123')]),
        ],
      );
      final before = form.state;

      form.teams[0].node.members[0].node.number.setValue('999');

      expect(form.state, isNot(before));
      expect(
        form.state.teams.items.single.members.items.single.number.value,
        '999',
      );
    });
  });

  group('Passthrough and Dynamic state', () {
    test('a Passthrough Field is its value in the state', () {
      final form = EditUserForm(id: 1, name: 'a');

      final int id = form.state.id;

      expect(id, 1);
      form.id.setValue(2);
      expect(form.state.id, 2);
    });

    test('a Dynamic Form holds the state of what is registered', () {
      final form = dynamic_schemas.SurveyForm(
        title: 'Hello',
        answers: const {},
      );
      final seen = _watch(form, () => form.state);
      final nickname = form.answers.register<String>('nickname');

      expect(form.state.answers.keys, ['nickname']);
      expect(form.state.answers.field<String>('nickname'), nickname.state);

      nickname.setValue('ange');

      expect(form.state.answers.field<String>('nickname').value, 'ange');
      expect(seen.last.answers.field<String>('nickname').value, 'ange');
    });

    test('Dynamic states are equal when keys and child states are', () {
      dynamic_schemas.SurveyForm make() {
        final form = dynamic_schemas.SurveyForm(
          title: 'Hello',
          answers: const {},
        );
        form.answers.register<String>('a');
        return form;
      }

      expect(make().state.answers, make().state.answers);
      expect(make().state.answers.hashCode, make().state.answers.hashCode);
      final changed = make();
      changed.answers.field<String>('a').setValue('x');
      expect(changed.state.answers, isNot(make().state.answers));
    });
  });
}

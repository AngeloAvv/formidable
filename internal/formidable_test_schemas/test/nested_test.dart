import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:test/test.dart';

void main() {
  group('Nested Form handles', () {
    test('reach the Fields of a nested Schema through typed handles', () {
      final form = ContactForm();

      form.home.street.setValue('Via Roma');
      form.home.zip.setValue('00100');

      expect(form.home.street.value, 'Via Roma');
      expect(form.home.zip.value, '00100');
      expect(form.home, isA<AddressForm>());
    });

    test('reach Fields through two nesting levels', () {
      final form = OrderForm();

      form.owner.home.street.setValue('Via Roma');

      expect(form.owner.home.street.value, 'Via Roma');
    });

    test('build the Schema output from the nested Forms', () async {
      final form = ContactForm()
        ..name.setValue('Angelo')
        ..home.street.setValue('Via Roma')
        ..billing.street.setValue('Via Milano');

      final result = await form.submit();

      final valid = result as FormidableSubmitValid<Contact>;
      expect(valid.value.name, 'Angelo');
      expect(valid.value.home.street, 'Via Roma');
      expect(valid.value.home.zip, isNull);
      expect(valid.value.billing!.street, 'Via Milano');
      expect(valid.value.work, isNull);
    });

    test('build the output through two levels', () async {
      final form = OrderForm(title: 'T')
        ..owner.name.setValue('Angelo')
        ..owner.home.street.setValue('Via Roma')
        ..owner.billing.street.setValue('Via Milano');

      final result = await form.submit() as FormidableSubmitValid<Order>;

      expect(result.value.owner.home.street, 'Via Roma');
    });
  });

  group('Nested Form validation', () {
    test('runs the Validators of the nested Fields', () {
      final form = ContactForm();

      form.home.street.setValue('x');

      expect(form.home.street.state.errors, hasLength(1));
      expect(
        form.home.street.state.errors.single,
        isA<FormidableMinLengthError>(),
      );
    });

    test('makes the parent invalid while a nested Field is invalid', () {
      final form = ContactForm()
        ..name.setValue('Angelo')
        ..billing.street.setValue('Via Milano')
        ..home.street.setValue('Via Roma');
      expect(form.state.status, FormidableStatus.valid);

      form.home.street.setValue('x');

      expect(form.home.state.status, FormidableStatus.invalid);
      expect(form.state.status, FormidableStatus.invalid);
      expect(form.value, isNull);
    });

    test(
      'requires the nested Fields: an Unset required Field blocks',
      () async {
        final form = ContactForm()..name.setValue('Angelo');

        final result = await form.submit() as FormidableSubmitInvalid<Contact>;

        expect(
          result.errors.keys,
          containsAll([form.home.street, form.billing.street]),
        );
        expect(
          result.errors[form.home.street]!.single,
          isA<FormidableRequiredError>(),
        );
        expect(result.errors.containsKey(form.work.street), isFalse);
      },
    );

    test('reports the errors found two levels down', () async {
      final form = OrderForm(title: 'T')
        ..owner.name.setValue('Angelo')
        ..owner.home.street.setValue('x')
        ..owner.billing.street.setValue('Via Milano');

      final result = await form.submit() as FormidableSubmitInvalid<Order>;

      expect(result.errors.keys, [form.owner.home.street]);
    });

    test('exposes value once every level is valid', () {
      final form = ContactForm()
        ..name.setValue('Angelo')
        ..home.street.setValue('Via Roma');
      expect(form.value, isNull);

      form.billing.street.setValue('Via Milano');

      expect(form.value!.home.street, 'Via Roma');
    });
  });

  group('Nullable Nested Form presence', () {
    test(
      'an optional Nested Form starts Unset, valid and without output',
      () async {
        final form = ContactForm()
          ..name.setValue('Angelo')
          ..home.street.setValue('Via Roma')
          ..billing.street.setValue('Via Milano');

        expect(form.work.isSet, isFalse);
        expect(form.work.state.status, FormidableStatus.valid);
        expect(form.work.value, isNull);
        final result = await form.submit() as FormidableSubmitValid<Contact>;
        expect(result.value.work, isNull);
      },
    );

    test('an Unset optional Nested Form does not block submit', () async {
      final form = ContactForm()..name.setValue('Angelo');
      form.home.street.setValue('Via Roma');
      form.billing.street.setValue('Via Milano');

      expect(form.state.status, FormidableStatus.valid);
    });

    test(
      'becomes set when a Field is written, and its rules then apply',
      () async {
        final form = ContactForm()
          ..name.setValue('Angelo')
          ..home.street.setValue('Via Roma')
          ..billing.street.setValue('Via Milano');

        form.work.zip.setValue('00100');

        expect(form.work.isSet, isTrue);
        expect(form.state.status, FormidableStatus.invalid);
        final invalid = await form.submit() as FormidableSubmitInvalid<Contact>;
        expect(invalid.errors.keys, [form.work.street]);

        form.work.street.setValue('Via Napoli');
        final valid = await form.submit() as FormidableSubmitValid<Contact>;
        expect(valid.value.work!.street, 'Via Napoli');
        expect(valid.value.work!.zip, '00100');
      },
    );

    test('is Unset again when it goes back to its initial state', () {
      final form = ContactForm()..name.setValue('Angelo');

      form.work.zip.setValue('00100');
      expect(form.work.isSet, isTrue);
      form.work.zip.clear();

      expect(form.work.isSet, isFalse);
      expect(form.work.state.dirty, isFalse);
    });

    test('is set when created from a Schema instance', () async {
      final form = ContactForm.from(
        const Contact(
          name: 'Angelo',
          home: Address(street: 'Via Roma'),
          work: Address(street: 'Via Napoli'),
          billing: Address(street: 'Via Milano'),
        ),
      );

      expect(form.work.isSet, isTrue);
      expect(form.work.street.value, 'Via Napoli');
      final result = await form.submit() as FormidableSubmitValid<Contact>;
      expect(result.value.work!.street, 'Via Napoli');
    });

    test('stays Unset when created from a Schema with a null Nested Form', () {
      final form = ContactForm.from(
        const Contact(
          name: 'Angelo',
          home: Address(street: 'Via Roma'),
          billing: Address(street: 'Via Milano'),
        ),
      );

      expect(form.work.isSet, isFalse);
      expect(form.state.dirty, isFalse);
    });

    test('a nullable Nested Form with @Required() is always set', () async {
      final form = ContactForm();

      expect(form.billing.isSet, isTrue);
      expect(form.home.isSet, isTrue);
      final result = await form.submit() as FormidableSubmitInvalid<Contact>;
      expect(result.errors.containsKey(form.billing.street), isTrue);
    });

    test('notifies the parent when an optional Nested Form becomes set', () {
      final form = ContactForm()
        ..name.setValue('Angelo')
        ..home.street.setValue('Via Roma')
        ..billing.street.setValue('Via Milano');
      final statuses = <FormidableStatus>[];
      form.addListener(() => statuses.add(form.state.status));

      form.work.zip.setValue('00100');

      expect(statuses.last, FormidableStatus.invalid);
    });
  });

  group('Nested Form dirty and state', () {
    test('a nested change makes every ancestor dirty, and clean again', () {
      final form = OrderForm(title: 'T');
      expect(form.state.dirty, isFalse);

      form.owner.home.street.setValue('Via Roma');

      expect(form.owner.home.state.dirty, isTrue);
      expect(form.owner.state.dirty, isTrue);
      expect(form.state.dirty, isTrue);

      form.owner.home.street.clear();

      expect(form.state.dirty, isFalse);
    });

    test('a Nested Form starts clean when created from a Schema', () {
      final form = ContactForm.from(
        const Contact(
          name: 'Angelo',
          home: Address(street: 'Via Roma'),
          billing: Address(street: 'Via Milano'),
        ),
      );

      expect(form.state.dirty, isFalse);
      expect(form.home.state.dirty, isFalse);
    });

    test('notifies the parent of a nested value change even if its state '
        'stays equal', () {
      final form = ContactForm()..home.street.setValue('Via Roma');
      var changes = 0;
      form.addChangeListener(() => changes++);

      form.home.street.setValue('Via Milano');

      expect(changes, 1);
    });

    test('notifies the Nested Form listeners of its own state changes', () {
      final form = ContactForm();
      var count = 0;
      form.home.addListener(() => count++);

      form.home.street.setValue('x');

      expect(count, 1);
    });

    test('prefills nested Fields from the partial constructor', () {
      final form = ContactForm(home: const Address(street: 'Via Roma'));

      expect(form.home.street.value, 'Via Roma');
      expect(form.home.state.dirty, isFalse);
    });
  });

  group('Nested Form Effects', () {
    test('a nested Effect runs when a nested Field changes', () {
      final form = ShipmentForm()
        ..place.street.setValue('A')
        ..place.zip.setValue('00100');

      form.place.street.setValue('B');

      expect(form.place.zip.isSet, isFalse);
    });

    test('a parent Effect sees a change in a nested Field', () {
      final form = ShipmentForm();

      form.place.street.setValue('Via Roma');

      expect(form.note.value, 'street: Via Roma');
    });
  });

  group('Nested Form with a Passthrough', () {
    test('requires the Schema instance of a Nested Form that has one', () {
      final form = EditorForm(record: const Record(id: 7, title: 'a'));

      form.record.title.setValue('b');

      expect(form.record.id.value, 7);
      expect(form.value!.record.id, 7);
      expect(form.value!.record.title, 'b');
    });
  });

  group('Nested Form disposal', () {
    test('disposing the parent disposes the nested Forms', () {
      final form = ContactForm();
      final home = form.home;
      final street = form.home.street;

      form.dispose();

      expect(home.isDisposed, isTrue);
      expect(street.isDisposed, isTrue);
    });
  });

  group('Nested Form Validators', () {
    test('a Form Validator of the Nested Form addresses its own Fields', () {
      final form = DeliveryForm(place: const Place());

      form.credentials.password.setValue('a');
      form.credentials.confirmation.setValue('b');
      expect(form.credentials.confirmation.state.errors, [
        const PasswordMismatch(),
      ]);
      expect(form.credentials.state.status, FormidableStatus.invalid);

      form.credentials.confirmation.setValue('a');
      expect(form.credentials.confirmation.state.errors, isEmpty);
    });

    test('a Form Validator of the parent can address a nested Field', () {
      final form = DeliveryForm(place: const Place());

      form.place.street.setValue('Via Roma');
      expect(form.place.zip.state.errors, [const PasswordMismatch()]);
      expect(form.state.status, FormidableStatus.invalid);

      form.place.zip.setValue('00100');
      expect(form.place.zip.state.errors, isEmpty);
    });

    test('an Unset optional Nested Form is not validated', () async {
      final form = DeliveryForm(place: const Place());
      form.place.street.setValue('Via Roma');
      form.place.zip.setValue('00100');

      expect(form.credentials.isSet, isFalse);
      expect(form.credentials.confirmation.state.errors, isEmpty);
      expect(await form.submit(), isA<FormidableSubmitValid<Delivery>>());
    });
  });

  group('Nested Form writes', () {
    Contact contact({Address? work}) => Contact(
      name: 'Angelo',
      home: const Address(street: 'Via Roma', zip: '00100'),
      work: work,
      billing: const Address(street: 'Via Milano'),
    );

    test('patch replaces the Fields of a Nested Form from a Schema', () {
      final form = ContactForm.from(contact());

      form.patch(home: const Address(street: 'Via Napoli'));

      expect(form.home.street.value, 'Via Napoli');
      // A null in the Schema is a chosen value, not Unset (ADR-0003).
      expect(form.home.zip.value, isNull);
      expect(form.name.value, 'Angelo');
    });

    test('a nested patch writes only the given Fields, in the same change', () {
      final form = ContactForm.from(contact());
      var notifications = 0;
      form.addListener(() => notifications++);

      form.patch(name: 'Other');
      form.home.patch(street: 'Via Napoli');

      expect(form.home.street.value, 'Via Napoli');
      expect(form.home.zip.value, '00100');
      expect(form.state.dirty, isTrue);
      expect(notifications, 1);
    });

    test('replace writes every nested Field and sets an optional one', () {
      final form = ContactForm.from(contact());

      form.replace(contact(work: const Address(street: 'Via Torino')));

      expect(form.work.isSet, isTrue);
      expect(form.work.street.value, 'Via Torino');
    });

    test('replace with a null Nested Form clears it', () {
      final form = ContactForm.from(
        contact(work: const Address(street: 'Via Torino')),
      );

      form.replace(contact());

      expect(form.work.street.isSet, isFalse);
      expect(form.work.zip.isSet, isFalse);
    });

    test('replace through two levels', () async {
      final form = OrderForm(title: 'T');

      form.replace(Order(title: 'U', owner: contact()));

      final result = await form.submit() as FormidableSubmitValid<Order>;
      expect(result.value.owner.home.zip, '00100');
    });

    test('reset restores every level and the presence of optional ones', () {
      final form = ContactForm.from(contact());
      form.home.street.setValue('x');
      form.work.zip.setValue('1');
      form.home.street.markAsTouched();
      expect(form.work.isSet, isTrue);

      form.reset();

      expect(form.home.street.value, 'Via Roma');
      expect(form.home.street.state.touched, isFalse);
      expect(form.work.isSet, isFalse);
      expect(form.work.zip.isSet, isFalse);
      expect(form.state.dirty, isFalse);
      expect(form.state.status, FormidableStatus.valid);
    });

    test('reset notifies a Nested Form and its parent once', () {
      final form = ContactForm.from(contact());
      form.home.street.setValue('x');
      form.home.zip.setValue('1');
      var home = 0;
      var parent = 0;
      form.home.addListener(() => home++);
      form.addListener(() => parent++);

      form.reset();

      expect(home, 1);
      expect(parent, 1);
    });

    test(
      'commit makes every level, and the presence, the new initial state',
      () {
        final form = ContactForm.from(contact());
        form.home.street.setValue('Via Napoli');
        form.work.street.setValue('Via Torino');

        form.commit();

        expect(form.state.dirty, isFalse);
        expect(form.home.state.dirty, isFalse);
        expect(form.work.isSet, isTrue);

        form.reset();
        expect(form.home.street.value, 'Via Napoli');
        expect(form.work.street.value, 'Via Torino');
      },
    );

    test('clear makes the Fields of every level Unset', () {
      final form = ContactForm.from(contact());

      form.home.clear();

      expect(form.home.street.isSet, isFalse);
      expect(form.home.zip.isSet, isFalse);
    });
  });

  group('Nested Form submit and applied errors', () {
    test('submit marks the Fields of every set level as submitted', () async {
      final form = OrderForm(title: 'T');

      await form.submit();

      expect(form.owner.home.street.state.submitted, isTrue);
      expect(form.owner.home.street.state.touched, isTrue);
      expect(form.owner.name.state.submitted, isTrue);
    });

    test('submit leaves an Unset optional Nested Form alone', () async {
      final form = ContactForm();

      await form.submit();

      expect(form.home.street.state.submitted, isTrue);
      expect(form.work.street.state.submitted, isFalse);
      expect(form.work.street.state.touched, isFalse);
    });

    test('applies errors to Fields of a Nested Form', () async {
      final form = ContactForm.from(
        const Contact(
          name: 'Angelo',
          home: Address(street: 'Via Roma'),
          billing: Address(street: 'Via Milano'),
        ),
      );
      expect(form.state.status, FormidableStatus.valid);

      form.applyErrors(
        fieldErrors: {
          form.home.street: [const PasswordMismatch()],
        },
      );

      expect(form.home.street.state.errors, [const PasswordMismatch()]);
      expect(form.home.state.status, FormidableStatus.invalid);
      expect(form.state.status, FormidableStatus.invalid);
      final result = await form.submit() as FormidableSubmitInvalid<Contact>;
      expect(result.errors.keys, [form.home.street]);
    });

    test('applies errors to a Nested Form as a whole, until it changes', () {
      final form = ContactForm.from(
        const Contact(
          name: 'Angelo',
          home: Address(street: 'Via Roma'),
          billing: Address(street: 'Via Milano'),
        ),
      );

      form.home.applyErrors(formErrors: [const PasswordMismatch()]);

      expect(form.home.state.errors, [const PasswordMismatch()]);
      expect(form.home.state.status, FormidableStatus.invalid);
      expect(form.state.status, FormidableStatus.invalid);

      form.home.zip.setValue('00100');

      expect(form.home.state.errors, isEmpty);
      expect(form.state.status, FormidableStatus.valid);
    });
  });
}

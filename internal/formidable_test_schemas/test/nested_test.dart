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
          result.fieldErrors.keys,
          containsAll([form.home.street, form.billing.street]),
        );
        expect(
          result.fieldErrors[form.home.street]!.single,
          isA<FormidableRequiredError>(),
        );
        expect(result.fieldErrors.containsKey(form.work.street), isFalse);
      },
    );

    test('reports the errors found two levels down', () async {
      final form = OrderForm(title: 'T')
        ..owner.name.setValue('Angelo')
        ..owner.home.street.setValue('x')
        ..owner.billing.street.setValue('Via Milano');

      final result = await form.submit() as FormidableSubmitInvalid<Order>;

      expect(result.fieldErrors.keys, [form.owner.home.street]);
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
        expect(invalid.fieldErrors.keys, [form.work.street]);

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
      expect(result.fieldErrors.containsKey(form.billing.street), isTrue);
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
}

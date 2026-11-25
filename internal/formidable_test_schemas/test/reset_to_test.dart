import 'package:formidable_test_schemas/effects.dart' as fx;
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:test/test.dart';

void main() {
  group('reset(to:)', () {
    test('replaces the values and commits them as the initial state', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      form.country.setValue('FR');

      form.reset(
        to: const fx.Address(
          revision: 5,
          country: 'IT',
          province: 'BE',
          label: 'IT/BE',
        ),
      );

      expect(form.country.value, 'IT');
      expect(form.province.value, 'BE');
      expect(form.state.meta.dirty, isFalse);
      expect(form.country.state.dirty, isFalse);

      // The new initial state is what reset() restores now.
      form.country.setValue('ES');
      expect(form.state.meta.dirty, isTrue);
      form.reset();
      expect(form.province.value, 'BE');
      expect(form.state.meta.dirty, isFalse);
    });

    test('without a source it still restores the initial state', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      form.province.setValue('RM');

      form.reset();

      expect(form.province.value, 'MI');
    });

    test('clears touched and submitted', () async {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      await form.submit();
      form.province.touch();
      expect(form.country.state.touched, isTrue);
      expect(form.country.state.submitted, isTrue);

      form.reset(
        to: const fx.Address(revision: 1, country: 'FR', province: 'PA'),
      );

      for (final state in [form.country.state, form.province.state]) {
        expect(state.touched, isFalse);
        expect(state.submitted, isFalse);
      }
    });

    test('runs the Form Effects on the new values', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);

      form.reset(
        to: const fx.Address(
          revision: 1,
          country: 'FR',
          province: 'PA',
          label: 'wrong',
        ),
      );

      // The Effects ran on the new values, as at creation: the label is
      // derived again, and the province that came with the source stays.
      expect(form.province.value, 'PA');
      expect(form.label.value, 'FR/PA');
      expect(form.state.meta.dirty, isFalse);
    });

    test('notifies the listeners once', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      form.country.setValue('FR');
      var notifications = 0;
      form.addListener(() => notifications++);

      form.reset(
        to: const fx.Address(revision: 1, country: 'DE', province: 'BE'),
      );

      expect(notifications, 1);
    });
  });

  group('reset(to:) with Nested Forms', () {
    test('replaces, commits and clears the flags below', () async {
      final form = ShipmentForm.from(
        const Shipment(
          place: Place(street: 'A', zip: '1'),
        ),
      );
      addTearDown(form.dispose);
      form.place.street.setValue('B');
      await form.submit();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.reset(
        to: const Shipment(
          place: Place(street: 'C', zip: '3'),
          note: 'n',
        ),
      );

      expect(notifications, 1);
      expect(form.place.street.value, 'C');
      // No Effect treats the source as a change: the zip stays.
      expect(form.place.zip.value, '3');
      expect(form.note.value, 'n');
      expect(form.state.meta.dirty, isFalse);
      expect(form.place.street.state.touched, isFalse);
      expect(form.place.street.state.submitted, isFalse);
    });

    test(
      'does not fire the Effects of the parent and of the Nested Form on a change',
      () {
        final form = ShipmentForm.from(
          const Shipment(
            place: Place(street: 'A', zip: '1'),
          ),
        );
        addTearDown(form.dispose);

        form.reset(
          to: const Shipment(
            place: Place(street: 'C', zip: '3'),
          ),
        );

        // Effects that react to a change do not: the source is not one.
        expect(form.note.value, isNull);
        expect(form.place.zip.value, '3');
        expect(form.state.meta.dirty, isFalse);
      },
    );

    test('a Nested Form resets to its own Schema instance', () {
      final form = ShipmentForm.from(
        const Shipment(
          place: Place(street: 'A', zip: '1'),
        ),
      );
      addTearDown(form.dispose);
      form.place.street.setValue('X');
      var notifications = 0;
      form.addListener(() => notifications++);

      form.place.reset(
        to: const Place(street: 'Z', zip: '9'),
      );

      expect(notifications, 1);
      expect(form.place.street.value, 'Z');
      expect(form.place.state.meta.dirty, isFalse);
      expect(form.place.street.state.touched, isFalse);
    });
  });

  group('reset(to:) with Field Arrays', () {
    test('replaces the items and commits them', () async {
      final form = PersonForm.from(
        const Person(
          name: 'A',
          phones: [Telephone(number: '111')],
        ),
      );
      addTearDown(form.dispose);
      form.phones.add(const Telephone(number: '222'));
      await form.submit();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.reset(
        to: const Person(
          name: 'B',
          phones: [
            Telephone(number: '333'),
            Telephone(number: '444'),
            Telephone(number: '555'),
          ],
        ),
      );

      expect(notifications, 1);
      expect(form.phones.items, hasLength(3));
      expect(form.phones.items.last.node.number.value, '555');
      expect(form.state.meta.dirty, isFalse);
      expect(form.phones.state.touched, isFalse);
      expect(form.phones.state.submitted, isFalse);
      expect(form.phones.items.first.node.number.state.touched, isFalse);

      // The new items are the initial ones: reset() keeps them.
      form.phones.items.first.node.number.setValue('999');
      form.reset();
      expect(form.phones.items, hasLength(3));
      expect(form.phones.items.first.node.number.value, '333');
    });
  });

  group('reset(to:) with a Dynamic Form', () {
    test('replaces the entries and commits them', () {
      final form = ItineraryForm(
        title: 'Rome',
        contact: const Address(street: 'Via Roma'),
        phones: const [Telephone(number: '111')],
      );
      addTearDown(form.dispose);
      final key = form.extras.register<String>('k');
      key.setValue('v');
      form.title.setValue('Milan');

      form.reset(
        to: const Itinerary(
          title: 'Turin',
          contact: Address(street: 'Via Po'),
          phones: [Telephone(number: '999')],
          extras: {'k': 'w'},
          footer: null,
        ),
      );

      expect(form.title.value, 'Turin');
      expect(key.value, 'w');
      expect(key.state.dirty, isFalse);
      expect(form.state.meta.dirty, isFalse);
    });
  });

  group('reset(to:) and the enable lock', () {
    test('leaves the enabled flags of the containers and the Fields alone', () {
      final form = ShipmentForm.from(
        const Shipment(
          place: Place(street: 'A', zip: '1'),
        ),
      );
      addTearDown(form.dispose);
      form.place.street.disable();
      form.disable();
      form.place.street.setValue('B');
      form.place.street.touch();

      form.reset(
        to: const Shipment(
          place: Place(street: 'C', zip: '3'),
        ),
      );

      expect(form.state.meta.enabled, isFalse);
      expect(form.place.street.state.enabled, isFalse);
      expect(form.place.zip.state.enabled, isFalse);
      expect(form.place.street.value, 'C');
      expect(form.place.street.state.touched, isFalse);

      form.enable();
      // The Field disabled on its own stays disabled.
      expect(form.place.street.state.enabled, isFalse);
      expect(form.place.zip.state.enabled, isTrue);
    });
  });

  group('reset(to:) edge cases', () {
    test('an optional Nested Form takes its presence from the source', () {
      final form = DeliveryForm(
        place: const Place(street: 'Main', zip: '00100'),
        backup: const Place(street: 'Side', zip: '00200'),
      );
      addTearDown(form.dispose);
      expect(form.backup.defined, isTrue);

      form.reset(to: const Delivery(place: Place(street: 'New', zip: '1')));

      expect(form.backup.defined, isFalse);
      expect(form.value.backup, isNull);
      expect(form.state.meta.dirty, isFalse);

      form.reset(
        to: const Delivery(
          place: Place(street: 'New', zip: '1'),
          backup: Place(),
        ),
      );

      expect(form.backup.defined, isTrue);
      expect(form.value.backup, isNotNull);
      expect(form.state.meta.dirty, isFalse);
    });

    test('items created by the reset keep notifying afterwards', () {
      final form = PersonForm(name: 'Ada');
      addTearDown(form.dispose);

      form.reset(
        to: const Person(
          name: 'Ada',
          phones: [Telephone(number: '111'), Telephone(number: '222')],
        ),
      );
      var notifications = 0;
      form.addListener(() => notifications++);
      final phone = form.phones.items.last.node;
      var itemNotifications = 0;
      phone.addListener(() => itemNotifications++);

      phone.number.setValue('333');

      expect(itemNotifications, 1);
      expect(notifications, 1);
      expect(phone.state.number.value, '333');
      expect(form.state.phones.items.last.number.value, '333');
    });
  });

  group('reset(to:) inside a batch', () {
    test('the Effects still see the changes made earlier in the batch', () {
      final form = DeliveryForm(
        place: const Place(street: 'Main', zip: '00100'),
        backup: const Place(street: 'Side', zip: '00200'),
      );
      addTearDown(form.dispose);

      form.batch(() {
        form.place.street.setValue('Other');
        form.backup.reset(to: const Place(street: 'New', zip: '00300'));
      });

      // ClearZipOnStreetChange ran for the edit made before the reset...
      expect(form.place.zip.defined, isFalse);
      // ...and not for the Fields the reset wrote.
      expect(form.backup.street.value, 'New');
      expect(form.backup.zip.value, '00300');
      expect(form.backup.state.meta.dirty, isFalse);
    });
  });
}

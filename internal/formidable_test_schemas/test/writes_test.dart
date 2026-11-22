import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/effects.dart';
import 'package:formidable_test_schemas/writes.dart';
import 'package:test/test.dart';

void main() {
  ContactForm contactForm() =>
      ContactForm.from(const Contact(id: 1, name: 'Angelo', phone: '123'));

  group('patch', () {
    test('updates only the Fields it is given', () {
      final form = contactForm();

      form.patch(name: 'Marco', note: 'vip');

      expect(form.name.value, 'Marco');
      expect(form.note.value, 'vip');
      expect(form.phone.value, '123');
      expect(form.id.value, 1);
    });

    test('can write a Passthrough Field', () {
      final form = contactForm();

      form.patch(id: 7);

      expect(form.id.value, 7);
    });

    test('notifies the Form once, and each changed Field once', () {
      final form = contactForm();
      var formNotifications = 0;
      var nameNotifications = 0;
      var phoneNotifications = 0;
      var untouchedNotifications = 0;
      form.addListener(() => formNotifications++);
      form.name.addListener(() => nameNotifications++);
      form.phone.addListener(() => phoneNotifications++);
      form.note.addListener(() => untouchedNotifications++);

      form.patch(name: 'Marco', phone: '456');

      expect(formNotifications, 1);
      expect(nameNotifications, 1);
      expect(phoneNotifications, 1);
      expect(untouchedNotifications, 0);
    });

    test('notifies listeners once', () {
      final form = contactForm();
      var changes = 0;
      form.addListener(() => changes++);

      form.patch(name: 'Marco', phone: '456', note: 'vip');

      expect(changes, 1);
    });

    test('a chosen null is written atomically with batch', () {
      final form = contactForm();
      var changes = 0;
      form.addListener(() => changes++);

      form.patch(phone: null); // null means "leave unchanged"
      expect(form.phone.value, '123');

      form.batch(() {
        form.phone.setValue(null);
        form.name.setValue('Marco');
      });

      expect(form.phone.value, isNull);
      expect(form.name.value, 'Marco');
      expect(changes, 1);
    });

    test('without arguments, or with the current values, notifies nobody', () {
      final form = contactForm();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.patch();
      form.patch(name: 'Angelo', phone: '123');

      expect(notifications, 0);
    });

    test('goes through the Normalizers and Validators', () {
      final form = contactForm();

      form.patch(name: '  Marco  ');
      expect(form.name.value, 'Marco');

      form.patch(name: 'M');
      expect(form.name.state.errors, [isA<FormidableMinLengthError>()]);
      expect(form.state.meta.status, FormidableStatus.invalid);
    });

    test('never marks a Field as touched', () {
      final form = contactForm();

      form.patch(name: 'Marco', phone: '456');

      expect(form.name.state.touched, isFalse);
      expect(form.phone.state.touched, isFalse);
    });

    test('runs the Form Effects once, after every Field was written', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.patch(country: 'FR', province: 'PA');

      // The Effect sees the country change and clears the province.
      expect(form.province.defined, isFalse);
      expect(form.label.value, 'FR/-');
    });
  });

  group('replace', () {
    test('sets every Field from a Schema instance', () {
      final form = contactForm();

      form.replace(const Contact(id: 2, name: 'Marco', note: 'vip'));

      expect(form.id.value, 2);
      expect(form.name.value, 'Marco');
      expect(form.phone.value, isNull);
      expect(form.phone.defined, isTrue);
      expect(form.note.value, 'vip');
    });

    test('notifies the Form once', () {
      final form = contactForm();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.replace(const Contact(id: 2, name: 'Marco', note: 'vip'));

      expect(notifications, 1);
    });

    test('never marks a Field as touched', () {
      final form = contactForm();

      form.replace(const Contact(id: 2, name: 'Marco'));

      expect(form.name.state.touched, isFalse);
    });

    test('makes the Form dirty until the initial state is replaced back', () {
      final form = contactForm();

      form.replace(const Contact(id: 2, name: 'Marco'));
      expect(form.state.meta.dirty, isTrue);

      form.replace(const Contact(id: 1, name: 'Angelo', phone: '123'));
      expect(form.state.meta.dirty, isFalse);
    });
  });

  group('reset', () {
    test('restores the initial values and presence', () {
      final form = ContactForm(id: 1, name: 'Angelo');
      form.patch(name: 'Marco', phone: '456', id: 9);
      form.note.clear();

      form.reset();

      expect(form.name.value, 'Angelo');
      expect(form.phone.defined, isFalse);
      expect(form.note.value, 'none');
      expect(form.note.defined, isTrue);
      expect(form.id.value, 1);
      expect(form.state.meta.dirty, isFalse);
      expect(form.state.meta.status, FormidableStatus.valid);
    });

    test('clears errors and touched', () {
      final form = contactForm();
      form.name.setValue('M');
      form.name.touch();
      expect(form.name.state.errors, isNotEmpty);

      form.reset();

      expect(form.name.state.errors, isEmpty);
      expect(form.name.state.touched, isFalse);
    });

    test('brings back a Field that started Unset', () {
      final form = ContactForm(id: 1);
      form.name.setValue('Angelo');

      form.reset();

      expect(form.name.defined, isFalse);
      expect(form.name.state.errors, [isA<FormidableRequiredError>()]);
    });

    test('notifies the Form once', () {
      final form = contactForm();
      form.patch(name: 'Marco', phone: '456', id: 3);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.reset();

      expect(notifications, 1);
    });

    test('restores the initial state exactly, without rerunning Effects', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');
      form.country.setValue('FR');
      expect(form.province.defined, isFalse);

      form.reset();

      expect(form.country.value, 'IT');
      expect(form.province.value, 'MI');
      expect(form.revision.value, 0);
      expect(form.state.meta.dirty, isFalse);
    });
  });

  group('commit', () {
    test('makes the current state the initial state', () {
      final form = contactForm();
      form.patch(name: 'Marco', phone: '456', id: 3);
      expect(form.state.meta.dirty, isTrue);

      form.commit();

      expect(form.state.meta.dirty, isFalse);
      expect(form.name.state.dirty, isFalse);
      expect(form.phone.state.dirty, isFalse);
      expect(form.name.value, 'Marco');
    });

    test('is what reset returns to afterwards', () {
      final form = contactForm();
      form.patch(name: 'Marco', id: 3);
      form.commit();
      form.patch(name: 'Luca', id: 4);

      form.reset();

      expect(form.name.value, 'Marco');
      expect(form.id.value, 3);
    });

    test('notifies the Form once when it stops being dirty', () {
      final form = contactForm();
      form.patch(id: 3);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.commit();

      expect(notifications, 1);
      expect(form.state.meta.dirty, isFalse);
    });

    test('a Field changed back to the committed value is clean', () {
      final form = contactForm();
      form.patch(name: 'Marco');
      form.commit();

      form.name.setValue('Luca');
      expect(form.name.state.dirty, isTrue);
      form.name.setValue('Marco');
      expect(form.name.state.dirty, isFalse);
    });
  });

  group('dirty', () {
    test('is cleared when every Field returns to its initial state', () {
      final form = contactForm();

      form.patch(name: 'Marco', phone: '456');
      expect(form.state.meta.dirty, isTrue);

      form.patch(name: 'Angelo', phone: '123');
      expect(form.state.meta.dirty, isFalse);
    });

    test('takes its initial snapshot after the creation-time Form Effects', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      // The Effects derived the label while the Form was being created.
      expect(form.label.value, 'IT/MI');
      expect(form.label.state.dirty, isFalse);
      expect(form.state.meta.dirty, isFalse);

      form.reset();
      expect(form.label.value, 'IT/MI');
    });
  });
}

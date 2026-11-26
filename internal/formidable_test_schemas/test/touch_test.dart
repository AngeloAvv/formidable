import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/effects.dart' as fx;
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:test/test.dart';

ItineraryForm itinerary() {
  final form = ItineraryForm(
    title: 'Rome',
    contact: const Address(street: 'Via Roma'),
    phones: const [
      Telephone(number: '111'),
      Telephone(number: '222'),
    ],
  );
  addTearDown(form.dispose);
  return form;
}

/// Counts the notifications of [form] until the test is over.
List<int> count(FormidableForm<Object?> form) {
  final calls = <int>[0];
  void listener() => calls[0]++;
  form.addListener(listener);
  addTearDown(() => form.removeListener(listener));
  return calls;
}

void main() {
  group('Form.touch()', () {
    test('touches every Field below the Form with one notification', () {
      final form = itinerary();
      final extra = form.extras.register<int>('age');
      final calls = count(form);

      form.touch();

      expect(calls[0], 1);
      expect(form.title.state.touched, isTrue);
      expect(form.footer.state.touched, isTrue);
      expect(form.contact.street.state.touched, isTrue);
      expect(form.contact.zip.state.touched, isTrue);
      expect(form.phones.state.touched, isTrue);
      for (final item in form.phones.items) {
        expect(item.node.number.state.touched, isTrue);
        expect(item.node.label.state.touched, isTrue);
      }
      expect(extra.state.touched, isTrue);
    });

    test('does not mark the Form as submitted or change values', () {
      final form = itinerary();

      form.touch();

      expect(form.title.state.submitted, isFalse);
      expect(form.title.value, 'Rome');
      expect(form.state.meta.dirty, isFalse);
    });

    test('is not a notification when everything is already touched', () {
      final form = itinerary()..touch();
      final calls = count(form);

      form.touch();

      expect(calls[0], 0);
    });

    test('shows the errors of untouched Fields', () {
      final form = ContactForm();
      expect(form.name.state.touched, isFalse);

      form.touch();

      expect(form.name.state.touched, isTrue);
      expect(form.name.state.errors, isNotEmpty);
    });

    test('leaves an Unset optional Nested Form alone', () {
      final form = ContactForm();
      expect(form.work.defined, isFalse);

      form.touch();

      expect(form.home.street.state.touched, isTrue);
      expect(form.work.street.state.touched, isFalse);
    });

    test('on a Nested Form touches it with one notification of the root', () {
      final form = itinerary();
      final calls = count(form);

      form.contact.touch();

      expect(calls[0], 1);
      expect(form.contact.street.state.touched, isTrue);
      expect(form.title.state.touched, isFalse);
    });

    test('reaches the items of a Field Array added later', () {
      final form = itinerary();
      form.touch();

      form.phones.add(const Telephone(number: '333'));

      expect(form.phones.items.last.node.number.state.touched, isFalse);
      form.touch();
      expect(form.phones.items.last.node.number.state.touched, isTrue);
    });
  });

  group('untouch()', () {
    test('Field clears touched, and nothing else', () {
      final form = itinerary();
      form.title.setValue('Oslo');
      form.title.touch();

      form.title.untouch();

      expect(form.title.state.touched, isFalse);
      expect(form.title.value, 'Oslo');
      expect(form.title.state.dirty, isTrue);
    });

    test('Field does not notify when it was not touched', () {
      final form = itinerary();
      final calls = count(form);

      form.title.untouch();

      expect(calls[0], 0);
    });

    test('Form clears touched everywhere with one notification', () {
      final form = itinerary();
      final extra = form.extras.register<int>('age');
      form.title.setValue('Oslo');
      form.touch();
      final calls = count(form);

      form.untouch();

      expect(calls[0], 1);
      expect(form.title.state.touched, isFalse);
      expect(form.contact.street.state.touched, isFalse);
      expect(form.phones.state.touched, isFalse);
      for (final item in form.phones.items) {
        expect(item.node.number.state.touched, isFalse);
      }
      expect(extra.state.touched, isFalse);
      // Values and dirty state are untouched.
      expect(form.title.value, 'Oslo');
      expect(form.state.meta.dirty, isTrue);
    });

    test('Field Array clears itself and its items with one notification', () {
      final form = itinerary()..touch();
      final calls = count(form);

      form.phones.untouch();

      expect(calls[0], 1);
      expect(form.phones.state.touched, isFalse);
      for (final item in form.phones.items) {
        expect(item.node.number.state.touched, isFalse);
      }
      expect(form.title.state.touched, isTrue);
    });

    test('Dynamic Form touches and untouches what is registered', () {
      final form = itinerary();
      final age = form.extras.register<int>('age');
      final calls = count(form);

      form.extras.touch();
      expect(calls[0], 1);
      expect(age.state.touched, isTrue);
      expect(form.title.state.touched, isFalse);

      form.extras.untouch();
      expect(calls[0], 2);
      expect(age.state.touched, isFalse);
    });

    test('submit() still touches and marks submitted', () async {
      final form = itinerary();

      await form.submit();

      expect(form.title.state.touched, isTrue);
      expect(form.title.state.submitted, isTrue);
    });
  });

  group('A Field named like an action', () {
    test('a plain Form still exposes touch', () {
      final form = SignUpForm();
      addTearDown(form.dispose);

      form.touch();

      expect(form.username.state.touched, isTrue);
    });
  });

  group('setValue(value, touched: true)', () {
    test('writes and touches with one notification', () {
      final form = itinerary();
      final calls = count(form);

      form.title.setValue('Oslo', touched: true);

      expect(calls[0], 1);
      expect(form.title.value, 'Oslo');
      expect(form.title.state.touched, isTrue);
    });

    test('touches even when the value does not change', () {
      final form = itinerary();
      final calls = count(form);

      form.title.setValue('Rome', touched: true);

      expect(calls[0], 1);
      expect(form.title.state.touched, isTrue);
      expect(form.title.state.dirty, isFalse);
    });

    test('without touched it leaves touched alone', () {
      final form = itinerary();

      form.title.setValue('Oslo');

      expect(form.title.state.touched, isFalse);
    });

    test('does not notify when nothing changes', () {
      final form = itinerary();
      form.title.touch();
      final calls = count(form);

      form.title.setValue('Rome', touched: true);

      expect(calls[0], 0);
    });

    test('shows the error of the new value at once', () {
      final form = itinerary();

      form.title.setValue('a', touched: true);

      expect(form.title.state.touched, isTrue);
      expect(form.title.state.errors, isNotEmpty);
    });

    test('works on a standalone Field with one notification', () {
      final field = FormidableField<String>();
      addTearDown(field.dispose);
      var calls = 0;
      field.addListener(() => calls++);

      field.setValue('x', touched: true);

      expect(calls, 1);
      expect(field.state.touched, isTrue);
    });
  });

  group('setValue(touched:) and Form Effects', () {
    test('a touch-only write does not count as a change for Effects', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.country.setValue('IT', touched: true);

      expect(form.province.value, 'MI');
      expect(form.country.state.touched, isTrue);
      expect(notifications, 1);
    });

    test('a real change touches and runs the Effects once', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.country.setValue('FR', touched: true);

      expect(form.province.defined, isFalse);
      expect(form.country.state.touched, isTrue);
      expect(notifications, 1);
    });
  });

  group('setValue(touched:) in a batch', () {
    test('touch-only writes publish once, when the batch ends', () {
      final form = fx.AddressForm(revision: 0, country: 'IT', province: 'MI');
      addTearDown(form.dispose);
      var notifications = 0;
      form.addListener(() => notifications++);

      form.batch(() {
        form.country.setValue('IT', touched: true);
        form.province.setValue('MI', touched: true);
        expect(notifications, 0);
      });

      expect(notifications, 1);
      expect(form.country.state.touched, isTrue);
      expect(form.province.state.touched, isTrue);
      expect(form.province.value, 'MI');
    });
  });
}

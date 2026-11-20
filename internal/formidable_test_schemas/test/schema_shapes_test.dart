import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/schema_shapes.dart';
import 'package:test/test.dart';

void main() {
  group('inherited fields and getters', () {
    test('an inherited Field is a Field of the Form', () async {
      final form = CustomerForm()
        ..id.setValue(7)
        ..name.setValue('Ada');

      final result = await form.submit();

      final valid = result as FormidableSubmitValid<Customer>;
      expect(valid.value.id, 7);
      expect(valid.value.name, 'Ada');
    });

    test('an unset inherited Field is required', () async {
      final form = CustomerForm()..name.setValue('Ada');

      final result = await form.submit();

      final invalid = result as FormidableSubmitInvalid<Customer>;
      expect(invalid.errors[form.id], [isA<FormidableRequiredError>()]);
    });

    test('a Form built from an instance carries the inherited Field', () {
      final form = CustomerForm.from(const Customer(id: 3, name: 'Grace'));

      expect(form.id.value, 3);
      expect(form.name.value, 'Grace');
    });

    test('a getter does not become a Field and is still usable', () async {
      final form = CustomerForm.from(const Customer(id: 3, name: 'Grace'));

      final result = await form.submit();

      expect(
        (result as FormidableSubmitValid<Customer>).value.label,
        'Grace#3',
      );
    });
  });

  group('positional constructors', () {
    test('positional parameters are filled from the matching Fields', () async {
      final form = CoordinatesForm()
        ..latitude.setValue(45.5)
        ..longitude.setValue(9.2)
        ..label.setValue('Milan');

      final result = await form.submit();

      final value = (result as FormidableSubmitValid<Coordinates>).value;
      expect(value.latitude, 45.5);
      expect(value.longitude, 9.2);
      expect(value.label, 'Milan');
    });

    test(
      'an optional positional parameter default is used when Unset',
      () async {
        final form = CoordinatesForm()
          ..latitude.setValue(1)
          ..longitude.setValue(2);

        final result = await form.submit();

        expect(
          (result as FormidableSubmitValid<Coordinates>).value.label,
          'unnamed',
        );
      },
    );

    test('Fields follow declaration order, not constructor order', () async {
      final form = MixedForm();

      final result = await form.submit();

      final invalid = result as FormidableSubmitInvalid<Mixed>;
      expect(invalid.errors.keys, [form.first, form.second]);
    });

    test('positional and named parameters land in the right place', () async {
      final form = MixedForm()
        ..first.setValue('a')
        ..second.setValue(2);

      final result = await form.submit();

      final value = (result as FormidableSubmitValid<Mixed>).value;
      expect(value.first, 'a');
      expect(value.second, 2);
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/normalizers.dart';
import 'package:test/test.dart';

void main() {
  group('@Trim()', () {
    test('trims the value when it is written', () {
      final form = ContactForm();

      form.name.setValue('  Ada  ');

      expect(form.name.value, 'Ada');
      expect(form.name.isSet, isTrue);
    });

    test('turns whitespace-only text into Unset, which a required Field '
        'reports', () {
      final form = ContactForm(name: 'Ada');

      form.name.setValue(' \t\n ');

      expect(form.name.isSet, isFalse);
      expect(form.name.value, isNull);
      expect(form.name.state.errors, [isA<FormidableRequiredError>()]);
    });

    test('turns whitespace-only text into Unset on an optional Field',
        () async {
      final form = ContactForm(name: 'Ada', handle: 'ada');
      form.nickname.setValue('Lady');

      form.nickname.setValue('   ');

      expect(form.nickname.isSet, isFalse);
      final valid = await form.submit() as FormidableSubmitValid<Contact>;
      expect(valid.value.nickname, isNull);
    });

    test('runs before the Validators', () {
      final form = ContactForm();

      form.handle.setValue('  ab  ');

      expect(form.handle.state.errors, [
        const FormidableMinLengthError(minLength: 3, actualLength: 2),
      ]);

      form.handle.setValue('  abc  ');

      expect(form.handle.value, 'abc');
      expect(form.handle.state.errors, isEmpty);
    });

    test('normalizes the initial values of the Form too', () {
      final form = ContactForm.from(
        const Contact(name: '  Ada ', handle: ' abc '),
      );

      expect(form.name.value, 'Ada');
      expect(form.handle.value, 'abc');
      expect(form.handle.state.errors, isEmpty);
    });

    test('keeps whitespace on a Field that does not declare it', () {
      // No Normalizer applies unless it is declared (ADR: opt-in trimming).
      final form = ContactForm();

      form.note.setValue('  ');

      expect(form.note.isSet, isTrue);
      expect(form.note.value, '  ');
    });

    test('a nullable Field keeps a chosen null', () {
      final form = ContactForm();

      form.nickname.setValue(null);

      expect(form.nickname.isSet, isTrue);
      expect(form.nickname.value, isNull);
    });
  });
}

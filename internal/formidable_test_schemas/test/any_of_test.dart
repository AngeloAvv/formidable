import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/any_of.dart';
import 'package:test/test.dart';

void main() {
  group('AnyOf', () {
    test('passes when the first Validator passes', () {
      final form = ContactForm()..email.setValue('someone@example.com');

      expect(form.email.state.errors, isEmpty);
    });

    test('passes when only a later Validator passes', () {
      final form = ContactForm()..email.setValue('+390000000000');

      expect(form.email.state.errors, isEmpty);
    });

    test('fails with the errors of every alternative when none passes', () {
      final form = ContactForm()..email.setValue('no');

      final error = form.email.state.errors.single as FormidableAnyOfError;
      expect(error.failures, hasLength(2));
      expect(error.failures[0], [isA<AtSignError>()]);
      expect(error.failures[1], [isA<FormidableMinLengthError>()]);
    });

    test('does not run while the Field is Unset', () {
      expect(ContactForm().email.state.errors, [
        isA<FormidableRequiredError>(),
      ]);
    });

    test('is skipped when null is chosen for a nullable Field', () {
      final form = ContactForm()..fax.setValue(null);

      expect(form.fax.state.errors, isEmpty);
    });

    test('counts as one error in the order of the annotations', () {
      final form = ContactForm()..tagged.setValue('a');

      expect(form.tagged.state.errors, [
        isA<FormidableMinLengthError>(),
        isA<FormidableAnyOfError>(),
      ]);
    });
  });
}

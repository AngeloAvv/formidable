import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/pipeline_order.dart';
import 'package:test/test.dart';

void main() {
  group('Form Validator after Field Validators', () {
    test('sees the Field errors of the write that triggered it', () {
      final form = NewPasswordForm(password: 'short', confirmation: 'other');
      expect(form.confirmation.state.errors, isEmpty);

      form.password.setValue('long-enough');

      expect(form.confirmation.state.errors, [
        const ConfirmationMismatchError(),
      ]);
    });

    test('stops judging once the Field it reads becomes invalid', () {
      final form = NewPasswordForm(
        password: 'long-enough',
        confirmation: 'other',
      );
      expect(form.confirmation.state.errors, [
        const ConfirmationMismatchError(),
      ]);

      form.password.setValue('short');

      expect(form.confirmation.state.errors, isEmpty);
    });

    test('notifies the Form once per change', () {
      final form = NewPasswordForm(password: 'short', confirmation: 'other');
      var count = 0;
      form.addListener(() => count++);

      form.password.setValue('long-enough');

      expect(count, 1);
    });

    test(
      'notifies the Field once when both its own and the Form errors move',
      () {
        final form = NewPasswordForm(password: 'short', confirmation: 'other');
        var count = 0;
        form.password.addListener(() => count++);

        form.password.setValue('long-enough');

        expect(count, 1);
      },
    );
  });
}

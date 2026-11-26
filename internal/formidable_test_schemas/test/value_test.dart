import 'package:formidable_test_schemas/presence.dart';
import 'package:test/test.dart';

void main() {
  group('Field value', () {
    test(
      'throws while the Field is Unset, naming the Field and the ways out',
      () {
        final form = PresenceForm();

        expect(form.email.defined, isFalse);
        expect(
          () => form.email.value,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('`email`'),
                contains('`defined`'),
                contains('`valueOrNull`'),
              ),
            ),
          ),
        );
        expect(form.email.valueOrNull, isNull);
      },
    );

    test('the state throws as the Field does', () {
      final form = PresenceForm();

      expect(() => form.email.state.value, throwsStateError);
      expect(form.email.state.valueOrNull, isNull);

      form.email.setValue('a@b.c');

      expect(form.email.state.value, 'a@b.c');
      expect(form.email.value, 'a@b.c');
      expect(form.email.valueOrNull, 'a@b.c');
    });

    test(
      'a nullable Field holding null returns null, and Unset still throws',
      () {
        final form = PresenceForm(email: 'a@b.c');

        expect(() => form.nickname.value, throwsStateError);

        form.nickname.setValue(null);

        expect(form.nickname.defined, isTrue);
        expect(form.nickname.value, isNull);
        expect(form.nickname.state.value, isNull);
        expect(form.nickname.valueOrNull, isNull);
      },
    );

    test('a Field with a default is defined, so it reads', () {
      expect(PresenceForm().bio.value, 'none');
    });
  });

  group('Form value', () {
    test(
      'throws while the Form is invalid, pointing to submit and valueOrNull',
      () {
        final form = PresenceForm();

        expect(form.state.meta.valid, isFalse);
        expect(
          () => form.value,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(contains('submit()'), contains('valueOrNull')),
            ),
          ),
        );
        expect(() => form.state.meta.value, throwsStateError);
        expect(form.valueOrNull, isNull);
        expect(form.state.meta.valueOrNull, isNull);
      },
    );

    test('returns the Schema instance once the Form is valid', () {
      final form = PresenceForm(email: 'a@b.c', mood: true);

      expect(form.state.meta.valid, isTrue);
      expect(form.value.email, 'a@b.c');
      expect(form.valueOrNull?.email, 'a@b.c');
      expect(form.state.meta.value.email, 'a@b.c');
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/presence.dart';
import 'package:test/test.dart';

void main() {
  group('@Required() on a nullable Field', () {
    test('blocks submit while the Field is Unset', () async {
      final form = PresenceForm(email: 'a@b.c');

      final result = await form.submit();

      final invalid = result as FormidableSubmitInvalid<Presence>;
      expect(invalid.fieldErrors.keys, [form.mood]);
      expect(invalid.fieldErrors[form.mood], [isA<FormidableRequiredError>()]);
    });

    test('accepts null as a chosen value', () async {
      final form = PresenceForm(email: 'a@b.c')..mood.setValue(null);

      final valid = await form.submit() as FormidableSubmitValid<Presence>;

      expect(valid.value.mood, isNull);
    });

    test('accepts a value, and clear() makes it Unset again', () async {
      final form = PresenceForm(email: 'a@b.c', mood: true);
      expect((await form.submit()) is FormidableSubmitValid<Presence>, isTrue);

      form.mood.clear();

      expect(form.mood.isSet, isFalse);
      expect(form.mood.state.errors, [isA<FormidableRequiredError>()]);
    });
  });

  group('the output of an Unset Field', () {
    test(
      'uses the default first, then null, and a required Field errors',
      () async {
        final form = PresenceForm(email: 'a@b.c', mood: false);

        final valid = await form.submit() as FormidableSubmitValid<Presence>;

        expect(valid.value.bio, 'none'); // default
        expect(valid.value.age, 18); // default
        expect(valid.value.nickname, isNull); // nullable, no default

        final missing = await PresenceForm(mood: false).submit();
        final invalid = missing as FormidableSubmitInvalid<Presence>;
        expect(invalid.fieldErrors.keys, hasLength(1)); // email, no output
      },
    );

    test('a Field set to null is different from an Unset Field', () {
      final unset = PresenceForm(email: 'a@b.c');
      final chosen = PresenceForm(email: 'a@b.c')..nickname.setValue(null);

      expect(unset.nickname.isSet, isFalse);
      expect(chosen.nickname.isSet, isTrue);
      expect(unset.nickname.value, chosen.nickname.value);
      expect(unset.nickname.state, isNot(chosen.nickname.state));
    });

    test('a defaulted Field starts with its default and returns to it', () {
      final form = PresenceForm(email: 'a@b.c');
      expect(form.bio.isSet, isTrue);
      expect(form.bio.value, 'none');

      form.bio.setValue('hi');
      form.bio.clear();

      expect(form.bio.isSet, isFalse);
    });
  });
}

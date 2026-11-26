import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/dynamic.dart';
import 'package:formidable_test_schemas/string_catalog.dart';
import 'package:test/test.dart';

void main() {
  group('dynamic Validators', () {
    test('validators lists the annotation Validators, unmodifiable', () {
      final form = StringCatalogForm();

      expect(form.maxLength.validators, [const MaxLength(5)]);
      expect(
        () => form.maxLength.validators.add(const MinLength(1)),
        throwsUnsupportedError,
      );
    });

    test('a consumer reads a Schema constraint from validators', () {
      final form = StringCatalogForm();

      final max = form.maxLength.validators
          .whereType<MaxLength>()
          .map((validator) => validator.maxLength)
          .firstOrNull;

      expect(max, 5);
    });

    test('addValidator revalidates at once with one notification', () {
      final form = StringCatalogForm()..maxLength.setValue('abc');
      var notifications = 0;
      form.maxLength.addListener(() => notifications++);

      form.maxLength.addValidator(const MinLength(5));

      expect(notifications, 1);
      expect(form.maxLength.state.errors, hasLength(1));
      expect(form.maxLength.validators, [
        const MaxLength(5),
        const MinLength(5),
      ]);
    });

    test('removeValidator revalidates and only removes added ones', () {
      final form = StringCatalogForm()..maxLength.setValue('abc');
      const minimum = MinLength(5);
      form.maxLength.addValidator(minimum);
      var notifications = 0;
      form.maxLength.addListener(() => notifications++);

      expect(form.maxLength.removeValidator(minimum), isTrue);
      expect(notifications, 1);
      expect(form.maxLength.state.errors, isEmpty);

      expect(form.maxLength.removeValidator(const MaxLength(5)), isFalse);
      expect(form.maxLength.validators, [const MaxLength(5)]);
      expect(notifications, 1);
    });

    test('rejects a Validator that does not fit the Field type', () {
      final form = StringCatalogForm();

      expect(
        () => form.maxLength.addValidator(const Min(1)),
        throwsArgumentError,
      );
    });

    test('works on a Dynamic Form Field', () {
      final form = SurveyForm()..title.setValue('Pets');
      final age = form.answers.register<int>('age')..setValue(3);

      age.addValidator(const Min(5));

      expect(age.state.errors, isNotEmpty);
      expect(form.state.meta.valid, isFalse);
    });

    test('added Validators are skipped while the Field is disabled', () {
      final form = StringCatalogForm()..maxLength.setValue('abc');
      form.maxLength.disable();

      form.maxLength.addValidator(const MinLength(5));
      expect(form.maxLength.state.errors, isEmpty);

      form.maxLength.enable();
      expect(form.maxLength.state.errors, hasLength(1));
    });

    test(
      'added Validators are skipped while a container above is disabled',
      () {
        final form = StringCatalogForm()..maxLength.setValue('abc');
        addTearDown(form.dispose);
        form.disable();

        form.maxLength.addValidator(const MinLength(5));
        expect(form.maxLength.state.errors, isEmpty);
        expect(form.maxLength.state.enabled, isFalse);

        form.enable();
        expect(form.maxLength.state.errors, hasLength(1));
      },
    );
  });
}

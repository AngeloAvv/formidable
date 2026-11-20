import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/dynamic.dart';
import 'package:test/test.dart';

void main() {
  group('Dynamic Form registration', () {
    test('registers a Field under a key and outputs a map of the values',
        () async {
      final form = SurveyForm()..title.setValue('Pets');

      form.answers.register<int>('age').setValue(7);
      form.answers.register<String?>('nickname').setValue('Rex');

      final result = await form.submit();

      final valid = result as FormidableSubmitValid<Survey>;
      expect(valid.value.title, 'Pets');
      expect(valid.value.answers, {'age': 7, 'nickname': 'Rex'});
    });

    test('starts with an empty map', () {
      final form = SurveyForm()..title.setValue('Pets');

      expect(form.value!.answers, isEmpty);
    });

    test('rejects a second Field under the same key', () {
      final form = SurveyForm()..answers.register<int>('age');

      expect(
        () => form.answers.register<int>('age'),
        throwsA(isA<FormidableDynamicKeyError>()),
      );
    });

    test('outputs the values in registration order', () {
      final form = SurveyForm()..title.setValue('Pets');

      form.answers.register<String?>('b');
      form.answers.register<String?>('a');

      expect(form.value!.answers.keys, ['b', 'a']);
    });

    test('an optional Field outputs null, a Field with a default its default',
        () {
      final form = SurveyForm()..title.setValue('Pets');

      form.answers.register<String?>('nickname');
      form.answers.register<int>('legs', defaultValue: 4);

      expect(form.value!.answers, {'nickname': null, 'legs': 4});
    });
  });

  group('Dynamic Form lookup', () {
    test('returns the registered Field', () {
      final form = SurveyForm();
      final age = form.answers.register<int>('age');

      expect(form.answers.field<int>('age'), same(age));
      expect(form.answers.contains('age'), isTrue);
      expect(form.answers.keys, ['age']);
    });

    test('fails with a clear error when the type does not match', () {
      final form = SurveyForm()..answers.register<int>('age');

      expect(
        () => form.answers.field<String>('age'),
        throwsA(
          isA<FormidableDynamicTypeError>().having(
            (e) => e.message,
            'message',
            allOf(contains('"age"'), contains('int'), contains('String')),
          ),
        ),
      );
    });

    test('treats a nullable type as another type', () {
      final form = SurveyForm()..answers.register<int>('age');

      expect(
        () => form.answers.field<int?>('age'),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
    });

    test('fails when nothing is registered under the key', () {
      final form = SurveyForm();

      expect(
        () => form.answers.field<int>('age'),
        throwsA(isA<FormidableDynamicKeyError>()),
      );
    });

    test('fails when a Field is looked up as a Nested Form and the reverse',
        () {
      final form = SurveyForm()
        ..answers.register<int>('age')
        ..answers.registerForm('home', PlaceForm());

      expect(
        () => form.answers.form<PlaceForm>('age'),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
      expect(
        () => form.answers.field<int>('home'),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
    });
  });

  group('Dynamic Form removal', () {
    test('removes a Field from the output', () {
      final form = SurveyForm()..title.setValue('Pets');
      form.answers.register<int>('age').setValue(7);
      form.answers.register<int>('legs').setValue(4);

      form.answers.remove('age');

      expect(form.answers.contains('age'), isFalse);
      expect(form.value!.answers, {'legs': 4});
    });

    test('lets the key be registered again', () {
      final form = SurveyForm()..answers.register<int>('age');

      form.answers.remove('age');
      form.answers.register<String>('age').setValue('seven');

      expect(form.answers.field<String>('age').value, 'seven');
    });

    test('makes the Form valid again when the invalid Field goes away', () {
      final form = SurveyForm()..title.setValue('Pets');
      form.answers.register<int>('age');
      expect(form.state.status, FormidableStatus.invalid);

      form.answers.remove('age');

      expect(form.state.status, FormidableStatus.valid);
    });

    test('fails when nothing is registered under the key', () {
      final form = SurveyForm();

      expect(
        () => form.answers.remove('age'),
        throwsA(isA<FormidableDynamicKeyError>()),
      );
    });
  });

  group('Dynamic Form validation', () {
    test('a required Field blocks the Form until it has a value', () {
      final form = SurveyForm()..title.setValue('Pets');

      final age = form.answers.register<int>('age');
      expect(form.value, isNull);
      expect(age.state.errors, [isA<FormidableRequiredError>()]);

      age.setValue(7);
      expect(form.value, isNotNull);
    });

    test('runs the Validator instances given at registration', () {
      final form = SurveyForm()..title.setValue('Pets');

      final nickname = form.answers.register<String?>(
        'nickname',
        validators: const [MinLength(3)],
      )..setValue('Re');

      expect(nickname.state.errors, [isA<FormidableMinLengthError>()]);
      expect(form.state.status, FormidableStatus.invalid);
      nickname.setValue('Rex');
      expect(form.state.status, FormidableStatus.valid);
    });

    test('accepts a Validator typed for a supertype of the Field', () {
      final form = SurveyForm();

      expect(
        () => form.answers.register<int>('age', validators: const [Min(0)]),
        returnsNormally,
      );
    });

    test('rejects a Validator that does not fit the type', () {
      final form = SurveyForm();

      expect(
        () => form.answers.register<int>(
          'age',
          validators: const [MinLength(3)],
        ),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
      expect(form.answers.contains('age'), isFalse);
    });

    test('applies the Normalizers given at registration', () {
      final form = SurveyForm();

      final name = form.answers.register<String>(
        'name',
        normalizers: const [Trim()],
      )..setValue('  Rex ');

      expect(name.value, 'Rex');
    });

    test('shows errors on submit and moves invalid Fields into the result',
        () async {
      final form = SurveyForm()..title.setValue('Pets');
      final age = form.answers.register<int>('age');

      final result = await form.submit();

      final invalid = result as FormidableSubmitInvalid<Survey>;
      expect(invalid.fieldErrors.keys, [age]);
      expect(age.state.touched, isTrue);
    });

    test('applied server errors reach a dynamic Field', () {
      final form = SurveyForm()..title.setValue('Pets');
      final age = form.answers.register<int>('age')..setValue(7);

      form.applyErrors(fieldErrors: {age: const [PasswordMismatch()]});

      expect(age.state.errors, [isA<PasswordMismatch>()]);
      expect(form.state.status, FormidableStatus.invalid);
    });
  });

  group('Dynamic Form with Nested Forms', () {
    test('registers a Nested Form and outputs its Schema instance', () {
      final form = SurveyForm()..title.setValue('Pets');
      final home = form.answers.registerForm('home', PlaceForm());
      home.street.setValue('Via Roma');

      expect(form.answers.form<PlaceForm>('home'), same(home));
      expect(form.value!.answers['home'], isA<Place>());
      expect((form.value!.answers['home']! as Place).street, 'Via Roma');
    });

    test('an invalid Nested Form makes the Form invalid', () {
      final form = SurveyForm()..title.setValue('Pets');
      final home = form.answers.registerForm('home', PlaceForm());

      expect(form.value, isNull);
      home.street.setValue('Via Roma');
      expect(form.value, isNotNull);
    });

    test('an Unset optional Nested Form outputs null and blocks nothing', () {
      final form = SurveyForm()..title.setValue('Pets');
      form.answers.registerForm('home', PlaceForm()..markOptional(initiallySet: false));

      expect(form.value!.answers, {'home': null});
    });

    test('lists the Fields of a Nested Form in the submit errors', () async {
      final form = SurveyForm()..title.setValue('Pets');
      final home = form.answers.registerForm('home', PlaceForm());

      final result = await form.submit();

      expect(
        (result as FormidableSubmitInvalid<Survey>).fieldErrors.keys,
        [home.street],
      );
    });
  });

  group('Dynamic Form in the pipeline', () {
    test('a Form Effect reacts to a dynamic Field and writes another one', () {
      final form = QuestionnaireForm()..title.setValue('Trip');
      final country = form.answers.register<String>('country');
      final province = form.answers.register<String?>('province');
      country.setValue('IT');
      province.setValue('RM');

      country.setValue('FR');

      expect(province.isSet, isFalse);
    });

    test('a Form Effect reacts to a typed Field and writes a dynamic one', () {
      final form = QuestionnaireForm()..title.setValue('Trip');
      final slug = form.answers.register<String?>('slug');

      form.title.setValue('Road Trip');

      expect(slug.value, 'Road Trip');
    });

    test('registering a Field is a change: the Form Effects see it', () {
      final form = QuestionnaireForm(answers: {'province': 'RM'})
        ..title.setValue('Trip');
      final province = form.answers.register<String?>('province');
      expect(province.value, 'RM');

      // The new Field counts as changed, so the Effect clears the province.
      form.answers.register<String>('country');

      expect(province.isSet, isFalse);
    });

    test('a Form Validator addresses dynamic Fields', () {
      final form = QuestionnaireForm()..title.setValue('Trip');
      final password = form.answers.register<String>('password')
        ..setValue('secret');
      final confirm = form.answers.register<String>('confirm')
        ..setValue('other');

      expect(confirm.state.errors, [isA<PasswordMismatch>()]);

      confirm.setValue('secret');
      expect(confirm.state.errors, isEmpty);
      password.setValue('changed');
      expect(confirm.state.errors, [isA<PasswordMismatch>()]);
    });

    test('registering a Field notifies the Form and the Dynamic Form once',
        () {
      final form = SurveyForm()..title.setValue('Pets');
      var formCalls = 0;
      var keyCalls = 0;
      form.addListener(() => formCalls++);
      form.answers.addListener(() => keyCalls++);

      form.answers.register<int>('age');

      expect(formCalls, 1);
      expect(keyCalls, 1);
      expect(form.answers.state.keys, ['age']);
    });

    test('a write to a dynamic Field notifies the Form', () {
      final form = SurveyForm()..title.setValue('Pets');
      final age = form.answers.register<int>('age');
      var formCalls = 0;
      form.addListener(() => formCalls++);

      age.setValue(7);

      expect(formCalls, 1);
      expect(form.state.status, FormidableStatus.valid);
    });
  });

  group('Dynamic Form dirty, reset and commit', () {
    test('registering a Field does not make the Form dirty', () {
      final form = SurveyForm();

      form.answers.register<String?>('nickname');

      expect(form.state.dirty, isFalse);
    });

    test('writing a dynamic Field makes the Form dirty and back again', () {
      final form = SurveyForm();
      final nickname = form.answers.register<String?>('nickname');

      nickname.setValue('Rex');
      expect(form.state.dirty, isTrue);
      expect(form.answers.isDirty, isTrue);

      nickname.clear();
      expect(form.state.dirty, isFalse);
    });

    test('reset restores the values and keeps the Fields registered', () {
      final form = SurveyForm();
      final nickname = form.answers.register<String?>('nickname');
      nickname.setValue('Rex');

      form.reset();

      expect(nickname.isSet, isFalse);
      expect(form.answers.contains('nickname'), isTrue);
      expect(form.state.dirty, isFalse);
    });

    test('commit makes the current values the initial state', () {
      final form = SurveyForm();
      final nickname = form.answers.register<String?>('nickname');
      nickname.setValue('Rex');

      form.commit();
      expect(form.state.dirty, isFalse);

      nickname.setValue('Max');
      form.reset();
      expect(nickname.value, 'Rex');
    });
  });

  group('Dynamic Form initial values, patch and replace', () {
    test('a Field registered under a key of the source starts with its value',
        () {
      final form = SurveyForm.from(
        const Survey(title: 'Pets', answers: {'age': 7}),
      );

      final age = form.answers.register<int>('age');

      expect(age.value, 7);
      expect(form.state.dirty, isFalse);
      expect(form.value!.answers, {'age': 7});
    });

    test('an initial value of the wrong type fails at registration', () {
      final form = SurveyForm.from(
        const Survey(title: 'Pets', answers: {'age': 'seven'}),
      );

      expect(
        () => form.answers.register<int>('age'),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
    });

    test('the partial constructor takes the initial map too', () {
      final form = SurveyForm(answers: {'age': 7});

      expect(form.answers.register<int>('age').value, 7);
    });

    test('patch writes the registered Fields and leaves the others', () {
      final form = SurveyForm();
      final age = form.answers.register<int>('age')..setValue(1);
      final legs = form.answers.register<int>('legs')..setValue(4);

      form.patch(answers: {'age': 9});

      expect(age.value, 9);
      expect(legs.value, 4);
    });

    test('replace makes the registered Fields hold exactly the map', () {
      final form = SurveyForm()..title.setValue('Pets');
      final age = form.answers.register<int>('age')..setValue(1);
      final nickname = form.answers.register<String?>('nickname')
        ..setValue('Rex');

      form.replace(const Survey(title: 'Cats', answers: {'age': 3}));

      expect(form.title.value, 'Cats');
      expect(age.value, 3);
      expect(nickname.isSet, isFalse);
    });

    test('a written value of the wrong type fails with a clear error', () {
      final form = SurveyForm();
      form.answers.register<int>('age');

      expect(
        () => form.patch(answers: {'age': 'seven'}),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
    });

    test('a value for an unregistered key waits for its Field', () {
      final form = SurveyForm();

      form.patch(answers: {'age': 9});

      expect(form.answers.register<int>('age').value, 9);
    });
  });

  group('Dynamic Form focus order', () {
    test('lists typed and dynamic Fields in declaration, then registration, '
        'order', () {
      final form = SurveyForm();
      final age = form.answers.register<int>('age');
      final home = form.answers.registerForm('home', PlaceForm());

      expect(form.focusOrder, [form.title, age, home.street, home.zip]);
    });

    test('drops a removed Field', () {
      final form = SurveyForm();
      form.answers.register<int>('age');

      form.answers.remove('age');

      expect(form.focusOrder, [form.title]);
    });
  });
}

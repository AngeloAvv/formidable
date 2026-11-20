import 'package:fake_async/fake_async.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/async_collections.dart';
import 'package:formidable_test_schemas/async_validation.dart';
import 'package:formidable_test_schemas/dynamic.dart';
import 'package:test/test.dart';

const _debounce = Duration(milliseconds: 300);

MemberForm _add(ClubForm form) {
  form.members.add();
  return form.members.items.last.node;
}

void main() {
  group('Async Validator on a dynamic Field', () {
    test(
      'runs after the debounce with the same lifecycle as a static Field',
      () {
        fakeAsync((async) {
          final usernames = UsernameAvailable();
          final form = SurveyForm()..title.setValue('Pets');
          final username = form.answers.register<String>(
            'username',
            asyncValidators: [usernames],
          );

          username.setValue('alice');
          expect(username.state.pending, isTrue);
          expect(form.isPending, isTrue);
          expect(usernames.calls, isEmpty);

          async.elapse(_debounce);
          expect(usernames.calls, ['alice']);

          usernames.answer('alice', taken: true);
          async.flushMicrotasks();

          expect(username.state.pending, isFalse);
          expect(username.state.errors, [const TakenError('alice')]);
          expect(form.isValid, isFalse);
          expect(form.isPending, isFalse);
        });
      },
    );

    test('a free value leaves the Form valid', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = SurveyForm()..title.setValue('Pets');
        form.answers
            .register<String>('username', asyncValidators: [usernames])
            .setValue('alice');

        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        async.flushMicrotasks();

        expect(form.isValid, isTrue);
        expect(form.value!.answers, {'username': 'alice'});
      });
    });

    test('checks a value offered when the Form was created', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = SurveyForm(answers: {'username': 'alice'})
          ..title.setValue('Pets');

        final username = form.answers.register<String>(
          'username',
          asyncValidators: [usernames],
        );

        expect(username.state.pending, isTrue);
        async.elapse(_debounce);
        expect(usernames.calls, ['alice']);
      });
    });

    test('does not run while a synchronous Validator fails', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = SurveyForm()..title.setValue('Pets');
        final username = form.answers.register<String>(
          'username',
          validators: const [MinLength(3)],
          asyncValidators: [usernames],
        );

        username.setValue('al');
        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
        expect(username.state.pending, isFalse);
        expect(username.state.errors, [isA<FormidableMinLengthError>()]);
      });
    });

    test(
      'submit waits for the check and is invalid when it finds an error',
      () {
        fakeAsync((async) {
          final usernames = UsernameAvailable();
          final form = SurveyForm()..title.setValue('Pets');
          form.answers
              .register<String>('username', asyncValidators: [usernames])
              .setValue('alice');
          FormidableSubmitResult<Survey>? result;

          form.submit().then((value) => result = value);
          async.flushMicrotasks();
          expect(result, isNull);

          async.elapse(_debounce);
          usernames.answer('alice', taken: true);
          async.flushMicrotasks();

          expect(result, isA<FormidableSubmitInvalid<Survey>>());
        });
      },
    );

    test('removing the Field drops its pending check', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = SurveyForm()..title.setValue('Pets');
        form.answers
            .register<String>('username', asyncValidators: [usernames])
            .setValue('alice');
        expect(form.isPending, isTrue);

        form.answers.remove('username');
        async.elapse(const Duration(seconds: 5));

        expect(form.isPending, isFalse);
        expect(usernames.calls, isEmpty);
      });
    });

    test('rejects an Async Validator that does not accept the type', () {
      final form = SurveyForm();

      expect(
        () => form.answers.register<int>(
          'age',
          asyncValidators: [UsernameAvailable()],
        ),
        throwsA(isA<FormidableDynamicTypeError>()),
      );
    });
  });

  group('Async Validator on a Field inside a Field Array item', () {
    ({ClubForm form, UsernameAvailable usernames}) create() {
      final usernames = UsernameAvailable();
      return (
        form: ClubForm(usernameAvailable: usernames),
        usernames: usernames,
      );
    }

    test('an added item checks its Field like a static one', () {
      fakeAsync((async) {
        final (:form, :usernames) = create();
        final member = _add(form);

        member.username.setValue('alice');
        expect(member.username.state.pending, isTrue);
        expect(form.isPending, isTrue);

        async.elapse(_debounce);
        expect(usernames.calls, ['alice']);
        usernames.answer('alice', taken: true);
        async.flushMicrotasks();

        expect(member.username.state.errors, [const TakenError('alice')]);
        expect(form.isValid, isFalse);
        expect(form.isPending, isFalse);
      });
    });

    test('an item created from an instance checks its initial value', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = ClubForm.from(
          const Club(members: [Member(username: 'alice')]),
          usernameAvailable: usernames,
        );

        expect(form.members.items.single.node.username.state.pending, isTrue);
        async.elapse(_debounce);
        expect(usernames.calls, ['alice']);
      });
    });

    test('submit waits for every item and reports the failing Field', () {
      fakeAsync((async) {
        final (:form, :usernames) = create();
        final first = _add(form)..username.setValue('alice');
        final second = _add(form)..username.setValue('bobby');
        FormidableSubmitResult<Club>? result;

        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        usernames
          ..answer('alice', taken: false)
          ..answer('bobby', taken: true);
        async.flushMicrotasks();

        final invalid = result! as FormidableSubmitInvalid<Club>;
        expect(invalid.errors.keys, [second.username]);
        expect(first.username.state.errors, isEmpty);
      });
    });

    test('removing an item drops its pending check', () {
      fakeAsync((async) {
        final (:form, :usernames) = create();
        _add(form).username.setValue('alice');
        expect(form.isPending, isTrue);

        form.members.removeAt(0);
        async.elapse(const Duration(seconds: 5));

        expect(form.isPending, isFalse);
        expect(usernames.calls, isEmpty);
      });
    });
  });
}

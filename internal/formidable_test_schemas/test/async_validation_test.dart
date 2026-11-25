import 'package:fake_async/fake_async.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/async_validation.dart';
import 'package:test/test.dart';

const _debounce = Duration(milliseconds: 300);

({RegistrationForm form, UsernameAvailable usernames, EmailAvailable emails})
_create({String? username, String? email}) {
  final usernames = UsernameAvailable();
  final emails = EmailAvailable();
  final form = RegistrationForm(
    username: username,
    email: email,
    note: 'n',
    usernameAvailable: usernames,
    emailAvailable: emails,
  );
  return (form: form, usernames: usernames, emails: emails);
}

void main() {
  group('Async Validator on a Field', () {
    test('runs after the debounce, and the Field is pending meanwhile', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        expect(form.username.state.pending, isTrue);
        expect(usernames.calls, isEmpty);

        async.elapse(_debounce);
        expect(usernames.calls, ['alice']);
        expect(form.username.state.pending, isTrue);

        usernames.answer('alice', taken: true);
        async.flushMicrotasks();

        expect(form.username.state.pending, isFalse);
        expect(form.username.state.errors, [const TakenError('alice')]);
        expect(form.username.state.valid, isFalse);
      });
    });

    test('a free value leaves the Field valid', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        async.flushMicrotasks();

        expect(form.username.state.pending, isFalse);
        expect(form.username.state.errors, isEmpty);
      });
    });
  });

  group('gating', () {
    test('does not run while the Field is Unset', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
        expect(form.username.state.pending, isFalse);
      });
    });

    test('does not run while a synchronous Validator fails', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('al');
        expect(form.username.state.pending, isFalse);
        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
        expect(form.username.state.errors, [isA<FormidableMinLengthError>()]);
      });
    });

    test('starts when the synchronous Validators start to pass', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('al');
        form.username.setValue('alice');
        async.elapse(_debounce);

        expect(usernames.calls, ['alice']);
      });
    });

    test('checks the value the Form was created with', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create(username: 'alice');

        expect(form.username.state.pending, isTrue);
        async.elapse(_debounce);

        expect(usernames.calls, ['alice']);
      });
    });

    test('a Field without Async Validators is never pending', () {
      fakeAsync((async) {
        final (:form, usernames: _, emails: _) = _create();

        form.note.setValue('other');

        expect(form.note.state.pending, isFalse);
      });
    });
  });

  group('debounce', () {
    test('restarts on every change and checks only the last value', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('ali');
        async.elapse(const Duration(milliseconds: 200));
        form.username.setValue('alic');
        async.elapse(const Duration(milliseconds: 200));
        form.username.setValue('alice');
        async.elapse(const Duration(milliseconds: 299));
        expect(usernames.calls, isEmpty);

        async.elapse(const Duration(milliseconds: 1));
        expect(usernames.calls, ['alice']);
      });
    });

    test('is per Field: typing in one never delays the other', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create();

        form.email.setValue('a@b.c');
        async.elapse(const Duration(milliseconds: 200));
        form.username.setValue('alice');
        async.elapse(const Duration(milliseconds: 100));

        expect(emails.calls, ['a@b.c']);
        expect(usernames.calls, isEmpty);

        async.elapse(const Duration(milliseconds: 200));
        expect(usernames.calls, ['alice']);
      });
    });

    test('a write of the same value does not restart it', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(const Duration(milliseconds: 200));
        form.username.setValue('alice');
        async.elapse(const Duration(milliseconds: 100));

        expect(usernames.calls, ['alice']);
      });
    });
  });

  group('stale results', () {
    test('only the latest value counts, however late the old answer is', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(_debounce);
        form.username.setValue('alicia');
        async.elapse(_debounce);
        expect(usernames.calls, ['alice', 'alicia']);

        usernames.answer('alicia', taken: false);
        async.flushMicrotasks();
        expect(form.username.state.errors, isEmpty);
        expect(form.username.state.pending, isFalse);

        usernames.answer('alice', taken: true);
        async.flushMicrotasks();
        expect(form.username.state.errors, isEmpty);
        expect(form.username.state.pending, isFalse);
      });
    });

    test('an old answer does not end the pending state of the new check', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(_debounce);
        form.username.setValue('alicia');
        async.elapse(_debounce);

        usernames.answer('alice', taken: true);
        async.flushMicrotasks();

        expect(form.username.state.pending, isTrue);
        expect(form.username.state.errors, isEmpty);
      });
    });

    test('the errors of the old value go away as soon as it changes', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(_debounce);
        usernames.answer('alice', taken: true);
        async.flushMicrotasks();
        expect(form.username.state.errors, isNotEmpty);

        form.username.setValue('alicia');

        expect(form.username.state.errors, isEmpty);
        expect(form.username.state.pending, isTrue);
      });
    });
  });

  group('cancellation', () {
    test('going back to Unset during the debounce cancels the check', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        form.username.clear();
        expect(form.username.state.pending, isFalse);
        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
      });
    });

    test('going back to Unset while the check runs drops its answer', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        async.elapse(_debounce);
        form.username.clear();
        expect(form.username.state.pending, isFalse);

        usernames.answer('alice', taken: true);
        async.flushMicrotasks();

        expect(form.username.state.errors, [isA<FormidableRequiredError>()]);
      });
    });

    test('a value that becomes synchronously invalid cancels the check', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        form.username.setValue('al');
        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
        expect(form.username.state.pending, isFalse);
      });
    });

    test('disabling the Field cancels it and enabling starts it again', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        form.username.disable();
        expect(form.username.state.pending, isFalse);
        async.elapse(const Duration(seconds: 5));
        expect(usernames.calls, isEmpty);

        form.username.enable();
        expect(form.username.state.pending, isTrue);
        async.elapse(_debounce);
        expect(usernames.calls, ['alice']);
      });
    });

    test('disposing the Form cancels the check', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();

        form.username.setValue('alice');
        form.dispose();
        async.elapse(const Duration(seconds: 5));

        expect(usernames.calls, isEmpty);
      });
    });
  });

  group('a check that throws', () {
    test('blocks the value with an error that carries the cause', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();
        final cause = StateError('offline');

        form.username.setValue('alice');
        async.elapse(_debounce);
        usernames.fail('alice', cause);
        async.flushMicrotasks();

        expect(form.username.state.pending, isFalse);
        expect(form.username.state.errors, [
          FormidableAsyncCheckFailedError(cause),
        ]);
      });
    });
  });

  group('notifications', () {
    test('the Field notifies when it becomes pending and when it answers', () {
      fakeAsync((async) {
        final (:form, :usernames, emails: _) = _create();
        final seen = <bool>[];
        form.username.addListener(() => seen.add(form.username.state.pending));

        form.username.setValue('alice');
        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        async.flushMicrotasks();

        expect(seen, [true, false]);
      });
    });

    test('the Form is pending while any Field is', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create();

        expect(form.state.meta.pending, isFalse);
        form.username.setValue('alice');
        form.email.setValue('a@b.c');
        expect(form.state.meta.pending, isTrue);

        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        async.flushMicrotasks();
        expect(form.state.meta.pending, isTrue);

        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();
        expect(form.state.meta.pending, isFalse);
      });
    });
  });

  group('Form value and submit', () {
    test('value throws while a check is pending and is set once it passes', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create(
          username: 'alice',
          email: 'a@b.c',
        );

        expect(form.state.meta.status, FormidableStatus.pending);
        expect(form.state.meta.valid, isFalse);
        expect(() => form.value, throwsStateError);
        expect(form.valueOrNull, isNull);

        async.elapse(_debounce);
        expect(form.valueOrNull, isNull);

        usernames.answer('alice', taken: false);
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();

        expect(form.valueOrNull?.username, 'alice');
      });
    });

    test('submit waits for the debounce and the answer before it decides', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create(
          username: 'alice',
          email: 'a@b.c',
        );
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.flushMicrotasks();
        expect(result, isNull);

        async.elapse(_debounce);
        async.flushMicrotasks();
        expect(result, isNull);
        usernames.answer('alice', taken: false);
        async.flushMicrotasks();
        expect(result, isNull);

        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();

        expect(result, isA<FormidableSubmitValid<Registration>>());
      });
    });

    test('submit is invalid when a check found an error', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create(
          username: 'alice',
          email: 'a@b.c',
        );
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        usernames.answer('alice', taken: true);
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();

        final invalid = result as FormidableSubmitInvalid<Registration>;
        expect(invalid.errors[form.username], [const TakenError('alice')]);
        expect(invalid.errors.containsKey(form.email), isFalse);
      });
    });

    test('submit does not wait when nothing is pending', () {
      fakeAsync((async) {
        final (:form, usernames: _, emails: _) = _create();
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.flushMicrotasks();

        expect(result, isA<FormidableSubmitInvalid<Registration>>());
      });
    });

    test('submit also waits for a check that starts while it waits', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create(
          username: 'alice',
          email: 'a@b.c',
        );
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();
        expect(result, isA<FormidableSubmitValid<Registration>>());

        // A second submit after a change waits again.
        result = null;
        form.username.setValue('alicia');
        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        async.flushMicrotasks();
        expect(result, isNull);
        usernames.answer('alicia', taken: true);
        async.flushMicrotasks();
        expect(result, isA<FormidableSubmitInvalid<Registration>>());
      });
    });

    test('the Field the user changes while submit waits is checked too', () {
      fakeAsync((async) {
        final (:form, :usernames, :emails) = _create(
          username: 'alice',
          email: 'a@b.c',
        );
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        usernames.answer('alice', taken: false);
        form.username.setValue('alicia');
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();
        expect(result, isNull);

        async.elapse(_debounce);
        usernames.answer('alicia', taken: true);
        async.flushMicrotasks();

        expect(result, isA<FormidableSubmitInvalid<Registration>>());
      });
    });

    test('disposing the Form releases a waiting submit as invalid', () {
      fakeAsync((async) {
        final (:form, usernames: _, emails: _) = _create(username: 'alice');
        FormidableSubmitResult<Registration>? result;

        form.submit().then((value) => result = value);
        async.flushMicrotasks();
        form.dispose();
        async.flushMicrotasks();

        expect(result, isA<FormidableSubmitInvalid<Registration>>());
      });
    });
  });

  group('cross-field rules count as synchronous validation', () {
    test('does not run while a cross-field rule on the Field fails', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = InvitationForm(
          code: 'abc',
          confirmation: 'abd',
          usernameAvailable: usernames,
        );

        expect(form.confirmation.state.errors, [
          isA<FormidableMustMatchError>(),
        ]);
        expect(form.confirmation.state.pending, isFalse);
        async.elapse(const Duration(seconds: 5));
        expect(usernames.calls, isEmpty);

        form.confirmation.setValue('abc');
        expect(form.confirmation.state.errors, isEmpty);
        expect(form.confirmation.state.pending, isTrue);
        async.elapse(_debounce);
        expect(usernames.calls, ['abc']);
      });
    });

    test('stops a running check when the rule starts to fail', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = InvitationForm(
          code: 'abc',
          confirmation: 'abc',
          usernameAvailable: usernames,
        );
        async.elapse(_debounce);
        expect(usernames.calls, ['abc']);

        form.code.setValue('xyz');
        usernames.answer('abc', taken: true);
        async.flushMicrotasks();

        expect(form.confirmation.state.pending, isFalse);
        expect(form.confirmation.state.errors, [
          isA<FormidableMustMatchError>(),
        ]);
      });
    });

    test('works the same inside a Nested Form', () {
      fakeAsync((async) {
        final usernames = UsernameAvailable();
        final form = ReferralForm(
          invitation: const Invitation(code: 'abc', confirmation: 'abd'),
          note: 'n',
          usernameAvailable: usernames,
        );
        final field = form.invitation.confirmation;

        expect(field.state.errors, [isA<FormidableMustMatchError>()]);
        async.elapse(const Duration(seconds: 5));
        expect(usernames.calls, isEmpty);

        field.setValue('abc');
        async.elapse(_debounce);
        expect(usernames.calls, ['abc']);
        usernames.answer('abc', taken: true);
        async.flushMicrotasks();

        expect(field.state.errors, [isA<TakenError>()]);
        expect(form.state.meta.valid, isFalse);
      });
    });
  });
}

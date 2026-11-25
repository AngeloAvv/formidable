import 'package:fake_async/fake_async.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/async_validation.dart';
import 'package:formidable_test_schemas/pending_status.dart';
import 'package:test/test.dart';

const _debounce = Duration(milliseconds: 300);

/// Runs [body] with a Form whose `owner.username` is the checked Field.
void _workspace(
  void Function(FakeAsync async, WorkspaceForm form, UsernameAvailable names)
  body,
) {
  fakeAsync((async) {
    final names = UsernameAvailable();
    final form = WorkspaceForm(
      owner: const Owner(username: 'seed'),
      usernameAvailable: names,
    );
    body(async, form, names);
  });
}

void main() {
  group('pending status on a Field', () {
    test('a running check is pending: not valid, not invalid, no message', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: names,
          emailAvailable: EmailAvailable(),
        );

        form.username.setValue('alice');
        form.username.touch();

        final state = form.username.state;
        expect(state.pending, isTrue);
        expect(state.status, FormidableStatus.pending);
        expect(state.valid, isFalse);
        expect(state.touched, isTrue);
        // `errorText` reads only `errors`, and a running check has none yet.
        expect(state.errors, isEmpty);

        async.elapse(_debounce);
        expect(form.username.state.status, FormidableStatus.pending);
        expect(form.username.state.errors, isEmpty);
      });
    });

    test('a failing check makes the Field invalid with its message', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: names,
          emailAvailable: EmailAvailable(),
        );
        form.username.setValue('alice');
        form.username.touch();
        async.elapse(_debounce);

        names.answer('alice', taken: true);
        async.flushMicrotasks();

        expect(form.username.state.status, FormidableStatus.invalid);
        expect(form.username.state.valid, isFalse);
        expect(form.username.state.errors, [const TakenError('alice')]);
      });
    });

    test('a passing check makes the Field valid', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: names,
          emailAvailable: EmailAvailable(),
        );
        form.username.setValue('alice');
        async.elapse(_debounce);

        names.answer('alice', taken: false);
        async.flushMicrotasks();

        expect(form.username.state.status, FormidableStatus.valid);
        expect(form.username.state.valid, isTrue);
      });
    });

    test('an error wins over a running check: the Field is invalid', () {
      fakeAsync((async) {
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: UsernameAvailable(),
          emailAvailable: EmailAvailable(),
        );
        // `MinLength(3)` fails synchronously, so the check does not even run.
        form.username.setValue('al');
        expect(form.username.state.status, FormidableStatus.invalid);
      });
    });
  });

  group('pending status on a Form', () {
    test('pending while a check runs, then invalid or valid', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: null,
          note: 'n',
          usernameAvailable: names,
          emailAvailable: EmailAvailable(),
        );
        form.email.setValue('a@b.c');
        form.username.setValue('alice');
        form.username.touch();

        expect(form.state.meta.status, FormidableStatus.pending);
        expect(form.state.meta.valid, isFalse);
        expect(form.state.meta.errors, isEmpty);
        expect(form.username.state.errors, isEmpty);

        async.elapse(_debounce);
        names.answer('alice', taken: true);
        async.flushMicrotasks();
        expect(form.state.meta.status, FormidableStatus.invalid);
      });
    });

    test('a Form with a failing Field is invalid even while another runs', () {
      fakeAsync((async) {
        final form = RegistrationForm(
          username: null,
          email: null,
          note: 'n',
          usernameAvailable: UsernameAvailable(),
          emailAvailable: EmailAvailable(),
        );
        form.email.setValue('a@b.c');
        form.username.setValue('al'); // fails MinLength now
        expect(form.state.meta.status, FormidableStatus.invalid);
      });
    });

    test('statusChanges reports pending', () {
      fakeAsync((async) {
        final emails = EmailAvailable();
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: names,
          emailAvailable: emails,
        );
        final seen = <FormidableStatus>[];
        form.statusChanges.listen(seen.add);

        form.username.setValue('alice');
        async.elapse(_debounce);
        names.answer('alice', taken: false);
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();

        expect(seen, [FormidableStatus.pending, FormidableStatus.valid]);
      });
    });

    test('the value exists only once the Form is valid', () {
      fakeAsync((async) {
        final emails = EmailAvailable();
        final names = UsernameAvailable();
        final form = RegistrationForm(
          username: null,
          email: 'a@b.c',
          note: 'n',
          usernameAvailable: names,
          emailAvailable: emails,
        );
        form.username.setValue('alice');
        expect(form.state.meta.valid, isFalse);
        expect(() => form.value, throwsStateError);
        expect(form.valueOrNull, isNull);
        async.elapse(_debounce);
        names.answer('alice', taken: false);
        emails.answer('a@b.c', taken: false);
        async.flushMicrotasks();
        expect(form.state.meta.valid, isTrue);
        expect(form.value.username, 'alice');
      });
    });
  });

  group('pending status through containers', () {
    test('a Nested Form is pending while its Field runs', () {
      _workspace((async, form, _) {
        form.owner.username.setValue('alice');

        expect(form.owner.username.state.status, FormidableStatus.pending);
        expect(form.owner.state.meta.status, FormidableStatus.pending);
        expect(form.owner.state.meta.valid, isFalse);
        expect(form.state.meta.status, FormidableStatus.pending);
        expect(form.state.meta.valid, isFalse);
        expect(form.state.meta.errors, isEmpty);
      });
    });

    test('a Field Array is pending while an item runs', () {
      _workspace((async, form, _) {
        form.others.add(const Owner(username: 'seed'));
        async.elapse(_debounce);
        final item = form.others.items.last.node;
        item.username.setValue('alice');

        expect(form.others.state.pending, isTrue);
        expect(form.others.state.status, FormidableStatus.pending);
        expect(form.others.state.valid, isFalse);
        expect(form.state.meta.status, FormidableStatus.pending);
      });
    });

    test('a Dynamic Form is pending while a registered Field runs', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = WorkspaceForm(
          owner: const Owner(username: 'seed'),
          usernameAvailable: names,
        );
        final field = form.extras.register<String>(
          'username',
          asyncValidators: [names],
        );
        field.setValue('alice');
        field.touch();

        expect(form.extras.state.pending, isTrue);
        expect(form.extras.state.status, FormidableStatus.pending);
        expect(form.extras.state.valid, isFalse);
        expect(field.state.errors, isEmpty);
        expect(form.state.meta.status, FormidableStatus.pending);

        async.elapse(_debounce);
        names.answer('alice', taken: true);
        async.flushMicrotasks();
        expect(form.extras.state.status, FormidableStatus.invalid);
        expect(form.state.meta.status, FormidableStatus.invalid);

        field.setValue('bob');
        async.elapse(_debounce);
        names.answer('bob', taken: false);
        async.flushMicrotasks();
        expect(form.extras.state.status, FormidableStatus.valid);
        expect(form.extras.state.valid, isTrue);
      });
    });

    test('an error elsewhere wins over a pending child', () {
      fakeAsync((async) {
        final names = UsernameAvailable();
        final form = WorkspaceForm(
          owner: const Owner(username: 'seed'),
          usernameAvailable: names,
        );
        final field = form.extras.register<String>(
          'username',
          asyncValidators: [names],
          validators: const [MinLength(3)],
        );
        field.setValue('alice');
        form.extras
            .register<String>('other', validators: const [MinLength(3)])
            .setValue('x');

        expect(form.extras.state.status, FormidableStatus.invalid);
        expect(form.state.meta.status, FormidableStatus.invalid);
      });
    });
  });
}

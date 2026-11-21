import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/submit_flow.dart';
import 'package:test/test.dart';

final class _Target implements FormidableFocusTarget {
  _Target(this.name, this.log);

  final String name;
  final List<String> log;

  @override
  void focus() => log.add('focus $name');

  @override
  void unfocus() => log.add('unfocus $name');
}

void main() {
  late List<String> log;

  setUp(() => log = []);

  group('submit', () {
    test('marks every Field and notifies the Form once', () async {
      final form = AccountForm(username: 'angelo');
      var changes = 0;
      form.addListener(() => changes++);

      await form.submit();

      expect(changes, 1);
      expect(form.username.state.submitted, isTrue);
      expect(form.password.state.submitted, isTrue);
      expect(form.code.state.submitted, isTrue);
    });

    test('marks every Field as touched, valid or not', () async {
      final form = AccountForm(username: 'angelo');

      await form.submit();

      expect(form.username.state.touched, isTrue);
      expect(form.password.state.touched, isTrue);
      expect(form.note.state.touched, isTrue);
      expect(form.code.state.touched, isTrue);
    });

    test('marks every Field as touched when the Form is valid', () async {
      final form = AccountForm(
        username: 'angelo',
        password: 'secret-123',
        code: 'x',
      );

      final result = await form.submit();

      expect(result, isA<FormidableSubmitValid<Account>>());
      expect(form.note.state.touched, isTrue);
    });

    test('marks every Field as submitted', () async {
      final form = AccountForm(username: 'angelo');
      expect(form.username.state.submitted, isFalse);

      await form.submit();

      expect(form.username.state.submitted, isTrue);
      expect(form.code.state.submitted, isTrue);
    });

    test('notifies each Field once and the Form once for the touch', () async {
      final form = AccountForm(
        username: 'angelo',
        password: 'secret-123',
        code: 'x',
      );
      var fieldCount = 0;
      form.username.addListener(() => fieldCount++);

      await form.submit();
      expect(fieldCount, 1);

      await form.submit();
      expect(fieldCount, 1);
    });

    test('lists the invalid Fields in declaration order', () async {
      final form = AccountForm(username: 'ab', password: 'short');

      final result = await form.submit() as FormidableSubmitInvalid<Account>;

      expect(result.errors.keys, [form.username, form.password, form.code]);
    });

    test('focuses the first invalid Field in declaration order', () async {
      final form = AccountForm(username: 'angelo', password: 'short');
      form.username.registerFocusTarget(_Target('username', log));
      form.password.registerFocusTarget(_Target('password', log));
      form.code.registerFocusTarget(_Target('code', log));

      await form.submit();

      expect(log, ['focus password']);
    });

    test('does not focus anything when the Form is valid', () async {
      final form = AccountForm(
        username: 'angelo',
        password: 'secret-123',
        code: 'x',
      );
      form.username.registerFocusTarget(_Target('username', log));

      await form.submit();

      expect(log, isEmpty);
    });

    test('skips invalid Fields that are not bound to a widget', () async {
      final form = AccountForm(username: 'ab', password: 'short');
      form.code.registerFocusTarget(_Target('code', log));

      await form.submit();

      expect(log, ['focus code']);
    });

    test('skips invalid Fields that are disabled', () async {
      final form = AccountForm(password: 'secret-123')..username.disable();
      form.username.registerFocusTarget(_Target('username', log));
      form.code.registerFocusTarget(_Target('code', log));

      final result = await form.submit();

      expect(result, isA<FormidableSubmitInvalid<Account>>());
      expect(log, ['focus code']);
    });

    test('focuses a Field with applied errors', () async {
      final form = AccountForm(
        username: 'angelo',
        password: 'secret-123',
        code: 'x',
      );
      form.password.registerFocusTarget(_Target('password', log));
      form.password.applyErrors([const FormidableRequiredError()]);

      await form.submit();

      expect(log, ['focus password']);
    });
  });

  group('Field focus', () {
    test('focus and unfocus reach the registered target', () {
      final field = FormidableField<String>();
      field.registerFocusTarget(_Target('a', log));

      field
        ..focus()
        ..unfocus();

      expect(log, ['focus a', 'unfocus a']);
    });

    test('are no-ops without a target', () {
      final field = FormidableField<String>();

      expect(field.focus, returnsNormally);
      expect(field.unfocus, returnsNormally);
    });

    test('focus goes to the last registered target', () {
      final field = FormidableField<String>();
      field
        ..registerFocusTarget(_Target('first', log))
        ..registerFocusTarget(_Target('last', log));

      field.focus();

      expect(log, ['focus last']);
    });

    test('focus goes back to the previous target when the last is removed', () {
      final field = FormidableField<String>();
      field.registerFocusTarget(_Target('first', log));
      final remove = field.registerFocusTarget(_Target('last', log));

      remove();
      field.focus();

      expect(log, ['focus first']);
    });

    test('a disabled Field cannot take focus', () {
      final field = FormidableField<String>()
        ..registerFocusTarget(_Target('a', log))
        ..disable();

      field.focus();

      expect(log, isEmpty);
    });
  });
}

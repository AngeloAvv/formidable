import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'support/sign_up.dart';
import 'support/sign_up.formidable_scope.dart';

/// Seam 2: builders, listeners and selectors over real generated Forms.
void main() {
  Widget app(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);

  group('Field Builder', () {
    testWidgets('has a synchronous initial value', (tester) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          FormidableFieldBuilder<String>(
            field: form.username,
            builder: (context, state) => Text('v:${state.value}'),
          ),
        ),
      );

      expect(find.text('v:angelo'), findsOneWidget);
    });

    testWidgets('rebuilds when the Field changes', (tester) async {
      final form = SignUpForm();
      await tester.pumpWidget(
        app(
          FormidableFieldBuilder<String>(
            field: form.username,
            builder: (context, state) => Text('v:${state.value}'),
          ),
        ),
      );

      form.username.setValue('abc');
      await tester.pump();

      expect(find.text('v:abc'), findsOneWidget);
    });

    testWidgets('buildWhen decides which changes rebuild', (tester) async {
      final form = SignUpForm();
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableFieldBuilder<String>(
            field: form.username,
            buildWhen: (previous, current) =>
                previous.touched != current.touched,
            builder: (context, state) {
              builds++;
              return Text('v:${state.value}');
            },
          ),
        ),
      );
      expect(builds, 1);

      form.username.setValue('abc');
      await tester.pump();
      expect(builds, 1);
      expect(find.text('v:null'), findsOneWidget);

      form.username.markAsTouched();
      await tester.pump();
      expect(builds, 2);
      expect(find.text('v:abc'), findsOneWidget);
    });

    testWidgets('follows a different Field when the widget is updated', (
      tester,
    ) async {
      final first = SignUpForm(username: 'first');
      final second = SignUpForm(username: 'second');
      Widget build(SignUpForm form) => app(
        FormidableFieldBuilder<String>(
          field: form.username,
          builder: (context, state) => Text('v:${state.value}'),
        ),
      );
      await tester.pumpWidget(build(first));

      await tester.pumpWidget(build(second));
      expect(find.text('v:second'), findsOneWidget);

      first.username.setValue('ignored');
      second.username.setValue('heard');
      await tester.pump();
      expect(find.text('v:heard'), findsOneWidget);
    });
  });

  group('Field Listener', () {
    testWidgets('is called with each new state and never on the first build', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      final seen = <String?>[];
      await tester.pumpWidget(
        app(
          FormidableFieldListener<String>(
            field: form.username,
            listener: (context, state) => seen.add(state.value),
            child: const SizedBox(),
          ),
        ),
      );
      expect(seen, isEmpty);

      form.username.setValue('a');
      form.username.setValue('b');

      expect(seen, ['a', 'b']);
    });

    testWidgets('listenWhen filters the calls', (tester) async {
      final form = SignUpForm();
      final seen = <bool>[];
      await tester.pumpWidget(
        app(
          FormidableFieldListener<String>(
            field: form.username,
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) =>
                seen.add(state.status == FormidableStatus.valid),
            child: const SizedBox(),
          ),
        ),
      );

      form.username.setValue('ab'); // invalid -> invalid
      form.username.setValue('abcd'); // invalid -> valid
      form.username.setValue('abcde'); // valid -> valid

      expect(seen, [true]);
    });

    testWidgets('stops listening when removed from the tree', (tester) async {
      final form = SignUpForm();
      var calls = 0;
      await tester.pumpWidget(
        app(
          FormidableFieldListener<String>(
            field: form.username,
            listener: (context, state) => calls++,
            child: const SizedBox(),
          ),
        ),
      );
      await tester.pumpWidget(app(const SizedBox()));

      form.username.setValue('abc');

      expect(calls, 0);
    });
  });

  group('Field Selector', () {
    testWidgets('rebuilds only when the selected value changes', (
      tester,
    ) async {
      final form = SignUpForm();
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableFieldSelector<String, bool>(
            field: form.username,
            selector: (state) => state.status == FormidableStatus.valid,
            builder: (context, valid) {
              builds++;
              return Text('valid:$valid');
            },
          ),
        ),
      );
      expect(find.text('valid:false'), findsOneWidget);
      expect(builds, 1);

      form.username.setValue('ab');
      await tester.pump();
      expect(builds, 1);

      form.username.setValue('abcd');
      await tester.pump();
      expect(builds, 2);
      expect(find.text('valid:true'), findsOneWidget);
    });

    testWidgets('buildWhen can veto a rebuild', (tester) async {
      final form = SignUpForm(username: 'abcd');
      await tester.pumpWidget(
        app(
          FormidableFieldSelector<String, String?>(
            field: form.username,
            selector: (state) => state.value,
            buildWhen: (previous, current) => (current ?? '').length > 5,
            builder: (context, value) => Text('v:$value'),
          ),
        ),
      );

      form.username.setValue('abc');
      await tester.pump();
      expect(find.text('v:abcd'), findsOneWidget);

      form.username.setValue('abcdefg');
      await tester.pump();
      expect(find.text('v:abcdefg'), findsOneWidget);
    });
  });

  group('Form Builder, Listener and Selector', () {
    testWidgets('take the Form from the tree when none is given', (
      tester,
    ) async {
      late SignUpForm form;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(),
            child: FormidableFormBuilder<SignUpForm>(
              builder: (context, state) => Text('s:${state.status.name}'),
            ),
          ),
        ),
      );
      expect(find.text('s:invalid'), findsOneWidget);

      form.username.setValue('angelo');
      await tester.pump();
      expect(find.text('s:valid'), findsOneWidget);

      form.username.setValue('x');
      await tester.pump();
      expect(find.text('s:invalid'), findsOneWidget);
    });

    testWidgets('use the Form they are given', (tester) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          FormidableFormBuilder<SignUpForm>(
            form: form,
            builder: (context, state) => Text('d:${state.dirty}'),
          ),
        ),
      );
      expect(find.text('d:false'), findsOneWidget);

      form.username.setValue('other');
      await tester.pump();

      expect(find.text('d:true'), findsOneWidget);
    });

    testWidgets('the builder honours buildWhen', (tester) async {
      final form = SignUpForm();
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableFormBuilder<SignUpForm>(
            form: form,
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              builds++;
              return const SizedBox();
            },
          ),
        ),
      );

      form.username.setValue('ab'); // dirty changes only
      await tester.pump();
      expect(builds, 1);

      form.username.setValue('abcd');
      await tester.pump();
      expect(builds, 2);
    });

    testWidgets('the listener honours listenWhen', (tester) async {
      final form = SignUpForm();
      final seen = <FormidableStatus>[];
      await tester.pumpWidget(
        app(
          FormidableFormListener<SignUpForm>(
            form: form,
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) => seen.add(state.status),
            child: const SizedBox(),
          ),
        ),
      );

      form.username.setValue('ab');
      form.username.setValue('abcd');
      form.username.clear();

      expect(seen, [FormidableStatus.valid, FormidableStatus.invalid]);
    });

    testWidgets('the listener finds the Form in the tree', (tester) async {
      late SignUpForm form;
      final seen = <FormidableStatus>[];
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(),
            child: FormidableFormListener<SignUpForm>(
              listener: (context, state) => seen.add(state.status),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      form.username.setValue('abcd');

      expect(seen, [FormidableStatus.valid]);
    });

    testWidgets('the selector follows form.value, not only the state', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableFormSelector<SignUpForm, String?>(
            form: form,
            selector: (form) => form.value?.username,
            builder: (context, username) {
              builds++;
              return Text('u:$username');
            },
          ),
        ),
      );
      expect(find.text('u:angelo'), findsOneWidget);

      // Valid -> valid: the Form state is equal, the value is not.
      form.username.setValue('angelo2');
      await tester.pump();
      expect(find.text('u:angelo2'), findsOneWidget);

      form.username.setValue('x');
      await tester.pump();
      expect(find.text('u:null'), findsOneWidget);
      expect(builds, 3);
    });

    testWidgets('a button selector rebuilds only when validity flips', (
      tester,
    ) async {
      final form = SignUpForm();
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableFormSelector<SignUpForm, bool>(
            form: form,
            selector: (form) => form.value != null,
            builder: (context, canSubmit) {
              builds++;
              return Text('can:$canSubmit');
            },
          ),
        ),
      );

      form.username.setValue('a');
      form.username.setValue('ab');
      await tester.pump();
      expect(builds, 1);

      form.username.setValue('abcd');
      await tester.pump();
      expect(find.text('can:true'), findsOneWidget);
      expect(builds, 2);
    });

    testWidgets('throw an error naming the missing scope', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableFormBuilder<SignUpForm>(
            builder: (context, state) => const SizedBox(),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(error.toString(), contains('FormidableScope<SignUpForm>'));
    });

    testWidgets('selector and listener throw the same error', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableFormSelector<SignUpForm, int>(
            selector: (form) => 0,
            builder: (context, _) => const SizedBox(),
          ),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('FormidableScope<SignUpForm>'),
      );

      await tester.pumpWidget(
        app(
          FormidableFormListener<SignUpForm>(
            listener: (context, state) {},
            child: const SizedBox(),
          ),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('FormidableScope<SignUpForm>'),
      );
    });
  });

  group('Form Scope .value', () {
    testWidgets('exposes a Form owned elsewhere without disposing it', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          SignUpFormScope.value(
            form: form,
            child: Builder(
              builder: (context) =>
                  Text('u:${context.signUpForm.username.value}'),
            ),
          ),
        ),
      );
      expect(find.text('u:angelo'), findsOneWidget);

      await tester.pumpWidget(app(const SizedBox()));

      expect(form.isDisposed, isFalse);
      form.username.setValue('still works');
      expect(form.username.value, 'still works');
    });

    testWidgets('the owning scope disposes its Form', (tester) async {
      late SignUpForm form;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(app(const SizedBox()));

      expect(form.isDisposed, isTrue);
    });

    testWidgets('builders follow the Form when the scope gets another one', (
      tester,
    ) async {
      final first = SignUpForm(username: 'first');
      final second = SignUpForm(username: 'second');
      Widget build(SignUpForm form) => app(
        SignUpFormScope.value(
          form: form,
          child: FormidableFormSelector<SignUpForm, String?>(
            selector: (form) => form.username.value,
            builder: (context, name) => Text('u:$name'),
          ),
        ),
      );
      await tester.pumpWidget(build(first));
      expect(find.text('u:first'), findsOneWidget);

      await tester.pumpWidget(build(second));
      expect(find.text('u:second'), findsOneWidget);

      second.username.setValue('changed');
      await tester.pump();
      expect(find.text('u:changed'), findsOneWidget);
    });

    testWidgets('the context extension throws when there is no scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(Builder(builder: (context) => Text('${context.signUpForm}'))),
      );

      expect(
        tester.takeException().toString(),
        contains('FormidableScope<SignUpForm>'),
      );
    });
  });

  group('ValueListenable compatibility', () {
    testWidgets('a Field can be listened to with a ValueListenableBuilder', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          ValueListenableBuilder<FormidableFieldState<String>>(
            valueListenable: form.username.asValueListenable(),
            builder: (context, state, _) => Text('v:${state.value}'),
          ),
        ),
      );
      expect(find.text('v:angelo'), findsOneWidget);

      form.username.setValue('abc');
      await tester.pump();

      expect(find.text('v:abc'), findsOneWidget);
    });

    testWidgets('a Form can too', (tester) async {
      final form = SignUpForm();
      await tester.pumpWidget(
        app(
          ValueListenableBuilder<FormidableFormState>(
            valueListenable: form.asValueListenable(),
            builder: (context, state, _) => Text('s:${state.status.name}'),
          ),
        ),
      );

      form.username.setValue('abcd');
      await tester.pump();

      expect(find.text('s:valid'), findsOneWidget);
    });
  });
}

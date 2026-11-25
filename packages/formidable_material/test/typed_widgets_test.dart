import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'support/sign_up.dart';
import 'support/sign_up.formidable_scope.dart';
import 'support/trip.dart';
import 'support/trip.formidable_scope.dart';

/// Seam 2: the widgets that follow the complete state of a Form, a Field or a
/// Field Array, the typed ones the generator writes included.
void main() {
  Widget app(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);

  group('the Form widgets follow every change, not only status and dirty', () {
    testWidgets('a Form Builder rebuilds when a value changes and the Form '
        'stays valid', (tester) async {
      final form = SignUpForm(username: 'angelo');
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableTypedFormBuilder<SignUpForm, SignUpFormState>(
            form: form,
            builder: (context, state) {
              builds++;
              return Text('u:${state.username.valueOrNull}');
            },
          ),
        ),
      );

      form.username.setValue('angelo2');
      await tester.pump();

      expect(find.text('u:angelo2'), findsOneWidget);
      expect(builds, 2);
    });

    testWidgets(
      'a Form Listener fires for a change that keeps the Form valid',
      (tester) async {
        final form = SignUpForm(username: 'angelo');
        final seen = <String?>[];
        await tester.pumpWidget(
          app(
            FormidableTypedFormListener<SignUpForm, SignUpFormState>(
              form: form,
              listener: (context, state) =>
                  seen.add(state.username.valueOrNull),
              child: const SizedBox(),
            ),
          ),
        );
        expect(seen, isEmpty);

        form.username.setValue('angelo2');
        form.username.setValue('angelo3');

        expect(seen, ['angelo2', 'angelo3']);
      },
    );

    testWidgets('a Form Selector selects from the state, Schema value '
        'included', (tester) async {
      final form = SignUpForm(username: 'angelo');
      var builds = 0;
      await tester.pumpWidget(
        app(
          FormidableTypedFormSelector<SignUpForm, SignUpFormState, String?>(
            form: form,
            selector: (state) => state.meta.valueOrNull?.username,
            builder: (context, username) {
              builds++;
              return Text('u:$username');
            },
          ),
        ),
      );

      form.username.setValue('angelo2');
      await tester.pump();
      expect(find.text('u:angelo2'), findsOneWidget);

      form.username.touch(); // the selected value is the same
      await tester.pump();
      expect(builds, 2);

      form.username.setValue('x');
      await tester.pump();
      expect(find.text('u:null'), findsOneWidget);
    });

    testWidgets('the generic widgets give a FormidableFormState without a '
        'state type', (tester) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          FormidableFormBuilder<SignUpForm>(
            form: form,
            builder: (context, state) => Text('d:${state.meta.dirty}'),
          ),
        ),
      );

      form.username.setValue('x');
      await tester.pump();

      expect(find.text('d:true'), findsOneWidget);
    });
  });

  group('the generated typed widgets', () {
    testWidgets('SignUpFormBuilder gives the typed state, from the scope', (
      tester,
    ) async {
      late SignUpForm form;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(username: 'angelo'),
            child: SignUpFormBuilder(
              builder: (context, SignUpFormState state) =>
                  Text('u:${state.username.valueOrNull}'),
            ),
          ),
        ),
      );
      expect(find.text('u:angelo'), findsOneWidget);

      form.username.setValue('angelo2');
      await tester.pump();

      expect(find.text('u:angelo2'), findsOneWidget);
    });

    testWidgets('SignUpFormBuilder takes an explicit form and a buildWhen', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      var builds = 0;
      await tester.pumpWidget(
        app(
          SignUpFormBuilder(
            form: form,
            buildWhen: (previous, next) =>
                previous.username.valueOrNull != next.username.valueOrNull,
            builder: (context, state) {
              builds++;
              return Text('u:${state.username.valueOrNull}');
            },
          ),
        ),
      );

      form.username.touch();
      await tester.pump();
      expect(builds, 1);

      form.username.setValue('other');
      await tester.pump();
      expect(builds, 2);
    });

    testWidgets('SignUpFormListener hears typed states, never the first', (
      tester,
    ) async {
      late SignUpForm form;
      final seen = <String?>[];
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(username: 'angelo'),
            child: SignUpFormListener(
              listenWhen: (previous, next) =>
                  previous.meta.dirty != next.meta.dirty,
              listener: (context, state) =>
                  seen.add(state.username.valueOrNull),
              child: const SizedBox(),
            ),
          ),
        ),
      );
      expect(seen, isEmpty);

      form.username.setValue('angelo2'); // clean -> dirty
      form.username.setValue('angelo3'); // dirty -> dirty
      form.username.setValue('angelo'); // dirty -> clean

      expect(seen, ['angelo2', 'angelo']);
    });

    testWidgets('SignUpFormSelector<R> rebuilds only when R changes', (
      tester,
    ) async {
      late SignUpForm form;
      var builds = 0;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(),
            child: SignUpFormSelector<bool>(
              selector: (state) => state.meta.valueOrNull != null,
              builder: (context, canSubmit) {
                builds++;
                return Text('can:$canSubmit');
              },
            ),
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

    testWidgets('they throw an error naming the missing scope', (tester) async {
      await tester.pumpWidget(
        app(SignUpFormBuilder(builder: (context, state) => const SizedBox())),
      );

      expect(
        tester.takeException().toString(),
        contains('FormidableScope<SignUpForm>'),
      );
    });

    testWidgets('the state of a Nested Form and of an array is typed', (
      tester,
    ) async {
      late TripForm form;
      await tester.pumpWidget(
        app(
          TripFormScope(
            create: () => form = TripForm(),
            child: TripFormBuilder(
              builder: (context, TripFormState state) => Text(
                'o:${state.origin.street.valueOrNull} s:${state.stops.length} '
                'n:${state.stops.items.map((s) => s.place.valueOrNull).join(',')}',
              ),
            ),
          ),
        ),
      );

      form.origin.street.setValue('Via Roma');
      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      expect(find.text('o:Via Roma s:1 n:Rome'), findsOneWidget);

      form.stops[0].node.place.setValue('Milan');
      await tester.pump();
      expect(find.text('o:Via Roma s:1 n:Milan'), findsOneWidget);
    });
  });

  group('the scope builder', () {
    testWidgets('gives the Form to a builder below the scope', (tester) async {
      late SignUpForm form;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(username: 'angelo'),
            builder: (context, form) => Column(
              children: [
                Text('u:${form.username.valueOrNull}'),
                FormidableFieldBuilder<String>(
                  field: form.username,
                  builder: (context, state) => Text('f:${state.valueOrNull}'),
                ),
                // The context is below the scope.
                Text('same:${identical(context.signUpForm, form)}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('u:angelo'), findsOneWidget);
      expect(find.text('same:true'), findsOneWidget);

      form.username.setValue('x');
      await tester.pump();
      expect(find.text('f:x'), findsOneWidget);
    });

    testWidgets('works on .value too, and never disposes the Form', (
      tester,
    ) async {
      final form = SignUpForm(username: 'angelo');
      await tester.pumpWidget(
        app(
          SignUpFormScope.value(
            form: form,
            builder: (context, form) => Text('u:${form.username.valueOrNull}'),
          ),
        ),
      );
      expect(find.text('u:angelo'), findsOneWidget);

      await tester.pumpWidget(app(const SizedBox()));

      expect(form.isDisposed, isFalse);
    });

    testWidgets('an owning scope with a builder disposes its Form', (
      tester,
    ) async {
      late SignUpForm form;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => form = SignUpForm(),
            builder: (context, form) => const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(app(const SizedBox()));

      expect(form.isDisposed, isTrue);
    });

    test('exactly one of child and builder is required', () {
      expect(() => SignUpFormScope(), throwsAssertionError);
      expect(
        () => SignUpFormScope(
          child: const SizedBox(),
          builder: (context, form) => const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => SignUpFormScope.value(form: SignUpForm()),
        throwsAssertionError,
      );
    });
  });

  group('the Field Array widgets', () {
    late TripForm form;

    Future<void> pump(WidgetTester tester, Widget Function(TripForm) build) =>
        tester.pumpWidget(
          app(
            TripFormScope(
              create: () => form = TripForm(),
              builder: (context, form) => build(form),
            ),
          ),
        );

    testWidgets('the Builder rebuilds when the value of an item changes', (
      tester,
    ) async {
      await pump(
        tester,
        (form) => FormidableFieldArrayBuilder(
          array: form.stops,
          itemBuilder: (context, index, item) => const SizedBox(),
          builder: (context, state, items) => Text(
            'p:${state.items.map((s) => s.place.valueOrNull).join(',')}',
          ),
        ),
      );
      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      expect(find.text('p:Rome'), findsOneWidget);

      form.stops[0].node.place.setValue('Milan');
      await tester.pump();

      expect(find.text('p:Milan'), findsOneWidget);
    });

    testWidgets('the Builder honours buildWhen on the states', (tester) async {
      var builds = 0;
      await pump(
        tester,
        (form) => FormidableFieldArrayBuilder(
          array: form.stops,
          buildWhen: (previous, next) => previous.length != next.length,
          itemBuilder: (context, index, item) => const SizedBox(),
          builder: (context, state, items) {
            builds++;
            return Text('n:${state.length}');
          },
        ),
      );
      expect(builds, 1);

      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      expect(builds, 2);

      form.stops[0].node.place.setValue('Milan');
      await tester.pump();
      expect(builds, 2);
    });

    testWidgets('the Listener hears every change of the array, not the first', (
      tester,
    ) async {
      final seen = <String>[];
      await pump(
        tester,
        (form) => FormidableFieldArrayListener(
          array: form.stops,
          listener: (context, state) => seen.add(
            state.items.map((s) => s.place.valueOrNull ?? '-').join(','),
          ),
          child: const SizedBox(),
        ),
      );
      expect(seen, isEmpty);

      form.stops.add(const Stop(place: 'Rome'));
      form.stops[0].node.place.setValue('Milan');
      form.stops.add();

      expect(seen, ['Rome', 'Milan', 'Milan,-']);
    });

    testWidgets('the Listener honours listenWhen', (tester) async {
      var calls = 0;
      await pump(
        tester,
        (form) => FormidableFieldArrayListener(
          array: form.stops,
          listenWhen: (previous, next) => previous.length != next.length,
          listener: (context, state) => calls++,
          child: const SizedBox(),
        ),
      );

      form.stops.add(const Stop(place: 'Rome'));
      form.stops[0].node.place.setValue('Milan');
      form.stops.add();

      expect(calls, 2);
    });

    testWidgets('the Selector rebuilds only when the selection changes', (
      tester,
    ) async {
      var builds = 0;
      await pump(
        tester,
        (form) => FormidableFieldArraySelector(
          array: form.stops,
          selector: (state) => state.length,
          builder: (context, length) {
            builds++;
            return Text('n:$length');
          },
        ),
      );
      expect(find.text('n:0'), findsOneWidget);

      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      expect(find.text('n:1'), findsOneWidget);

      form.stops[0].node.place.setValue('Milan');
      await tester.pump();
      expect(builds, 2);
    });

    testWidgets('the Selector can follow the value of one item', (
      tester,
    ) async {
      await pump(
        tester,
        (form) => FormidableFieldArraySelector(
          array: form.stops,
          selector: (state) => state.items
              .map((s) => s.place.valueOrNull)
              .whereType<String>()
              .length,
          buildWhen: (previous, next) => next > previous,
          builder: (context, filled) => Text('filled:$filled'),
        ),
      );
      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      expect(find.text('filled:1'), findsOneWidget);

      form.stops[0].node.place.clear();
      await tester.pump();
      // 1 -> 0 is vetoed by buildWhen.
      expect(find.text('filled:1'), findsOneWidget);
    });
  });
}

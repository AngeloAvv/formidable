import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: `FormidableFieldWidget` turns any widget into a Formidable widget.
/// These tests use a color picker and a rating, which have no text controller,
/// to prove that the base needs nothing from text.

const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);

/// A picker made of tappable swatches: the widget under test never sees a
/// Field, only what the control tells it.
class _Swatches extends StatelessWidget {
  const _Swatches({required this.control});

  final FormidableFieldWidgetState<Color?, Color?> control;
  static const colors = [_red, _blue];

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: control.focusNode,
    child: Column(
      children: [
        for (final color in colors)
          GestureDetector(
            key: ValueKey(color),
            onTap: () => control.didChange(color, touch: true),
            child: SizedBox(
              width: 20,
              height: 20,
              child: ColoredBox(color: color),
            ),
          ),
        Text(
          control.value == null ? 'none' : 'picked ${control.value}',
          key: const Key('summary'),
        ),
        if (control.errorText != null)
          Text(control.errorText!, key: const Key('error')),
      ],
    ),
  );
}

/// A subclass, the way an app or a package ships its own Formidable widget.
class _ColorPicker extends FormidableFieldWidget<Color?, Color?> {
  _ColorPicker({
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(builder: (context, control) => _Swatches(control: control));
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  late FormidableField<Color?> color;

  setUp(() {
    color = FormidableField<Color?>(required: true);
    addTearDown(color.dispose);
  });

  group('ad hoc, with the builder', () {
    testWidgets('shows the Field and writes what the user picks', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, control) => _Swatches(control: control),
          ),
        ),
      );
      expect(find.text('none'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey(_blue)));
      await tester.pump();

      expect(color.value, _blue);
      expect(color.isSet, isTrue);
      expect(find.text('picked ${_blue.toString()}'), findsOneWidget);
    });

    testWidgets('follows the Field when code changes it', (tester) async {
      await tester.pumpWidget(_app(_ColorPicker(field: color)));

      color.setValue(_red);
      await tester.pump();
      expect(find.text('picked ${_red.toString()}'), findsOneWidget);

      color.clear();
      await tester.pump();
      expect(find.text('none'), findsOneWidget);
    });

    testWidgets('the control exposes the snapshot of the Field', (
      tester,
    ) async {
      late FormidableFieldWidgetState<Color?, Color?> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, c) => Text('${(control = c).state.isSet}'),
          ),
        ),
      );
      expect(control.state, color.state);
      expect(control.field, same(color));

      color.setValue(_red);
      await tester.pump();

      expect(control.state.value, _red);
      expect(control.isSet, isTrue);
    });
  });

  group('writing', () {
    late FormidableFieldWidgetState<Color?, Color?> control;

    Future<void> mount(WidgetTester tester, FormidableField<Color?> field) =>
        tester.pumpWidget(
          _app(
            FormidableFieldWidget<Color?, Color?>(
              field: field,
              builder: (context, c) {
                control = c;
                return const SizedBox();
              },
            ),
          ),
        );

    testWidgets('didChange writes the Field but does not touch it', (
      tester,
    ) async {
      await mount(tester, color);

      control.didChange(_red);

      expect(color.value, _red);
      expect(color.state.touched, isFalse);
    });

    testWidgets('didChange can touch the Field in the same call', (
      tester,
    ) async {
      await mount(tester, color);

      control.didChange(_red, touch: true);

      expect(color.state.touched, isTrue);
    });

    testWidgets('markAsTouched touches the Field', (tester) async {
      await mount(tester, color);

      control.markAsTouched();

      expect(color.state.touched, isTrue);
    });

    testWidgets('clear puts the Field back to Unset', (tester) async {
      final field = FormidableField<Color?>(initial: (value: _red));
      addTearDown(field.dispose);
      await mount(tester, field);

      control.clear();

      expect(field.isSet, isFalse);
      expect(field.state.touched, isFalse);
    });

    testWidgets('clear can touch the Field in the same call', (tester) async {
      await mount(tester, color);

      control.clear(touch: true);

      expect(color.state.touched, isTrue);
    });

    testWidgets('null is a value when the type of the Field admits null', (
      tester,
    ) async {
      await mount(tester, color);

      control.didChange(null);

      expect(color.isSet, isTrue);
      expect(color.value, isNull);
    });

    testWidgets('null means no value when the type of the Field is not null', (
      tester,
    ) async {
      final field = FormidableField<Color>(initial: (value: _red));
      addTearDown(field.dispose);
      late FormidableFieldWidgetState<Color, Color> strict;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color, Color>(
            field: field,
            builder: (context, c) {
              strict = c;
              return const SizedBox();
            },
          ),
        ),
      );

      strict.didChange(null);

      expect(field.isSet, isFalse);
    });
  });

  group('Codec', () {
    // The Field holds a rating from 1 to 5, the widget shows a slider position.
    const codec = _RatingCodec();

    testWidgets('value is the Field seen through the Codec', (tester) async {
      final rating = FormidableField<int>(initial: (value: 4));
      addTearDown(rating.dispose);
      late FormidableFieldWidgetState<int, double> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<int, double>(
            field: rating,
            codec: codec,
            builder: (context, c) {
              control = c;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(control.value, 0.75);
      rating.clear();
      await tester.pump();
      expect(control.value, isNull);
    });

    testWidgets('didChange parses what the widget produced', (tester) async {
      final rating = FormidableField<int>();
      addTearDown(rating.dispose);
      late FormidableFieldWidgetState<int, double> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<int, double>(
            field: rating,
            codec: codec,
            builder: (context, c) {
              control = c;
              return const SizedBox();
            },
          ),
        ),
      );

      control.didChange(0.5);
      expect(rating.value, 3);

      control.didChange(null);
      expect(rating.isSet, isFalse);
    });

    testWidgets('a parse failure rejects the Field with the error', (
      tester,
    ) async {
      final rating = FormidableField<int>();
      addTearDown(rating.dispose);
      late FormidableFieldWidgetState<int, double> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<int, double>(
            field: rating,
            codec: codec,
            builder: (context, c) {
              control = c;
              return const SizedBox();
            },
          ),
        ),
      );

      control.didChange(2);

      expect(rating.inputError, isA<FormidableParseError>());
      expect(rating.isValid, isFalse);
    });
  });

  group('errors', () {
    testWidgets('are hidden until the Field is touched', (tester) async {
      await tester.pumpWidget(_app(_ColorPicker(field: color)));
      expect(find.byKey(const Key('error')), findsNothing);

      color.markAsTouched();
      await tester.pump();

      expect(find.byKey(const Key('error')), findsOneWidget);
    });

    testWidgets('picking a value hides the required error', (tester) async {
      await tester.pumpWidget(_app(_ColorPicker(field: color)));
      color.markAsTouched();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey(_red)));
      await tester.pump();

      expect(find.byKey(const Key('error')), findsNothing);
    });

    testWidgets('follow the error display policy of the widget', (
      tester,
    ) async {
      final filled = FormidableField<Color?>(
        required: true,
        initial: (value: _red),
      );
      addTearDown(filled.dispose);
      await tester.pumpWidget(
        _app(
          _ColorPicker(
            field: filled,
            errorDisplay: FormidableErrorDisplay.dirty,
          ),
        ),
      );

      filled.clear();
      await tester.pump();

      // Dirty is enough: the Field was never touched.
      expect(filled.state.touched, isFalse);
      expect(find.byKey(const Key('error')), findsOneWidget);
    });

    testWidgets('the Form Scope policy applies when the widget has none', (
      tester,
    ) async {
      await tester.pumpWidget(
        FormidableConfig(
          errorDisplay: FormidableErrorDisplay.submit,
          child: _app(_ColorPicker(field: color)),
        ),
      );
      color.markAsTouched();
      await tester.pump();
      expect(find.byKey(const Key('error')), findsNothing);

      color.markSubmitted();
      await tester.pump();
      expect(find.byKey(const Key('error')), findsOneWidget);
    });

    testWidgets('use the messages of the widget', (tester) async {
      color.markAsTouched();
      await tester.pumpWidget(
        _app(
          _ColorPicker(
            field: color,
            messages: const FormidableMessages().on<FormidableRequiredError>(
              (context, error) => 'Pick a color',
            ),
          ),
        ),
      );

      expect(find.text('Pick a color'), findsOneWidget);
    });

    testWidgets('follow the messages of the config', (tester) async {
      color.markAsTouched();
      await tester.pumpWidget(
        FormidableConfig(
          messages: const FormidableMessages().on<FormidableRequiredError>(
            (context, error) => 'From the config',
          ),
          child: _app(_ColorPicker(field: color)),
        ),
      );

      expect(find.text('From the config'), findsOneWidget);
    });
  });

  group('state of the Field', () {
    testWidgets('enabled follows the Field', (tester) async {
      late FormidableFieldWidgetState<Color?, Color?> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, c) {
              control = c;
              return Text('${c.enabled}');
            },
          ),
        ),
      );
      expect(control.enabled, isTrue);

      color.disable();
      await tester.pump();

      expect(control.enabled, isFalse);
      expect(find.text('false'), findsOneWidget);
    });

    testWidgets('pending says when an Async Validator is running', (
      tester,
    ) async {
      final answer = Completer<List<FormidableValidationError>>();
      final slow = FormidableField<Color?>(
        asyncValidators: [_Slow(answer)],
        initial: (value: _red),
      );
      addTearDown(slow.dispose);
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: slow,
            builder: (context, c) => Text(c.pending ? 'checking' : 'done'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('checking'), findsOneWidget);

      answer.complete(const []);
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.text('done'), findsOneWidget);
    });
  });

  group('focus', () {
    testWidgets('the control owns a focus node and disposes it', (
      tester,
    ) async {
      late FocusNode node;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, c) {
              node = c.focusNode;
              return Focus(focusNode: c.focusNode, child: const SizedBox());
            },
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox());

      expect(() => node.addListener(() {}), throwsFlutterError);
    });

    testWidgets('a focus node that is passed in is never disposed', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(_ColorPicker(field: color, focusNode: node)),
      );
      await tester.pumpWidget(const SizedBox());

      node.addListener(() {});
    });

    testWidgets('the Field is touched when its focus node loses focus', (
      tester,
    ) async {
      final node = FocusNode();
      final other = FocusNode();
      addTearDown(node.dispose);
      addTearDown(other.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _ColorPicker(field: color, focusNode: node),
              Focus(focusNode: other, child: const SizedBox()),
            ],
          ),
        ),
      );

      node.requestFocus();
      await tester.pump();
      expect(color.state.touched, isFalse);

      other.requestFocus();
      await tester.pump();
      expect(color.state.touched, isTrue);
    });

    testWidgets('Field.focus() reaches the focus node of the control', (
      tester,
    ) async {
      late FocusNode node;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, c) {
              node = c.focusNode;
              return Focus(focusNode: c.focusNode, child: const SizedBox());
            },
          ),
        ),
      );

      color.focus();
      await tester.pump();

      expect(node.hasFocus, isTrue);
    });
  });

  group('the widget changes', () {
    testWidgets('another Field replaces the first one', (tester) async {
      final other = FormidableField<Color?>(initial: (value: _blue));
      addTearDown(other.dispose);
      await tester.pumpWidget(_app(_ColorPicker(field: color)));
      expect(find.text('none'), findsOneWidget);

      await tester.pumpWidget(_app(_ColorPicker(field: other)));
      expect(find.text('picked ${_blue.toString()}'), findsOneWidget);

      // The first Field is not listened to any more, and no widget of it
      // remains registered for focus.
      expect(color.canFocus, isFalse);
      color.setValue(_red);
      await tester.pump();
      expect(find.text('picked ${_blue.toString()}'), findsOneWidget);
    });
  });

  _textTests();

  group('a custom state', () {
    testWidgets('a subclass can override createState', (tester) async {
      await tester.pumpWidget(_app(_CountingPicker(field: color)));
      expect(find.text('writes 0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey(_red)));
      await tester.pump();

      expect(find.text('writes 1'), findsOneWidget);
      expect(color.value, _red);
    });
  });

  group('keyboard focus helpers', () {
    testWidgets('on the last Field the action is done, and it unfocuses', (
      tester,
    ) async {
      late FormidableFieldWidgetState<Color?, Color?> control;
      await tester.pumpWidget(
        _app(
          FormidableFieldWidget<Color?, Color?>(
            field: color,
            builder: (context, c) {
              control = c;
              return Focus(focusNode: c.focusNode, child: const SizedBox());
            },
          ),
        ),
      );
      control.focusNode.requestFocus();
      await tester.pump();

      expect(control.textInputAction, TextInputAction.done);
      control.onEditingComplete();
      await tester.pump();

      expect(control.focusNode.hasFocus, isFalse);
    });
  });
}

void _textTests() {
  group('text specialization', () {
    late FormidableTextFieldWidgetState<int> control;

    Future<void> mount(WidgetTester tester, FormidableField<int> field) =>
        tester.pumpWidget(
          _app(
            FormidableTextFieldWidget<int>(
              field: field,
              builder: (context, c) {
                control = c;
                return TextField(controller: c.textController);
              },
            ),
          ),
        );

    testWidgets('the controller shows the Field through the built-in Codec', (
      tester,
    ) async {
      final age = FormidableField<int>(initial: (value: 42));
      addTearDown(age.dispose);
      await mount(tester, age);
      expect(control.textController.text, '42');

      age.setValue(7);
      await tester.pump();

      expect(control.textController.text, '7');
    });

    testWidgets('didChange parses text, and shows it when code calls it', (
      tester,
    ) async {
      final age = FormidableField<int>();
      addTearDown(age.dispose);
      await mount(tester, age);

      control.didChange('12');

      expect(age.value, 12);
      expect(control.textController.text, '12');

      control.didChange('');
      expect(age.isSet, isFalse);
      expect(control.textController.text, isEmpty);
    });

    testWidgets('text that is not a number stays and rejects the Field', (
      tester,
    ) async {
      final age = FormidableField<int>(initial: (value: 3));
      addTearDown(age.dispose);
      await mount(tester, age);

      control.didChange('3x');
      await tester.pump();

      expect(age.inputError, isA<FormidableNumberParseError>());
      expect(control.textController.text, '3x');
    });

    testWidgets('another Field replaces the text', (tester) async {
      final first = FormidableField<int>(initial: (value: 1));
      final second = FormidableField<int>(initial: (value: 2));
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await mount(tester, first);
      expect(control.textController.text, '1');

      await mount(tester, second);

      expect(control.textController.text, '2');
    });

    testWidgets('without a Codec for the type, the controller asserts', (
      tester,
    ) async {
      final color = FormidableField<Color>();
      addTearDown(color.dispose);
      await tester.pumpWidget(
        _app(
          FormidableTextFieldWidget<Color>(
            field: color,
            builder: (context, c) => TextField(controller: c.textController),
          ),
        ),
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}

/// Maps a rating from 1 to 5 to a position from 0 to 1 and back.
class _RatingCodec extends FormidableCodec<int, double> {
  const _RatingCodec();

  @override
  double format(int value) => (value - 1) / 4;

  @override
  FormidableParseResult<int> parse(double input) {
    if (input < 0 || input > 1) {
      return const FormidableParseFailure(_OutOfRange());
    }
    return FormidableParsedValue((input * 4).round() + 1);
  }
}

class _OutOfRange extends FormidableParseError {
  const _OutOfRange() : super(input: '');
}

class _Slow extends FormidableAsyncValidator<Color?> {
  _Slow(this.answer);

  final Completer<List<FormidableValidationError>> answer;

  @override
  Duration get debounce => const Duration(milliseconds: 10);

  @override
  Future<List<FormidableValidationError>> validate(Color? value) =>
      answer.future;
}

class _CountingPicker extends FormidableFieldWidget<Color?, Color?> {
  _CountingPicker({required super.field})
    : super(
        builder: (context, control) => Column(
          children: [
            _Swatches(control: control),
            Text('writes ${(control as _CountingState).writes}'),
          ],
        ),
      );

  @override
  FormidableFieldWidgetState<Color?, Color?> createState() => _CountingState();
}

class _CountingState extends FormidableFieldWidgetState<Color?, Color?> {
  int writes = 0;

  @override
  void didChange(Color? value, {bool touch = false}) {
    writes++;
    super.didChange(value, touch: touch);
  }
}

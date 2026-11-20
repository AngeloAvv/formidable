import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

class _Slow extends FormidableAsyncValidator<String> {
  _Slow(this.answer);

  final Completer<List<FormidableValidationError>> answer;

  @override
  Duration get debounce => const Duration(milliseconds: 10);

  @override
  Future<List<FormidableValidationError>> validate(String value) =>
      answer.future;
}

/// Seam 2: a widget can show progress from the Binding alone.
void main() {
  testWidgets('the Binding says when an Async Validator is running', (
    tester,
  ) async {
    final answer = Completer<List<FormidableValidationError>>();
    final field = FormidableField<String>(
      asyncValidators: [_Slow(answer)],
      initial: (value: 'alice'),
    );
    addTearDown(field.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FormidableBindingBuilder<String>(
          field: field,
          builder: (context, binding) =>
              Text(binding.isPending ? 'checking' : 'done'),
        ),
      ),
    );
    expect(find.text('checking'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    answer.complete(const []);
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('done'), findsOneWidget);
  });
}

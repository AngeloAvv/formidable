import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

final class _Taken extends FormidableValidationError {
  const _Taken();

  @override
  List<Object?> get props => const [];
}

final class _Slow extends FormidableAsyncValidator<String> {
  _Slow(this.completer);

  final Completer<List<FormidableValidationError>> completer;

  @override
  Duration get debounce => Duration.zero;

  @override
  Future<List<FormidableValidationError>> validate(String value) =>
      completer.future;
}

/// Seam 2: a running check is pending, never invalid, so a touched Field shows
/// no Validation Message until the check fails.
void main() {
  testWidgets('a touched Field shows no message while its check runs', (
    tester,
  ) async {
    final completer = Completer<List<FormidableValidationError>>();
    final field = FormidableField<String>(asyncValidators: [_Slow(completer)]);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          FormidableLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Scaffold(body: FormidableMaterialTextField<String>(field: field)),
      ),
    );

    String? shown() =>
        tester.widget<TextField>(find.byType(TextField)).decoration?.errorText;

    field
      ..setValue('alice')
      ..touch();
    await tester.pump(const Duration(milliseconds: 10));

    expect(field.state.status, FormidableStatus.pending);
    expect(field.state.valid, isFalse);
    expect(field.state.errors, isEmpty);
    expect(shown(), isNull);

    completer.complete(const [_Taken()]);
    await tester.pump();
    await tester.pump();

    expect(field.state.status, FormidableStatus.invalid);
    expect(shown(), isNotNull);
  });
}

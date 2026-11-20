import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/passthrough.dart';
import 'package:test/test.dart';

void main() {
  group('Passthrough Fields', () {
    test(
      'are supplied when the Form is created and reach the output',
      () async {
        final form = EditUserForm(id: 7, name: 'Angelo');

        final valid = await form.submit() as FormidableSubmitValid<EditUser>;

        expect(valid.value.id, 7);
        expect(valid.value.revision, 1);
        expect(valid.value.parentId, isNull);
      },
    );

    test('are set from the Schema instance by the from constructor', () {
      final form = EditUserForm.from(
        const EditUser(id: 3, name: 'A', revision: 4, parentId: 2),
      );

      expect(form.id.value, 3);
      expect(form.revision.value, 4);
      expect(form.parentId.value, 2);
    });

    test('can be written and observed, and are never Unset', () async {
      final form = EditUserForm(id: 7, name: 'Angelo');
      final seen = <int>[];
      form.id.addListener(() => seen.add(form.id.value));

      form.id.setValue(8);
      form.id.setValue(8);

      expect(seen, [8]);
      final valid = await form.submit() as FormidableSubmitValid<EditUser>;
      expect(valid.value.id, 8);
    });

    test('are never invalid and never decide the Form status', () {
      final form = EditUserForm(id: 7);

      expect(form.id.isValid, isTrue);
      expect(form.state.status, FormidableStatus.invalid); // name is Unset
      form.name.setValue('x');
      expect(form.state.status, FormidableStatus.valid);
    });

    test('a nullable Passthrough can be set to null', () async {
      final form = EditUserForm(id: 1, name: 'A', parentId: 5)
        ..parentId.setValue(null);

      final valid = await form.submit() as FormidableSubmitValid<EditUser>;

      expect(valid.value.parentId, isNull);
    });

    test('their handle has no clear()', () {
      final form = EditUserForm(id: 1, name: 'A');

      expect(form.id, isA<FormidablePassthrough<int>>());
      expect(form.id, isNot(isA<FormidableField<int>>()));
    });
  });
}

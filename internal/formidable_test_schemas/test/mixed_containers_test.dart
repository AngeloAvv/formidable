import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:test/test.dart';

void main() {
  late ItineraryForm form;
  late FormidableField<String> note;
  late FormidableField<String> secondNote;

  setUp(() {
    form = ItineraryForm();
    form.phones
      ..add()
      ..add();
    note = form.extras.register<String>('note');
    secondNote = form.extras.register<String>('secondNote');
  });

  tearDown(() => form.dispose());

  test('focus order walks every container in tree order', () {
    final first = form.phones.items[0].node;
    final second = form.phones.items[1].node;

    expect(form.focusOrder, [
      form.title,
      form.contact.street,
      form.contact.zip,
      first.number,
      first.label,
      second.number,
      second.label,
      note,
      secondNote,
      form.footer,
    ]);
  });

  test('a Nested Form hands out the order of the root', () {
    expect(form.contact.focusOrder, form.focusOrder);
  });

  test('every node kind counts for errors, dirty and reset', () async {
    form.title.setValue('Trip');
    form.contact.street.setValue('Main street');
    form.phones.items[1].node.number.setValue('12');
    note.setValue('hello');
    expect(form.isDirty, isTrue);

    final result = await form.submit();

    final invalid = result as FormidableSubmitInvalid<Itinerary>;
    expect(invalid.fieldErrors.keys, [
      form.phones.items[0].node.number,
      form.phones.items[1].node.number,
      secondNote,
    ]);

    form.reset();
    expect(form.isDirty, isFalse);
    expect(note.isSet, isFalse);
  });
}

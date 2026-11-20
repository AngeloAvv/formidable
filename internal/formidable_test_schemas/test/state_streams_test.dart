import 'dart:async';

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/mixed_containers.dart';
import 'package:formidable_test_schemas/nested.dart';
import 'package:formidable_test_schemas/passthrough.dart';
import 'package:formidable_test_schemas/field_arrays.dart';
import 'package:formidable_test_schemas/sign_up.dart';
import 'package:test/test.dart';

/// Collects what [stream] emits, and cancels when the test is over.
List<T> collect<T>(Stream<T> stream) {
  final events = <T>[];
  final subscription = stream.listen(events.add);
  addTearDown(subscription.cancel);
  return events;
}

ItineraryForm itinerary() {
  final form = ItineraryForm(
    title: 'Rome',
    contact: const Address(street: 'Via Roma'),
    phones: const [
      Telephone(number: '111'),
      Telephone(number: '222'),
    ],
  );
  addTearDown(form.dispose);
  return form;
}

void main() {
  group('Field streams', () {
    test('never emit the current state and arrive synchronously', () {
      final form = itinerary();
      final changes = collect(form.title.changes);
      final values = collect(form.title.valueChanges);
      final statuses = collect(form.title.statusChanges);

      expect(changes, isEmpty);
      expect(values, isEmpty);
      expect(statuses, isEmpty);

      form.title.setValue('Paris');

      // No await: the event is there when the write returns.
      expect(values, ['Paris']);
      expect(changes.map((s) => s.value), ['Paris']);
    });

    test('changes emits every state change, touched included', () {
      final form = itinerary();
      final changes = collect(form.title.changes);

      form.title.markAsTouched();

      expect(changes, hasLength(1));
      expect(changes.single.touched, isTrue);
    });

    test('valueChanges ignores touched and submitted', () {
      final form = itinerary();
      final values = collect(form.title.valueChanges);

      form.title.markAsTouched();
      form.markSubmitted();

      expect(values, isEmpty);
    });

    test('valueChanges emits a write, and not the same value again', () {
      final form = itinerary();
      final values = collect(form.title.valueChanges);

      form.title.setValue('Rome');
      form.title.setValue('Oslo');
      form.title.setValue('Oslo');

      expect(values, ['Oslo']);
    });

    test('valueChanges emits null for Unset and for a chosen null', () {
      final form = itinerary();
      final values = collect(form.footer.valueChanges);
      expect(form.footer.isSet, isFalse);

      form.footer.setValue(null); // Unset -> null chosen: presence changes
      expect(form.footer.isSet, isTrue);
      form.footer.setValue('bye');
      form.footer.clear(); // back to Unset

      expect(values, [null, 'bye', null]);
    });

    test('valueChanges emits null when the Field is cleared', () {
      final form = itinerary();
      final values = collect(form.title.valueChanges);

      form.title.clear();

      expect(values, [null]);
      expect(form.title.isSet, isFalse);
    });

    test('statusChanges emits only when the status changes', () {
      final form = itinerary();
      final statuses = collect(form.title.statusChanges);

      form.title.setValue('x'); // MinLength(2): invalid
      form.title.setValue('xy'); // valid
      form.title.setValue('xz'); // still valid
      form.title.markAsTouched();

      expect(statuses, [FormidableStatus.invalid, FormidableStatus.valid]);
    });

    test('select emits the selection only when it changes', () {
      final form = itinerary();
      final lengths = collect(form.title.select((s) => s.value?.length));

      form.title.setValue('Oslo'); // length 4, like Rome
      form.title.markAsTouched();
      form.title.setValue('Paris');
      form.title.setValue('Milan'); // length 5 again

      expect(lengths, [5]);
    });

    test('select computes the first selection when it is subscribed', () {
      final form = itinerary();
      form.title.setValue('Paris');

      final lengths = collect(form.title.select((s) => s.value?.length));
      form.title.setValue('Milan'); // same length as at subscribe time
      form.title.setValue('Oslo');

      expect(lengths, [4]);
    });

    test('select compares with ==, so a record selection works', () {
      final form = itinerary();
      final pairs = collect(form.title.select((s) => (s.isSet, s.touched)));

      form.title.setValue('Oslo');
      form.title.markAsTouched();

      expect(pairs, [(true, true)]);
    });

    test('are broadcast: several listeners, each one cancels on its own', () {
      final form = itinerary();
      final first = <String?>[];
      final second = <String?>[];
      final one = form.title.valueChanges.listen(first.add);
      addTearDown(one.cancel);
      collect(form.title.valueChanges).forEach(second.add);
      final other = form.title.valueChanges.listen(second.add);
      addTearDown(other.cancel);

      form.title.setValue('Oslo');
      one.cancel();
      form.title.setValue('Bern');

      expect(first, ['Oslo']);
      expect(second, ['Oslo', 'Bern']);
    });

    test('a listener added from inside an event only sees the next ones', () {
      final form = itinerary();
      final heard = <String?>[];
      var added = false;
      form.title.valueChanges.listen((_) {
        if (added) return;
        added = true;
        form.title.valueChanges.listen(heard.add);
      });

      form.title.setValue('Oslo');
      form.title.setValue('Bern');

      expect(heard, ['Bern']);
    });

    test('stop listening to the Field when nobody listens to them', () {
      final field = FormidableField<String>();
      addTearDown(field.dispose);
      expect(field.hasListeners, isFalse);

      final subscription = field.valueChanges.listen((_) {});
      expect(field.hasListeners, isTrue);
      subscription.cancel();
      expect(field.hasListeners, isFalse);

      final selected = field.select((s) => s.value).listen((_) {});
      expect(field.hasListeners, isTrue);
      selected.cancel();
      expect(field.hasListeners, isFalse);

      // A stream nobody listens to costs nothing either.
      field.changes;
      field.statusChanges;
      field.select((s) => s.value);
      expect(field.hasListeners, isFalse);
    });

    test('close when the Field is disposed', () async {
      final field = FormidableField<String>();
      final done = <String>[];
      field.changes.listen((_) {}, onDone: () => done.add('changes'));
      field.valueChanges.listen((_) {}, onDone: () => done.add('value'));
      field.statusChanges.listen((_) {}, onDone: () => done.add('status'));
      field
          .select((s) => s.isSet)
          .listen((_) {}, onDone: () => done.add('select'));

      field.dispose();
      await pumpEventQueue();

      expect(done, unorderedEquals(['changes', 'value', 'status', 'select']));
    });

    test('are closed when the Field is already disposed', () async {
      final field = FormidableField<String>()..dispose();
      final unsubscribed = field.select((s) => s.isSet);

      expect(await field.changes.isEmpty, isTrue);
      expect(await field.valueChanges.isEmpty, isTrue);
      expect(await field.statusChanges.isEmpty, isTrue);
      expect(await unsubscribed.isEmpty, isTrue);
    });

    test('a stream created before the dispose is closed when subscribed', () {
      final field = FormidableField<String>();
      final stream = field.select((s) => s.isSet);

      field.dispose();

      expect(stream.isEmpty, completion(isTrue));
    });

    test('a standalone Field has them too', () {
      final field = FormidableField<int>();
      addTearDown(field.dispose);
      final values = collect(field.valueChanges);

      field.setValue(3);

      expect(values, [3]);
    });

    test('a Passthrough Field has them too', () {
      final form = EditUserForm(id: 7, name: 'Ada');
      addTearDown(form.dispose);
      final values = collect(form.revision.valueChanges);
      final changes = collect(form.revision.changes);
      final selected = collect(form.revision.select((value) => value.isEven));

      form.revision.setValue(2);
      form.revision.setValue(2);
      form.revision.setValue(4);

      expect(values, [2, 4]);
      expect(changes, [2, 4]);
      expect(selected, [true]);
    });
  });

  group('Form streams', () {
    test('have the typed state of the generated Form', () {
      final form = itinerary();
      final Stream<ItineraryFormState> changes = form.changes;
      final Stream<ItineraryFormState> values = form.valueChanges;
      final Stream<FormidableStatus> statuses = form.statusChanges;
      final Stream<String?> titles = form.select((s) => s.title.value);
      final heard = [
        collect(changes),
        collect(values),
        collect(statuses),
        collect(titles),
      ];

      form.title.setValue('Paris');

      expect(heard[0].single, isA<ItineraryFormState>());
      expect((heard[1].single as ItineraryFormState).title.value, 'Paris');
      expect(heard[2], isEmpty);
      expect(heard[3], ['Paris']);
    });

    test('are on the plain Form type too', () {
      final FormidableForm<SignUp> form = SignUpForm(username: 'angelo');
      addTearDown(form.dispose);
      final events = collect(form.valueChanges);

      (form as SignUpForm).username.setValue('angelo2');

      expect(events.single, isA<SignUpFormState>());
      expect(events.single.form.value, isA<SignUp>());
    });

    test('changes emits on any state change', () {
      final form = itinerary();
      final changes = collect(form.changes);

      form.title.markAsTouched();
      form.markSubmitted();
      form.title.setValue('Oslo');

      expect(changes, hasLength(3));
    });

    test('valueChanges ignores touched, submitted and focus', () {
      final form = itinerary();
      final values = collect(form.valueChanges);

      form.title.markAsTouched();
      form.footer.markAsTouched();
      form.markSubmitted();

      expect(values, isEmpty);
    });

    test('valueChanges emits when a Field of the Form changes', () {
      final form = itinerary();
      final values = collect(form.valueChanges);

      form.title.setValue('Oslo');
      form.footer.setValue('bye');
      form.footer.setValue('bye');

      expect(values.map((s) => (s.title.value, s.footer.value)), [
        ('Oslo', null),
        ('Oslo', 'bye'),
      ]);
    });

    test('valueChanges bubbles up from a Nested Form', () {
      final form = itinerary();
      final values = collect(form.valueChanges);

      form.contact.street.markAsTouched();
      form.contact.street.setValue('Via Appia');

      expect(values, hasLength(1));
      expect(values.single.contact.street.value, 'Via Appia');
    });

    test('valueChanges bubbles up from a Field Array', () {
      final form = itinerary();
      final values = collect(form.valueChanges);

      form.phones.add(const Telephone(number: '333')); // added
      form.phones.move(0, 2); // moved
      form.phones[0].node.number.setValue('999'); // edited
      form.phones[0].node.number.markAsTouched(); // not a value change
      form.phones.removeAt(1); // removed

      expect(values, hasLength(4));
      expect(values.last.phones.length, 2);
    });

    test('valueChanges bubbles up from a Dynamic Form', () {
      final form = itinerary();
      final values = collect(form.valueChanges);

      final note = form.extras.register<String>('note'); // registered
      note.setValue('hi'); // written
      note.markAsTouched();
      form.extras.remove('note'); // removed

      expect(values, hasLength(3));
    });

    test('valueChanges bubbles up from a Field of a Dynamic Form item', () {
      final form = itinerary();
      final note = form.extras.register<String>('note');
      final values = collect(form.valueChanges);

      note.setValue('hi');
      note.setValue('hi');

      expect(values, hasLength(1));
    });

    test('valueChanges follows the presence of an optional Nested Form', () {
      final form = ContactForm(
        name: 'Ada',
        home: const Address(street: 'Via Roma'),
        billing: const Address(street: 'Via Po'),
      );
      addTearDown(form.dispose);
      final values = collect(form.valueChanges);
      expect(form.work.isSet, isFalse);

      form.work.street.setValue('Via Appia'); // work becomes set
      form.work.street.clear(); // work is Unset again

      expect(values, hasLength(2));
      expect(form.work.isSet, isFalse);
    });

    test('valueChanges is not the Form becoming valid', () {
      final form = itinerary();
      final values = collect(form.valueChanges);
      final statuses = collect(form.statusChanges);

      form.applyErrors(formErrors: const [FormidableRequiredError()]);

      expect(statuses, [FormidableStatus.invalid]);
      expect(values, isEmpty);
    });

    test('valueChanges emits when the Form becomes valid by a write', () {
      final form = SignUpForm(username: 'ab');
      addTearDown(form.dispose);
      final values = collect(form.valueChanges);
      expect(form.value, isNull);

      form.username.setValue('angelo');

      expect(values, hasLength(1));
      expect(values.single.form.value?.username, 'angelo');
    });

    test('valueChanges emits once for a batch', () {
      final form = itinerary();
      final values = collect(form.valueChanges);
      final changes = collect(form.changes);
      final titles = collect(form.select((s) => s.title.value));

      form.patch(title: 'Oslo', footer: 'bye');

      expect(values, hasLength(1));
      expect(changes, hasLength(1));
      expect(titles, ['Oslo']);
    });

    test('valueChanges follows reset, not commit', () {
      final form = itinerary();
      form.title.setValue('Oslo');
      final values = collect(form.valueChanges);
      final changes = collect(form.changes);

      form.commit();
      expect(values, isEmpty);
      expect(changes, hasLength(1)); // dirty flag

      form.title.setValue('Bern');
      form.reset();

      expect(values, hasLength(2));
      expect(values.last.title.value, 'Oslo');
    });

    test('statusChanges emits only when the status changes', () {
      final form = SignUpForm(username: 'angelo');
      addTearDown(form.dispose);
      final statuses = collect(form.statusChanges);

      form.username.setValue('ab');
      form.username.setValue('abc'); // still invalid
      form.username.markAsTouched();
      form.username.setValue('abcdef');

      expect(statuses, [FormidableStatus.invalid, FormidableStatus.valid]);
    });

    test('select emits only when the selection changes', () {
      final form = itinerary();
      form.footer.setValue('bye');
      final pairs = collect(
        form.select((s) => (s.title.value, s.footer.value)),
      );

      form.title.markAsTouched();
      form.contact.street.setValue('Via Appia'); // not selected
      form.title.setValue('Oslo');
      form.footer.setValue('bye');
      form.footer.setValue('ciao');

      expect(pairs, [('Oslo', 'bye'), ('Oslo', 'ciao')]);
    });

    test('select can read the metadata of the Form', () {
      final form = SignUpForm(username: 'angelo');
      addTearDown(form.dispose);
      final dirty = collect(form.select((s) => s.form.dirty));

      form.username.setValue('angelo2');
      form.username.setValue('angelo3');
      form.username.setValue('angelo');

      expect(dirty, [true, false]);
    });

    test('stop listening to the Form when nobody listens to them', () {
      final form = SignUpForm(username: 'angelo');
      addTearDown(form.dispose);
      expect(form.hasListeners, isFalse);

      final subscription = form.valueChanges.listen((_) {});
      expect(form.hasListeners, isTrue);
      subscription.cancel();
      expect(form.hasListeners, isFalse);

      final selection = form.select((s) => s.username.value).listen((_) {});
      final status = form.statusChanges.listen((_) {});
      final changes = form.changes.listen((_) {});
      expect(form.hasListeners, isTrue);
      selection.cancel();
      status.cancel();
      expect(form.hasListeners, isTrue);
      changes.cancel();
      expect(form.hasListeners, isFalse);
    });

    test('close when the Form is disposed', () async {
      final form = itinerary();
      final done = <String>[];
      form.changes.listen((_) {}, onDone: () => done.add('changes'));
      form.valueChanges.listen((_) {}, onDone: () => done.add('value'));
      form.statusChanges.listen((_) {}, onDone: () => done.add('status'));
      form
          .select((s) => s.title.value)
          .listen((_) {}, onDone: () => done.add('select'));
      form.contact.valueChanges.listen(
        (_) {},
        onDone: () => done.add('nested'),
      );
      form.phones.valueChanges.listen((_) {}, onDone: () => done.add('array'));
      form.extras.valueChanges.listen(
        (_) {},
        onDone: () => done.add('dynamic'),
      );

      form.dispose();
      await pumpEventQueue();

      expect(
        done,
        unorderedEquals([
          'changes',
          'value',
          'status',
          'select',
          'nested',
          'array',
          'dynamic',
        ]),
      );
    });

    test('a listener may write to the Form: its events are queued', () {
      final form = itinerary();
      final titles = <String?>[];
      final footers = <String?>[];
      form.valueChanges.listen((state) {
        titles.add(state.title.value);
        footers.add(state.footer.value);
        if (state.title.value == 'Oslo') form.footer.setValue('bye');
      });

      form.title.setValue('Oslo');

      expect(titles, ['Oslo', 'Oslo']);
      expect(footers, [null, 'bye']);
    });

    test('a listener may cancel itself from inside an event', () {
      final form = itinerary();
      final events = <String?>[];
      late StreamSubscription<ItineraryFormState> subscription;
      subscription = form.valueChanges.listen((state) {
        events.add(state.title.value);
        subscription.cancel();
      });

      form.title.setValue('Oslo');
      form.title.setValue('Bern');

      expect(events, ['Oslo']);
      expect(form.hasListeners, isFalse);
    });
  });

  group('Nested Form streams', () {
    test('are typed after the Nested Form and follow only its Fields', () {
      final form = itinerary();
      final Stream<AddressFormState> stream = form.contact.valueChanges;
      final values = collect(stream);
      final selection = collect(form.contact.select((s) => s.zip.value));

      form.title.setValue('Oslo');
      form.contact.street.markAsTouched();
      expect(values, isEmpty);

      form.contact.street.setValue('Via Appia');
      form.contact.zip.setValue('00100');

      expect(values.map((s) => s.street.value), ['Via Appia', 'Via Appia']);
      expect(selection, ['00100']);
    });

    test('statusChanges follows the Nested Form', () {
      final form = itinerary();
      final statuses = collect(form.contact.statusChanges);

      form.contact.street.setValue('x'); // MinLength(2)
      form.title.setValue('x'); // another Field: not the Nested Form

      expect(statuses, [FormidableStatus.invalid]);
    });
  });

  group('Field Array streams', () {
    test(
      'valueChanges emits when items are added, removed, moved or edited',
      () {
        final form = itinerary();
        final Stream<FormidableFieldArrayState<TelephoneFormState>> stream =
            form.phones.valueChanges;
        final values = collect(stream);

        form.title.setValue('Oslo'); // not the array
        form.phones.add(const Telephone(number: '333'));
        form.phones.move(2, 0);
        form.phones[1].node.number.setValue('999');
        form.phones[1].node.number.markAsTouched();
        form.phones.removeAt(0);

        expect(values, hasLength(4));
        expect(values.last.items.map((s) => s.number.value), ['999', '222']);
      },
    );

    test('changes emits on touched too, valueChanges does not', () {
      final form = itinerary();
      final changes = collect(form.phones.changes);
      final values = collect(form.phones.valueChanges);

      form.phones.markAsTouched();
      form.phones[0].node.number.markAsTouched();

      expect(changes, hasLength(2));
      expect(values, isEmpty);
    });

    test('statusChanges includes the items', () {
      final form = itinerary();
      final statuses = collect(form.phones.statusChanges);

      form.phones[0].node.number.setValue('1'); // MinLength(3)
      form.phones[0].node.number.setValue('12');
      form.phones[0].node.number.setValue('123');

      expect(statuses, [FormidableStatus.invalid, FormidableStatus.valid]);
    });

    test('select reads the state of the array', () {
      final form = itinerary();
      final lengths = collect(form.phones.select((s) => s.length));

      form.phones[0].node.number.setValue('999');
      form.phones.add();
      form.phones.removeAt(2);

      expect(lengths, [3, 2]);
    });

    test('an array of Fields has them too', () {
      final form = LabelsForm(tags: const ['ab']);
      addTearDown(form.dispose);
      final values = collect(form.tags.valueChanges);

      form.tags[0].node.setValue('cd');
      form.tags[0].node.markAsTouched();
      form.tags.add('ef');

      expect(values, hasLength(2));
    });
  });

  group('Dynamic Form streams', () {
    test(
      'valueChanges emits when something is registered, written or removed',
      () {
        final form = itinerary();
        final Stream<FormidableDynamicFormState> stream =
            form.extras.valueChanges;
        final values = collect(stream);

        form.title.setValue('Oslo'); // not the Dynamic Form
        final age = form.extras.register<int>('age');
        age.setValue(3);
        age.markAsTouched();
        form.extras.remove('age');

        expect(values, hasLength(3));
        expect(values[1].field<int>('age').value, 3);
      },
    );

    test('statusChanges follows the Fields registered in it', () {
      final form = itinerary();
      final statuses = collect(form.extras.statusChanges);

      final age = form.extras.register<int>('age'); // required, Unset
      age.setValue(3);

      expect(statuses, [FormidableStatus.invalid, FormidableStatus.valid]);
    });

    test('select, changes and hasListeners on a standalone Dynamic Form', () {
      final dynamicForm = FormidableDynamicForm();
      addTearDown(dynamicForm.dispose);
      expect(dynamicForm.hasListeners, isFalse);
      final changes = collect(dynamicForm.changes);
      final keys = collect(dynamicForm.select((s) => s.keys.length));
      expect(dynamicForm.hasListeners, isTrue);

      dynamicForm.register<int>('age').setValue(3);

      expect(changes, isNotEmpty);
      expect(keys, [1]);
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/effects.dart';
import 'package:test/test.dart';

void main() {
  setUp(effectLog.clear);

  group('Form Effects', () {
    test('receive the typed Form and react to a change', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.country.setValue('FR');

      expect(form.province.isSet, isFalse);
    });

    test('see a change only in the Effects that ask for it', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.province.setValue('RM');

      expect(form.country.value, 'IT');
      expect(form.province.value, 'RM');
    });

    test('also run once when the Form is created', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      expect(form.label.value, 'IT/MI');
    });

    test('also run when the Form is created from an existing object', () {
      final form = AddressForm.from(
        const Address(revision: 3, country: 'IT', province: 'MI', label: 'x'),
      );

      expect(form.label.value, 'IT/MI');
    });

    test('do not clear initial data: nothing counts as changed at creation',
        () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      expect(form.province.value, 'MI');
      expect(form.revision.value, 0);
    });

    test('run once at creation, and not again for a write that changes '
        'nothing', () {
      EffectOrderForm(title: 'a');
      expect(effectLog.where((e) => e.startsWith('first')), ['first:a']);

      effectLog.clear();
      final form = EffectOrderForm(title: 'a')..title.setValue('a');
      effectLog.clear();
      form.title.setValue('a');

      expect(effectLog, isEmpty);
    });

    test('run after the Normalizers and before the Validators, in order', () {
      final form = EffectOrderForm(title: 'a');
      effectLog.clear();

      form.title.setValue('  b  ');

      expect(effectLog, ['first:b', 'second:b', 'validate:b']);
    });

    test('run before validation, so validation sees what they changed', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'M');
      expect(form.province.state.errors, isNotEmpty);

      form.country.setValue('FR');

      expect(form.province.state.errors, isEmpty);
    });

    test('run again for what other Effects changed, until nothing changes',
        () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.country.setValue('FR');

      // The province cleared in pass 1, which the label and revision follow.
      expect(form.label.value, 'FR/-');
      expect(form.revision.value, 1);
    });

    test('can write a Passthrough Field, which stays observable', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');
      var notifications = 0;
      form.revision.addListener(() => notifications++);

      form.province.setValue('RM');

      expect(form.revision.value, 1);
      expect(notifications, 1);
    });

    test('notify a Field once, with the final state', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'M');
      final seen = <FormidableFieldState<String?>>[];
      form.province.addListener(() => seen.add(form.province.state));

      form.country.setValue('FR');

      expect(seen, hasLength(1));
      expect(seen.single.isSet, isFalse);
      expect(seen.single.errors, isEmpty);
    });

    test('never mark a Field as touched', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.country.setValue('FR');

      expect(form.province.state.touched, isFalse);
      expect(form.label.state.touched, isFalse);
      expect(form.country.state.touched, isFalse);
    });

    test('leave a touched Field touched', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');
      form.province.markAsTouched();

      form.country.setValue('FR');

      expect(form.province.isSet, isFalse);
      expect(form.province.state.touched, isTrue);
    });

    test('also run for programmatic clear()', () {
      final form = AddressForm(revision: 0, country: 'IT', province: 'MI');

      form.province.clear();

      expect(form.label.value, 'IT/-');
    });
  });

  group('a loop between Form Effects', () {
    test('raises a clear error in debug builds', () {
      final form = EffectLoopForm();

      expect(
        () => form.armed.setValue(true),
        throwsA(
          isA<FormidableEffectLoopError>().having(
            (e) => e.message,
            'message',
            allOf(contains('loop'), contains('PingEffect'), contains('PongEffect')),
          ),
        ),
      );
    });

    test('leaves the Form usable', () {
      final form = EffectLoopForm();
      expect(() => form.armed.setValue(true), throwsA(anything));

      form.armed.setValue(false);
      form.ping.setValue(1);

      expect(form.ping.value, 1);
    });

    test('does not trigger without a change', () {
      final form = EffectLoopForm();

      form.armed.setValue(false);
      form.ping.setValue(5);

      expect(form.pong.isSet, isFalse);
    });
  });
}

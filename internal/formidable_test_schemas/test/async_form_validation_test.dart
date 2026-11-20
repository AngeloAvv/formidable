import 'package:fake_async/fake_async.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/async_validation.dart';
import 'package:test/test.dart';

const _debounce = Duration(milliseconds: 300);

({ShippingForm form, PostalCodeMatchesCity validator}) _create({
  String? postalCode,
  String? city,
}) {
  final validator = PostalCodeMatchesCity();
  final form = ShippingForm(
    postalCode: postalCode,
    city: city,
    note: 'n',
    postalCodeMatchesCity: validator,
  );
  return (form: form, validator: validator);
}

void main() {
  group('asynchronous Form Validator', () {
    test('runs after the debounce once every dependency has a value', () {
      fakeAsync((async) {
        final (:form, :validator) = _create();

        form.postalCode.setValue('70121');
        async.elapse(const Duration(seconds: 5));
        expect(validator.calls, isEmpty);
        expect(form.state.pending, isFalse);

        form.city.setValue('Bari');
        expect(form.state.pending, isTrue);
        async.elapse(_debounce);
        expect(validator.calls, ['70121/Bari']);
      });
    });

    test('adds its error to the Field it addresses and ends pending', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Roma');

        async.elapse(_debounce);
        validator.answer('70121/Roma', mismatch: true);
        async.flushMicrotasks();

        expect(form.city.state.errors, [const CityMismatchError()]);
        expect(form.postalCode.state.errors, isEmpty);
        expect(form.state.pending, isFalse);
        expect(form.state.status, FormidableStatus.invalid);
      });
    });

    test('every dependency is pending while it runs', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Bari');

        expect(form.postalCode.state.pending, isTrue);
        expect(form.city.state.pending, isTrue);
        expect(form.note.state.pending, isFalse);

        async.elapse(_debounce);
        validator.answer('70121/Bari', mismatch: false);
        async.flushMicrotasks();

        expect(form.postalCode.state.pending, isFalse);
        expect(form.city.state.pending, isFalse);
        expect(form.value, isNotNull);
      });
    });

    test('debounces over the dependencies and keeps only the last values', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Bari');

        async.elapse(const Duration(milliseconds: 200));
        form.city.setValue('Roma');
        async.elapse(const Duration(milliseconds: 200));
        form.postalCode.setValue('00100');
        async.elapse(_debounce);

        expect(validator.calls, ['00100/Roma']);
      });
    });

    test('an old answer is dropped when a dependency changed', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Roma');
        async.elapse(_debounce);

        form.city.setValue('Bari');
        validator.answer('70121/Roma', mismatch: true);
        async.flushMicrotasks();

        expect(form.city.state.errors, isEmpty);
        expect(form.city.state.pending, isTrue);
      });
    });

    test('its errors go away when a dependency changes', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Roma');
        async.elapse(_debounce);
        validator.answer('70121/Roma', mismatch: true);
        async.flushMicrotasks();

        form.city.setValue('Bari');

        expect(form.city.state.errors, isEmpty);
      });
    });

    test('a dependency going back to Unset cancels the check', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Bari');
        async.elapse(_debounce);

        form.city.clear();
        expect(form.postalCode.state.pending, isFalse);
        validator.answer('70121/Bari', mismatch: true);
        async.flushMicrotasks();

        expect(form.city.state.errors, [isA<FormidableRequiredError>()]);
        expect(form.state.pending, isFalse);
      });
    });

    test('does not run while a dependency has a synchronous error', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '701', city: 'Bari');

        async.elapse(const Duration(seconds: 5));

        expect(validator.calls, isEmpty);
        expect(form.state.pending, isFalse);
      });
    });

    test('submit waits for it and is invalid when it found an error', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Roma');
        FormidableSubmitResult<Shipping>? result;

        form.submit().then((value) => result = value);
        async.elapse(_debounce);
        async.flushMicrotasks();
        expect(result, isNull);

        validator.answer('70121/Roma', mismatch: true);
        async.flushMicrotasks();

        final invalid = result as FormidableSubmitInvalid<Shipping>;
        expect(invalid.fieldErrors[form.city], [const CityMismatchError()]);
      });
    });

    test('a check that throws blocks the first dependency', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Bari');
        final cause = StateError('offline');

        async.elapse(_debounce);
        validator.fail('70121/Bari', cause);
        async.flushMicrotasks();

        expect(form.postalCode.state.errors, [
          FormidableAsyncCheckFailedError(cause),
        ]);
        expect(form.state.pending, isFalse);
      });
    });

    test('disposing the Form cancels it', () {
      fakeAsync((async) {
        final (:form, :validator) = _create(postalCode: '70121', city: 'Bari');

        form.dispose();
        async.elapse(const Duration(seconds: 5));

        expect(validator.calls, isEmpty);
      });
    });
  });
}

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/cross_field.dart';
import 'package:test/test.dart';

void main() {
  _crossFieldRules();
  group('@MustMatch', () {
    test('adds an error to the annotated Field when the values differ', () {
      final form = PasswordChangeForm(password: 'a', confirmation: 'b');

      expect(form.confirmation.state.errors, [isA<FormidableMustMatchError>()]);
      expect(form.password.state.errors, isEmpty);
      expect(form.state.meta.status, FormidableStatus.invalid);
    });

    test('passes when the values are equal', () {
      final form = PasswordChangeForm(password: 'a', confirmation: 'a');

      expect(form.confirmation.state.errors, isEmpty);
    });

    test('reacts when the referenced Field changes', () {
      final form = PasswordChangeForm(password: 'a', confirmation: 'a');

      form.password.setValue('b');
      expect(form.confirmation.state.errors, [isA<FormidableMustMatchError>()]);

      form.password.setValue('a');
      expect(form.confirmation.state.errors, isEmpty);
    });

    test('keeps the Field own errors next to the cross-field error', () {
      final form = PasswordChangeForm(password: 'a');

      expect(form.confirmation.state.errors, [isA<FormidableRequiredError>()]);
    });

    test('blocks submit with the error addressed to the Field', () async {
      final form = PasswordChangeForm(password: 'a', confirmation: 'b');

      final result = await form.submit();

      expect(result, isA<FormidableSubmitInvalid<PasswordChange>>());
      final invalid = result as FormidableSubmitInvalid<PasswordChange>;
      expect(invalid.errors.keys, [form.confirmation]);
    });
  });
}

/// The error types of a Field, which is how these tests read a Field.
List<Type> _types(FormidableField<Object?> field) => [
  for (final error in field.state.errors) error.runtimeType,
];

void _crossFieldRules() {
  group('@Different', () {
    test('fails when both values are equal', () {
      final form = CredentialsForm(oldPassword: 'a', newPassword: 'a');
      expect(_types(form.newPassword), [FormidableDifferentError]);

      form.newPassword.setValue('b');
      expect(form.newPassword.state.errors, isEmpty);
    });

    test('does not judge a Field that is Unset', () {
      final form = CredentialsForm(oldPassword: 'a');
      expect(_types(form.newPassword), [FormidableRequiredError]);
    });
  });

  group('@Compare and @DateRangeOrder', () {
    final day = DateTime(2026, 1, 10);

    test('compares an int with a double', () {
      final form = BookingForm(start: day, end: day, budget: 10.5, spent: 10);
      expect(form.spent.state.errors, isEmpty);

      form.spent.setValue(11);
      expect(_types(form.spent), [FormidableCompareError]);
      expect(
        form.spent.state.errors.single,
        const FormidableCompareError(FormidableComparison.lessThan),
      );
    });

    test('accepts a date on or after the start by default', () {
      final form = BookingForm(start: day, end: day, budget: 1, spent: 0);
      expect(form.end.state.errors, isEmpty);

      form.end.setValue(day.subtract(const Duration(days: 1)));
      expect(form.end.state.errors, [
        const FormidableDateRangeOrderError(allowSame: true),
      ]);
    });

    test('rejects the same moment when allowSame is false', () {
      final form = BookingForm(
        start: day,
        end: day,
        budget: 1,
        spent: 0,
        reminder: day,
      );
      expect(form.reminder.state.errors, [
        const FormidableDateRangeOrderError(allowSame: false),
      ]);
    });

    test('waits until both Fields have a value', () {
      final form = BookingForm(end: day, budget: 1, spent: 0);
      expect(form.end.state.errors, isEmpty);
      expect(form.deadline.state.errors, isEmpty);
    });

    test('FormidableComparison.accepts covers every operator', () {
      const expected = {
        FormidableComparison.equalTo: [false, true, false],
        FormidableComparison.notEqualTo: [true, false, true],
        FormidableComparison.lessThan: [true, false, false],
        FormidableComparison.lessThanOrEqualTo: [true, true, false],
        FormidableComparison.greaterThan: [false, false, true],
        FormidableComparison.greaterThanOrEqualTo: [false, true, true],
      };
      for (final entry in expected.entries) {
        expect(
          [entry.key.accepts(-1), entry.key.accepts(0), entry.key.accepts(1)],
          entry.value,
          reason: '${entry.key}',
        );
      }
    });
  });

  group('required-if family', () {
    test('@RequiredIf and @RequiredUnless follow the other Field value', () {
      final form = ConditionalForm(kind: Kind.company, taxCode: 't');
      expect(_types(form.vat), [FormidableRequiredIfError]);
      expect(form.taxCode.state.errors, isEmpty);

      form.vat.setValue('IT1');
      expect(form.vat.state.errors, isEmpty);

      form.kind.setValue(Kind.person);
      form.taxCode.clear();
      expect(_types(form.taxCode), [FormidableRequiredUnlessError]);
      expect(form.vat.state.errors, isEmpty);
    });

    test('an empty string does not count as filled', () {
      final form = ConditionalForm(kind: Kind.company, vat: '');
      expect(_types(form.vat), [FormidableRequiredIfError]);
    });

    test('@RequiredWith and @RequiredWithAll', () {
      final form = ConditionalForm(kind: Kind.person, taxCode: 't');
      expect(form.emailNote.state.errors, isEmpty);
      expect(form.contactName.state.errors, isEmpty);

      form.email.setValue('a@b.c');
      expect(_types(form.emailNote), [FormidableRequiredWithError]);
      expect(form.contactName.state.errors, isEmpty);

      form.phone.setValue('1');
      expect(_types(form.contactName), [FormidableRequiredWithAllError]);
    });

    test('@RequiredWithout and @RequiredWithoutAll', () {
      final form = ConditionalForm(kind: Kind.person, taxCode: 't');
      expect(_types(form.postalAddress), [FormidableRequiredWithoutError]);
      expect(_types(form.fallback), [FormidableRequiredWithoutAllError]);

      form.email.setValue('a@b.c');
      expect(form.postalAddress.state.errors, isEmpty);
      expect(form.fallback.state.errors, isEmpty);
    });

    test('@RequiredIfAccepted and @RequiredIfDeclined read a bool Field', () {
      final form = ConditionalForm(kind: Kind.person, taxCode: 't');
      expect(form.newsletterEmail.state.errors, isEmpty);
      expect(form.unsubscribeReason.state.errors, isEmpty);

      form.subscribe.setValue(true);
      expect(_types(form.newsletterEmail), [FormidableRequiredIfAcceptedError]);
      expect(form.unsubscribeReason.state.errors, isEmpty);

      form.subscribe.setValue(false);
      expect(form.newsletterEmail.state.errors, isEmpty);
      expect(_types(form.unsubscribeReason), [
        FormidableRequiredIfDeclinedError,
      ]);
    });
  });

  group('prohibited and conditional acceptance rules', () {
    test('@ProhibitedIf and @ProhibitedUnless', () {
      final form = ExclusiveForm(kind: Kind.person, vat: 'IT1', employees: '3');
      expect(_types(form.vat), [FormidableProhibitedIfError]);
      expect(_types(form.employees), [FormidableProhibitedUnlessError]);

      form.kind.setValue(Kind.company);
      expect(form.vat.state.errors, isEmpty);
      expect(form.employees.state.errors, isEmpty);
    });

    test('@Prohibits puts the error on the Field that carries it', () {
      final form = ExclusiveForm(email: 'a@b.c', phone: '1');
      expect(_types(form.email), [FormidableProhibitsError]);
      expect(form.phone.state.errors, isEmpty);

      form.phone.clear();
      expect(form.email.state.errors, isEmpty);
    });

    test('@AcceptedIf needs true, @DeclinedIf needs false', () {
      final form = ExclusiveForm(minor: true);
      expect(_types(form.parentConsent), [FormidableAcceptedIfError]);
      expect(_types(form.marketing), [FormidableDeclinedIfError]);

      form.parentConsent.setValue(true);
      form.marketing.setValue(false);
      expect(form.parentConsent.state.errors, isEmpty);
      expect(form.marketing.state.errors, isEmpty);

      form.marketing.setValue(true);
      expect(_types(form.marketing), [FormidableDeclinedIfError]);

      form.minor.setValue(false);
      expect(form.marketing.state.errors, isEmpty);
    });
  });

  group('group rules', () {
    test('@AtLeastOneOf', () {
      final form = ReachForm();
      expect(_types(form.email), [FormidableAtLeastOneOfError]);

      form.phone.setValue('1');
      expect(form.email.state.errors, isEmpty);
    });

    test('@ExactlyOneOf', () {
      final form = ReachForm();
      expect(_types(form.a), [FormidableExactlyOneOfError]);

      form.b.setValue('1');
      expect(form.a.state.errors, isEmpty);

      form.c.setValue('1');
      expect(_types(form.a), [FormidableExactlyOneOfError]);
    });

    test('@AtMostOneOf', () {
      final form = ReachForm();
      expect(form.x.state.errors, isEmpty);

      form.y.setValue('1');
      form.z.setValue('1');
      expect(_types(form.x), [FormidableAtMostOneOfError]);
    });
  });

  group('collection rules', () {
    test('@InList needs the value to be in the list of the other Field', () {
      final form = TaggingForm(options: ['a', 'b'], choice: 'a');
      expect(form.choice.state.errors, isEmpty);

      form.choice.setValue('z');
      expect(_types(form.choice), [FormidableInListError]);

      form.options.setValue(['z']);
      expect(form.choice.state.errors, isEmpty);
    });

    test('@InList treats an Unset list as empty', () {
      expect(_types(TaggingForm(choice: 'a').choice), [FormidableInListError]);
    });

    test('@UniqueBy compares the keys, not the values', () {
      final form = TaggingForm(existing: ['Ada'], name: 'ADA');
      expect(_types(form.name), [FormidableUniqueByError]);

      form.name.setValue('Grace');
      expect(form.name.state.errors, isEmpty);
    });
  });

  group('an invalid rule blocks the output', () {
    test('value is null and submit is invalid', () async {
      final form = CredentialsForm(oldPassword: 'a', newPassword: 'a');
      expect(form.value, isNull);
      expect(await form.submit(), isA<FormidableSubmitInvalid<Credentials>>());
    });
  });
}

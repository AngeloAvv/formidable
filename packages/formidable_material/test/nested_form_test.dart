import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/checkout.dart';
import 'support/checkout.formidable_scope.dart';

/// Seam 2: Nested Forms reached from widgets through the parent Form.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  Widget page(CheckoutForm form) => app(
    CheckoutFormScope.value(
      form: form,
      child: Builder(
        builder: (context) => Column(
          children: [
            FormidableMaterialTextField(
              field: context.checkoutForm.billing.street,
              decoration: const InputDecoration(labelText: 'Billing street'),
            ),
            FormidableMaterialTextField(
              field: context.checkoutForm.shipping.street,
              decoration: const InputDecoration(labelText: 'Shipping street'),
            ),
            FormidableFormBuilder<AddressForm>(
              form: context.checkoutForm.shipping,
              builder: (context, state) => Text(
                'shipping:${state.meta.status.name}:${state.meta.dirty}',
              ),
            ),
            FormidableFormBuilder<CheckoutForm>(
              builder: (context, state) =>
                  Text('checkout:${state.meta.status.name}'),
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('a nested Field edited in a widget updates the parent', (
    tester,
  ) async {
    final form = CheckoutForm(name: 'Angelo');
    await tester.pumpWidget(page(form));
    expect(find.text('checkout:invalid'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Via Roma');
    await tester.pump();

    expect(form.billing.street.value, 'Via Roma');
    expect(form.state.meta.dirty, isTrue);
    expect(find.text('checkout:valid'), findsOneWidget);
  });

  testWidgets('shows the Validation Message of a nested Field once touched', (
    tester,
  ) async {
    final form = CheckoutForm();
    await tester.pumpWidget(page(form));

    await tester.enterText(find.byType(TextField).first, 'ab');
    form.billing.street.touch();
    await tester.pump();

    expect(
      find.text(
        const FormidableMinLengthError(
          minLength: 3,
          actualLength: 2,
        ).toString(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an optional Nested Form becomes set when typed in', (
    tester,
  ) async {
    final form = CheckoutForm(name: 'Angelo');
    form.billing.street.setValue('Via Roma');
    await tester.pumpWidget(page(form));
    expect(find.text('checkout:valid'), findsOneWidget);
    expect(find.text('shipping:valid:false'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'ab');
    await tester.pump();

    expect(form.shipping.defined, isTrue);
    expect(find.text('shipping:invalid:true'), findsOneWidget);
    expect(find.text('checkout:invalid'), findsOneWidget);
  });

  testWidgets('a Nested Form can be exposed through its own Form Scope', (
    tester,
  ) async {
    final form = CheckoutForm(name: 'Angelo');
    await tester.pumpWidget(
      app(
        AddressFormScope.value(
          form: form.billing,
          child: Builder(
            builder: (context) => FormidableMaterialTextField(
              field: context.addressForm.street,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Via Roma');

    expect(form.billing.street.value, 'Via Roma');
  });

  testWidgets('the Form Selector of the parent follows the output', (
    tester,
  ) async {
    final form = CheckoutForm(name: 'Angelo')
      ..billing.street.setValue('Via Roma');
    await tester.pumpWidget(
      app(
        CheckoutFormScope.value(
          form: form,
          child: CheckoutFormSelector<String?>(
            selector: (state) => state.meta.value?.billing.street,
            builder: (context, street) => Text('street:$street'),
          ),
        ),
      ),
    );
    expect(find.text('street:Via Roma'), findsOneWidget);

    form.billing.street.setValue('Via Milano');
    await tester.pump();

    expect(find.text('street:Via Milano'), findsOneWidget);
  });

  testWidgets('submit focuses the first invalid Field of a Nested Form', (
    tester,
  ) async {
    final billing = FocusNode();
    addTearDown(billing.dispose);
    final form = CheckoutForm(name: 'Angelo');
    await tester.pumpWidget(
      app(
        CheckoutFormScope.value(
          form: form,
          child: Builder(
            builder: (context) => Column(
              children: [
                FormidableMaterialTextField(
                  field: context.checkoutForm.billing.street,
                  focusNode: billing,
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      ),
    );
    expect(billing.hasFocus, isFalse);

    final result = await form.submit();
    await tester.pump();

    expect(result, isA<FormidableSubmitInvalid<Checkout>>());
    expect(billing.hasFocus, isTrue);
    expect(
      find.text(const FormidableRequiredError().toString()),
      findsOneWidget,
    );
  });
}

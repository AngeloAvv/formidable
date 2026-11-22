import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: every Material widget takes the whole API of the Flutter widget it
/// wraps, except what Formidable owns, and keeps each parameter readable.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('FormidableMaterialCheckbox', () {
    late FormidableField<bool> terms;

    setUp(() {
      terms = FormidableField<bool>(required: true);
      addTearDown(terms.dispose);
    });

    testWidgets('hands its parameters to the Checkbox', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialCheckbox<bool>(
            field: terms,
            activeColor: Colors.red,
            checkColor: Colors.green,
            focusColor: Colors.blue,
            hoverColor: Colors.yellow,
            splashRadius: 31,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            mouseCursor: SystemMouseCursors.help,
            side: const BorderSide(width: 3),
            shape: const CircleBorder(),
            isError: true,
            semanticLabel: 'accept',
            autofocus: true,
          ),
        ),
      );

      final box = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(box.activeColor, Colors.red);
      expect(box.checkColor, Colors.green);
      expect(box.focusColor, Colors.blue);
      expect(box.hoverColor, Colors.yellow);
      expect(box.splashRadius, 31);
      expect(box.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(box.visualDensity, VisualDensity.compact);
      expect(box.mouseCursor, SystemMouseCursors.help);
      expect(box.side?.width, 3);
      expect(box.shape, const CircleBorder());
      expect(box.isError, isTrue);
      expect(box.semanticLabel, 'accept');
      expect(box.autofocus, isTrue);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialCheckbox<bool>(
        field: terms,
        tristate: false,
        activeColor: Colors.red,
        side: const BorderSide(width: 3),
        semanticLabel: 'accept',
      );

      expect(widget.field, same(terms));
      expect(widget.tristate, isFalse);
      expect(widget.activeColor, Colors.red);
      expect(widget.side?.width, 3);
      expect(widget.semanticLabel, 'accept');
      expect(widget.autofocus, isFalse);
      expect(widget.isError, isFalse);
      expect(widget.focusNode, isNull);
    });

    testWidgets('is disabled while the Field is', (tester) async {
      await tester.pumpWidget(
        app(FormidableMaterialCheckbox<bool>(field: terms)),
      );
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).onChanged,
        isNotNull,
      );

      terms.disable();
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    });
  });

  group('FormidableMaterialCheckboxListTile', () {
    late FormidableField<bool> terms;

    setUp(() {
      terms = FormidableField<bool>(required: true);
      addTearDown(terms.dispose);
    });

    testWidgets('hands its parameters to the CheckboxListTile', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialCheckboxListTile<bool>(
            field: terms,
            title: const Text('Accept'),
            subtitle: const Text('The terms'),
            secondary: const Icon(Icons.gavel),
            isThreeLine: true,
            dense: true,
            selected: true,
            tileColor: Colors.red,
            selectedTileColor: Colors.green,
            contentPadding: const EdgeInsets.all(7),
            shape: const StadiumBorder(),
            checkboxShape: const CircleBorder(),
            controlAffinity: ListTileControlAffinity.trailing,
            activeColor: Colors.blue,
            checkboxScaleFactor: 1.5,
            minTileHeight: 70,
          ),
        ),
      );

      final tile = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('The terms'), findsOneWidget);
      expect(tile.secondary, isA<Icon>());
      expect(tile.isThreeLine, isTrue);
      expect(tile.dense, isTrue);
      expect(tile.selected, isTrue);
      expect(tile.tileColor, Colors.red);
      expect(tile.selectedTileColor, Colors.green);
      expect(tile.contentPadding, const EdgeInsets.all(7));
      expect(tile.shape, const StadiumBorder());
      expect(tile.checkboxShape, const CircleBorder());
      expect(tile.controlAffinity, ListTileControlAffinity.trailing);
      expect(tile.activeColor, Colors.blue);
      expect(tile.checkboxScaleFactor, 1.5);
      expect(tile.minTileHeight, 70);
    });

    testWidgets('puts the box first unless told otherwise', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialCheckboxListTile<bool>(
            field: terms,
            title: const Text('Accept'),
          ),
        ),
      );

      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .controlAffinity,
        ListTileControlAffinity.leading,
      );
    });

    testWidgets('sets the Field and touches it when tapped', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialCheckboxListTile<bool>(
            field: terms,
            title: const Text('Accept'),
          ),
        ),
      );

      await tester.tap(find.text('Accept'));
      await tester.pump();

      expect(terms.value, isTrue);
      expect(terms.state.touched, isTrue);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialCheckboxListTile<bool>(
        field: terms,
        title: const Text('Accept'),
        dense: true,
        tileColor: Colors.red,
      );

      expect(widget.title, isA<Text>());
      expect(widget.dense, isTrue);
      expect(widget.tileColor, Colors.red);
      expect(widget.subtitle, isNull);
      expect(widget.controlAffinity, ListTileControlAffinity.leading);
    });
  });

  group('FormidableMaterialSwitch', () {
    late FormidableField<bool> notifications;

    setUp(() {
      notifications = FormidableField<bool>(required: true);
      addTearDown(notifications.dispose);
    });

    testWidgets('hands its parameters to the Switch', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialSwitch(
            field: notifications,
            activeThumbColor: Colors.red,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.blue,
            inactiveTrackColor: Colors.yellow,
            trackOutlineWidth: WidgetStateProperty.all(3),
            thumbIcon: WidgetStateProperty.all(const Icon(Icons.check)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            dragStartBehavior: DragStartBehavior.down,
            mouseCursor: WidgetStateMouseCursor.clickable,
            splashRadius: 21,
            padding: const EdgeInsets.all(9),
            autofocus: true,
          ),
        ),
      );

      final toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.activeThumbColor, Colors.red);
      expect(toggle.activeTrackColor, Colors.green);
      expect(toggle.inactiveThumbColor, Colors.blue);
      expect(toggle.inactiveTrackColor, Colors.yellow);
      expect(toggle.trackOutlineWidth?.resolve({}), 3);
      expect(toggle.thumbIcon?.resolve({}), isA<Icon>());
      expect(toggle.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(toggle.dragStartBehavior, DragStartBehavior.down);
      expect(toggle.splashRadius, 21);
      expect(toggle.padding, const EdgeInsets.all(9));
      expect(toggle.autofocus, isTrue);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialSwitch(
        field: notifications,
        activeThumbColor: Colors.red,
        padding: const EdgeInsets.all(9),
      );

      expect(widget.activeThumbColor, Colors.red);
      expect(widget.padding, const EdgeInsets.all(9));
      expect(widget.dragStartBehavior, DragStartBehavior.start);
      expect(widget.autofocus, isFalse);
    });

    testWidgets('is disabled while the Field is', (tester) async {
      await tester.pumpWidget(
        app(FormidableMaterialSwitch(field: notifications)),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNotNull);

      notifications.disable();
      await tester.pump();

      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });
  });

  group('FormidableMaterialSwitchListTile', () {
    late FormidableField<bool> notifications;

    setUp(() {
      notifications = FormidableField<bool>(required: true);
      addTearDown(notifications.dispose);
    });

    testWidgets('hands its parameters to the SwitchListTile', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialSwitchListTile(
            field: notifications,
            title: const Text('Notifications'),
            subtitle: const Text('Once a day'),
            secondary: const Icon(Icons.notifications),
            isThreeLine: true,
            dense: true,
            tileColor: Colors.red,
            contentPadding: const EdgeInsets.all(7),
            controlAffinity: ListTileControlAffinity.leading,
            activeThumbColor: Colors.green,
            visualDensity: VisualDensity.compact,
            horizontalTitleGap: 13,
          ),
        ),
      );

      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Once a day'), findsOneWidget);
      expect(tile.secondary, isA<Icon>());
      expect(tile.isThreeLine, isTrue);
      expect(tile.dense, isTrue);
      expect(tile.tileColor, Colors.red);
      expect(tile.contentPadding, const EdgeInsets.all(7));
      expect(tile.controlAffinity, ListTileControlAffinity.leading);
      expect(tile.activeThumbColor, Colors.green);
      expect(tile.visualDensity, VisualDensity.compact);
      expect(tile.horizontalTitleGap, 13);
    });

    testWidgets('sets the Field and touches it when tapped', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialSwitchListTile(
            field: notifications,
            title: const Text('Notifications'),
          ),
        ),
      );

      await tester.tap(find.text('Notifications'));
      await tester.pump();

      expect(notifications.value, isTrue);
      expect(notifications.state.touched, isTrue);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialSwitchListTile(
        field: notifications,
        title: const Text('Notifications'),
        dense: true,
      );

      expect(widget.title, isA<Text>());
      expect(widget.dense, isTrue);
      expect(widget.subtitle, isNull);
    });
  });

  group('FormidableMaterialRadioGroup', () {
    late FormidableField<String> plan;

    setUp(() {
      plan = FormidableField<String>(required: true);
      addTearDown(plan.dispose);
    });

    List<FormidableMaterialRadioOption<String>> options() => [
      const FormidableMaterialRadioOption(
        value: 'free',
        title: Text('Free'),
        subtitle: Text('No cost'),
        secondary: Icon(Icons.money_off),
        isThreeLine: true,
      ),
      const FormidableMaterialRadioOption(value: 'pro', title: Text('Pro')),
    ];

    testWidgets('hands its parameters to every RadioListTile', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(
            field: plan,
            options: options(),
            activeColor: Colors.red,
            hoverColor: Colors.yellow,
            dense: true,
            tileColor: Colors.green,
            selectedTileColor: Colors.blue,
            contentPadding: const EdgeInsets.all(5),
            controlAffinity: ListTileControlAffinity.trailing,
            visualDensity: VisualDensity.compact,
            shape: const StadiumBorder(),
            radioScaleFactor: 1.5,
            splashRadius: 17,
            toggleable: true,
          ),
        ),
      );

      final tiles = tester.widgetList<RadioListTile<(String,)>>(
        find.byType(RadioListTile<(String,)>),
      );
      expect(tiles, hasLength(2));
      for (final tile in tiles) {
        expect(tile.activeColor, Colors.red);
        expect(tile.hoverColor, Colors.yellow);
        expect(tile.dense, isTrue);
        expect(tile.tileColor, Colors.green);
        expect(tile.selectedTileColor, Colors.blue);
        expect(tile.contentPadding, const EdgeInsets.all(5));
        expect(tile.controlAffinity, ListTileControlAffinity.trailing);
        expect(tile.visualDensity, VisualDensity.compact);
        expect(tile.shape, const StadiumBorder());
        expect(tile.radioScaleFactor, 1.5);
        expect(tile.splashRadius, 17);
        expect(tile.toggleable, isTrue);
      }
    });

    testWidgets('keeps the content of each option', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(field: plan, options: options()),
        ),
      );

      final free = tester
          .widgetList<RadioListTile<(String,)>>(
            find.byType(RadioListTile<(String,)>),
          )
          .first;
      expect(find.text('No cost'), findsOneWidget);
      expect(free.secondary, isA<Icon>());
      expect(free.isThreeLine, isTrue);
    });

    testWidgets('an option can be disabled on its own', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(
            field: plan,
            options: const [
              FormidableMaterialRadioOption(
                value: 'free',
                title: Text('Free'),
                enabled: false,
              ),
              FormidableMaterialRadioOption(value: 'pro', title: Text('Pro')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Free'));
      await tester.pump();
      expect(plan.defined, isFalse);

      await tester.tap(find.text('Pro'));
      await tester.pump();
      expect(plan.value, 'pro');
    });

    testWidgets('every option is disabled while the Field is', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(field: plan, options: options()),
        ),
      );
      RadioListTile<(String,)> tile(int index) => tester
          .widgetList<RadioListTile<(String,)>>(
            find.byType(RadioListTile<(String,)>),
          )
          .elementAt(index);
      expect(tile(0).enabled, isNull);

      plan.disable();
      await tester.pump();

      expect(tile(0).enabled, isFalse);
      expect(tile(1).enabled, isFalse);
      await tester.tap(find.text('Pro'));
      await tester.pump();
      expect(plan.defined, isFalse);
    });

    testWidgets('a toggleable group on a non-nullable Field goes Unset', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(
            field: plan,
            options: options(),
            toggleable: true,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      expect(plan.value, 'pro');

      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.defined, isFalse);
      expect(plan.state.touched, isTrue);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialRadioGroup<String>(
        field: plan,
        options: options(),
        activeColor: Colors.red,
        dense: true,
      );

      expect(widget.options, hasLength(2));
      expect(widget.activeColor, Colors.red);
      expect(widget.dense, isTrue);
      expect(widget.toggleable, isFalse);
      expect(widget.options.first.subtitle, isA<Text>());
    });
  });

  group('FormidableMaterialSlider', () {
    late FormidableField<double> volume;

    setUp(() {
      volume = FormidableField<double>(required: true);
      addTearDown(volume.dispose);
    });

    testWidgets('hands its parameters to the Slider', (tester) async {
      final changes = <double>[];
      await tester.pumpWidget(
        app(
          FormidableMaterialSlider<double>(
            field: volume,
            min: 1,
            max: 9,
            divisions: 8,
            label: 'Volume',
            activeColor: Colors.red,
            inactiveColor: Colors.green,
            secondaryActiveColor: Colors.blue,
            thumbColor: Colors.yellow,
            overlayColor: WidgetStateProperty.all(Colors.black),
            mouseCursor: WidgetStateMouseCursor.clickable,
            secondaryTrackValue: 5,
            padding: const EdgeInsets.all(3),
            showValueIndicator: ShowValueIndicator.never,
            allowedInteraction: SliderInteraction.tapOnly,
            semanticFormatterCallback: (value) => 'v$value',
            onChangeStart: changes.add,
            onChangeEnd: changes.add,
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 1);
      expect(slider.max, 9);
      expect(slider.divisions, 8);
      expect(slider.label, isNull, reason: 'the Field has no value yet');
      expect(slider.activeColor, Colors.red);
      expect(slider.inactiveColor, Colors.green);
      expect(slider.secondaryActiveColor, Colors.blue);
      expect(slider.thumbColor, Colors.yellow);
      expect(slider.secondaryTrackValue, 5);
      expect(slider.padding, const EdgeInsets.all(3));
      expect(slider.showValueIndicator, ShowValueIndicator.never);
      expect(slider.allowedInteraction, SliderInteraction.tapOnly);
      expect(slider.semanticFormatterCallback!(2), 'v2.0');

      slider.onChangeStart!(2);
      slider.onChangeEnd!(3);
      expect(changes, [2, 3]);
    });

    testWidgets('shows the static label once the Field has a value', (
      tester,
    ) async {
      volume.setValue(4);
      await tester.pumpWidget(
        app(
          FormidableMaterialSlider<double>(
            field: volume,
            max: 10,
            divisions: 10,
            label: 'Volume',
          ),
        ),
      );

      expect(tester.widget<Slider>(find.byType(Slider)).label, 'Volume');
    });

    testWidgets('does not take a label and a label builder together', (
      tester,
    ) async {
      expect(
        () => FormidableMaterialSlider<double>(
          field: volume,
          label: 'Volume',
          labelBuilder: (value) => '$value',
        ),
        throwsAssertionError,
      );
    });

    testWidgets('is disabled while the Field is', (tester) async {
      await tester.pumpWidget(
        app(FormidableMaterialSlider<double>(field: volume)),
      );
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);

      volume.disable();
      await tester.pump();

      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialSlider<double>(
        field: volume,
        min: 2,
        max: 8,
        divisions: 3,
        label: 'Volume',
        activeColor: Colors.red,
        padding: const EdgeInsets.all(3),
      );

      expect(widget.min, 2);
      expect(widget.max, 8);
      expect(widget.divisions, 3);
      expect(widget.label, 'Volume');
      expect(widget.activeColor, Colors.red);
      expect(widget.padding, const EdgeInsets.all(3));
      expect(widget.labelBuilder, isNull);
    });
  });

  group('FormidableMaterialDropdown', () {
    late FormidableField<String> country;

    setUp(() {
      country = FormidableField<String>(required: true);
      addTearDown(country.dispose);
    });

    const items = [
      DropdownMenuItem(value: 'it', child: Text('Italy')),
      DropdownMenuItem(value: 'fr', child: Text('France')),
    ];

    testWidgets('hands its parameters to the DropdownButton', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        app(
          FormidableMaterialDropdown<String>(
            field: country,
            items: items,
            hint: const Text('Pick'),
            disabledHint: const Text('Off'),
            elevation: 3,
            style: const TextStyle(fontSize: 21),
            icon: const Icon(Icons.expand_more),
            iconDisabledColor: Colors.red,
            iconEnabledColor: Colors.green,
            iconSize: 31,
            isDense: false,
            isExpanded: false,
            itemHeight: 70,
            menuWidth: 200,
            focusColor: Colors.blue,
            autofocus: true,
            dropdownColor: Colors.yellow,
            menuMaxHeight: 300,
            enableFeedback: false,
            alignment: AlignmentDirectional.centerEnd,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            barrierDismissible: false,
            mouseCursor: SystemMouseCursors.help,
            onTap: () => tapped++,
          ),
        ),
      );

      final button = tester.widget<DropdownButton<(String,)>>(
        find.byType(DropdownButton<(String,)>),
      );
      expect(button.elevation, 3);
      expect(button.style?.fontSize, 21);
      expect(button.icon, isA<Icon>());
      expect(button.iconDisabledColor, Colors.red);
      expect(button.iconEnabledColor, Colors.green);
      expect(button.iconSize, 31);
      expect(button.isDense, isFalse);
      expect(button.isExpanded, isFalse);
      expect(button.itemHeight, 70);
      expect(button.menuWidth, 200);
      expect(button.focusColor, Colors.blue);
      expect(button.autofocus, isTrue);
      expect(button.dropdownColor, Colors.yellow);
      expect(button.menuMaxHeight, 300);
      expect(button.enableFeedback, isFalse);
      expect(button.alignment, AlignmentDirectional.centerEnd);
      expect(button.borderRadius, BorderRadius.circular(5));
      expect(button.padding, const EdgeInsets.all(2));
      expect(button.barrierDismissible, isFalse);
      expect(button.mouseCursor, SystemMouseCursors.help);
      expect(button.disabledHint, isA<Text>());

      button.onTap!();
      expect(tapped, 1);
    });

    testWidgets('keeps the dense and expanded layout by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(FormidableMaterialDropdown<String>(field: country, items: items)),
      );

      final button = tester.widget<DropdownButton<(String,)>>(
        find.byType(DropdownButton<(String,)>),
      );
      expect(button.isDense, isTrue);
      expect(button.isExpanded, isTrue);
    });

    testWidgets('shows the disabled hint while the Field is disabled', (
      tester,
    ) async {
      country.disable();
      await tester.pumpWidget(
        app(
          FormidableMaterialDropdown<String>(
            field: country,
            items: items,
            hint: const Text('Pick'),
            disabledHint: const Text('Off'),
          ),
        ),
      );

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Pick'), findsNothing);
    });

    testWidgets('builds the shown item from selectedItemBuilder', (
      tester,
    ) async {
      country.setValue('fr');
      await tester.pumpWidget(
        app(
          FormidableMaterialDropdown<String>(
            field: country,
            items: items,
            selectedItemBuilder: (context) => [
              for (final item in items) Text('picked ${item.value}'),
            ],
          ),
        ),
      );

      expect(find.text('picked fr'), findsOneWidget);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialDropdown<String>(
        field: country,
        items: items,
        elevation: 3,
        iconSize: 31,
        isExpanded: false,
        decoration: const InputDecoration(labelText: 'Country'),
      );

      expect(widget.items, hasLength(2));
      expect(widget.elevation, 3);
      expect(widget.iconSize, 31);
      expect(widget.isExpanded, isFalse);
      expect(widget.isDense, isTrue);
      expect(widget.decoration.labelText, 'Country');
      expect(widget.decorationBuilder, isNull);
    });
  });

  group('FormidableMaterialSegmentedButton', () {
    late FormidableField<String> size;

    setUp(() {
      size = FormidableField<String>(required: true);
      addTearDown(size.dispose);
    });

    const segments = [
      ButtonSegment(value: 's', label: Text('S')),
      ButtonSegment(value: 'm', label: Text('M')),
    ];

    testWidgets('hands its parameters to the SegmentedButton', (tester) async {
      await tester.pumpWidget(
        app(
          SizedBox(
            height: 300,
            child: FormidableMaterialSegmentedButton<String>(
              field: size,
              segments: segments,
              style: SegmentedButton.styleFrom(backgroundColor: Colors.red),
              showSelectedIcon: false,
              selectedIcon: const Icon(Icons.check),
              expandedInsets: const EdgeInsets.all(4),
              direction: Axis.vertical,
            ),
          ),
        ),
      );

      final button = tester.widget<SegmentedButton<(String,)>>(
        find.byType(SegmentedButton<(String,)>),
      );
      expect(button.style, isNotNull);
      expect(button.showSelectedIcon, isFalse);
      expect(button.selectedIcon, isA<Icon>());
      expect(button.expandedInsets, const EdgeInsets.all(4));
      expect(button.direction, Axis.vertical);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialSegmentedButton<String>(
        field: size,
        segments: segments,
        allowDeselect: true,
        direction: Axis.vertical,
        expandedInsets: const EdgeInsets.all(4),
      );

      expect(widget.segments, hasLength(2));
      expect(widget.allowDeselect, isTrue);
      expect(widget.direction, Axis.vertical);
      expect(widget.expandedInsets, const EdgeInsets.all(4));
      expect(widget.showSelectedIcon, isTrue);
    });
  });

  group('FormidableMaterialDatePicker', () {
    late FormidableField<DateTime> birthday;

    setUp(() {
      birthday = FormidableField<DateTime>(required: true);
      addTearDown(birthday.dispose);
    });

    testWidgets('hands its parameters to the date dialog', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialDatePicker<DateTime>(
            field: birthday,
            initialDate: DateTime(2024, 5, 10),
            firstDate: DateTime(2024),
            lastDate: DateTime(2024, 12, 31),
            helpText: 'Pick the day',
            cancelText: 'Nope',
            confirmText: 'Yes',
            fieldLabelText: 'Typed date',
            initialEntryMode: DatePickerEntryMode.input,
            selectableDayPredicate: (day) => day.day != 11,
          ),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      expect(find.text('Pick the day'), findsOneWidget);
      expect(find.text('Nope'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('Typed date'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialDatePicker<DateTime>(
        field: birthday,
        helpText: 'Pick the day',
        currentDate: DateTime(2024, 5, 1),
        useRootNavigator: false,
        clearable: true,
        initialEntryMode: DatePickerEntryMode.input,
      );

      expect(widget.helpText, 'Pick the day');
      expect(widget.currentDate, DateTime(2024, 5, 1));
      expect(widget.useRootNavigator, isFalse);
      expect(widget.clearable, isTrue);
      expect(widget.initialEntryMode, DatePickerEntryMode.input);
      expect(widget.barrierDismissible, isTrue);
      expect(widget.firstDate, isNull);
    });
  });

  group('FormidableMaterialTimePicker', () {
    late FormidableField<TimeOfDay> reminder;

    setUp(() {
      reminder = FormidableField<TimeOfDay>(required: true);
      addTearDown(reminder.dispose);
    });

    testWidgets('hands its parameters to the time dialog', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTimePicker<TimeOfDay>(
            field: reminder,
            initialTime: const TimeOfDay(hour: 9, minute: 30),
            helpText: 'Pick the hour',
            cancelText: 'Nope',
            confirmText: 'Yes',
            hourLabelText: 'Hours',
            minuteLabelText: 'Minutes',
            initialEntryMode: TimePickerEntryMode.input,
          ),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      expect(find.text('Pick the hour'), findsOneWidget);
      expect(find.text('Nope'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);
    });

    testWidgets('keeps every parameter readable', (tester) async {
      final widget = FormidableMaterialTimePicker<TimeOfDay>(
        field: reminder,
        helpText: 'Pick the hour',
        orientation: Orientation.portrait,
        useRootNavigator: false,
        clearable: true,
      );

      expect(widget.helpText, 'Pick the hour');
      expect(widget.orientation, Orientation.portrait);
      expect(widget.useRootNavigator, isFalse);
      expect(widget.clearable, isTrue);
      expect(widget.initialEntryMode, TimePickerEntryMode.dial);
      expect(widget.initialTime, isNull);
    });
  });
}

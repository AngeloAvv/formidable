import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'support/harness.dart';
import 'support/profile.dart';

/// Seam 2: every widget takes the whole API of the Cupertino widget it wraps,
/// except what Formidable owns, and keeps every parameter readable.
void main() {
  late ProfileForm form;

  Future<void> pump(
    WidgetTester tester,
    Widget Function(ProfileForm) field, {
    DateTime? born,
    Duration? alarm,
  }) => tester.pumpWidget(
    profileApp(
      field,
      create: () => ProfileForm(
        username: 'angelo',
        terms: false,
        plan: 'free',
        volume: 0.5,
        born: born,
        alarm: alarm,
      ),
      onForm: (f) => form = f,
    ),
  );

  group('FormidableCupertinoCheckbox', () {
    testWidgets('hands every parameter to the CupertinoCheckbox', (
      tester,
    ) async {
      final side = BorderSide(color: CupertinoColors.activeOrange);
      const shape = RoundedRectangleBorder();
      late FormidableCupertinoCheckbox widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoCheckbox(
          field: form.terms,
          mouseCursor: SystemMouseCursors.help,
          activeColor: CupertinoColors.activeGreen,
          fillColor: WidgetStateProperty.all(CupertinoColors.systemPink),
          checkColor: CupertinoColors.black,
          focusColor: CupertinoColors.systemYellow,
          autofocus: true,
          side: side,
          shape: shape,
          tapTargetSize: const Size(60, 60),
          semanticLabel: 'Terms',
        );
        return widget;
      });

      final checkbox = tester.widget<CupertinoCheckbox>(
        find.byType(CupertinoCheckbox),
      );
      expect(checkbox.mouseCursor, SystemMouseCursors.help);
      expect(checkbox.activeColor, CupertinoColors.activeGreen);
      expect(checkbox.checkColor, CupertinoColors.black);
      expect(checkbox.focusColor, CupertinoColors.systemYellow);
      expect(checkbox.autofocus, isTrue);
      expect(checkbox.side, side);
      expect(checkbox.shape, shape);
      expect(checkbox.tapTargetSize, const Size(60, 60));
      expect(checkbox.semanticLabel, 'Terms');
      expect(widget.activeColor, CupertinoColors.activeGreen);
      expect(widget.semanticLabel, 'Terms');
      expect(widget.tristate, isFalse);
    });

    testWidgets('a tristate checkbox shows an Unset Field as mixed', (
      tester,
    ) async {
      await pump(
        tester,
        (form) =>
            FormidableCupertinoCheckbox(field: form.terms, tristate: true),
      );
      CupertinoCheckbox checkbox() =>
          tester.widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox));
      expect(checkbox().tristate, isTrue);
      expect(checkbox().value, isFalse);

      form.terms.clear();
      await tester.pump();
      expect(checkbox().value, isNull);

      await tester.tap(find.byType(CupertinoCheckbox));
      await tester.pump();
      expect(form.terms.value, isFalse);
      await tester.tap(find.byType(CupertinoCheckbox));
      await tester.pump();
      expect(form.terms.value, isTrue);
      await tester.tap(find.byType(CupertinoCheckbox));
      await tester.pump();
      expect(form.terms.defined, isFalse);
      expect(form.terms.state.touched, isTrue);
    });

    testWidgets('the focus node of the control is attached', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoCheckbox(field: form.terms),
      );

      expect(
        tester
            .widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox))
            .focusNode,
        isNotNull,
      );
    });

    testWidgets('a given focus node is the one attached', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pump(
        tester,
        (form) => FormidableCupertinoCheckbox(
          field: form.terms,
          focusNode: focusNode,
        ),
      );

      expect(
        tester
            .widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox))
            .focusNode,
        same(focusNode),
      );
    });

    testWidgets('the action key of the field before moves the focus to it', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        profileApp(
          (form) => Column(
            children: [
              FormidableCupertinoTextField<String>(field: form.username),
              FormidableCupertinoCheckbox(
                field: form.terms,
                focusNode: focusNode,
              ),
            ],
          ),
          create: () => ProfileForm(username: 'angelo', terms: false),
          onForm: (f) => form = f,
        ),
      );
      expect(focusNode.hasFocus, isFalse);

      await tester.tap(find.byType(CupertinoTextField).first);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(form.terms.state.touched, isFalse);

      focusNode.unfocus();
      await tester.pump();

      expect(form.terms.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoSwitch', () {
    testWidgets('hands every parameter to the CupertinoSwitch', (tester) async {
      final focusChanges = <bool>[];
      const thumbImage = AssetImage('thumb.png');
      void imageError(Object error, StackTrace? stackTrace) {}
      late FormidableCupertinoSwitch widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoSwitch(
          field: form.terms,
          activeTrackColor: CupertinoColors.activeOrange,
          inactiveTrackColor: CupertinoColors.systemGrey,
          thumbColor: CupertinoColors.systemYellow,
          inactiveThumbColor: CupertinoColors.systemPink,
          applyTheme: true,
          focusColor: CupertinoColors.systemTeal,
          onLabelColor: CupertinoColors.white,
          offLabelColor: CupertinoColors.black,
          activeThumbImage: thumbImage,
          onActiveThumbImageError: imageError,
          inactiveThumbImage: thumbImage,
          onInactiveThumbImageError: imageError,
          trackOutlineColor: WidgetStateProperty.all(CupertinoColors.black),
          trackOutlineWidth: WidgetStateProperty.all(3),
          thumbIcon: WidgetStateProperty.all(
            const Icon(CupertinoIcons.check_mark),
          ),
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.help),
          onFocusChange: focusChanges.add,
          autofocus: true,
          dragStartBehavior: DragStartBehavior.down,
        );
        return widget;
      });

      final control = tester.widget<CupertinoSwitch>(
        find.byType(CupertinoSwitch),
      );
      expect(control.activeTrackColor, CupertinoColors.activeOrange);
      expect(control.inactiveTrackColor, CupertinoColors.systemGrey);
      expect(control.thumbColor, CupertinoColors.systemYellow);
      expect(control.inactiveThumbColor, CupertinoColors.systemPink);
      expect(control.applyTheme, isTrue);
      expect(control.focusColor, CupertinoColors.systemTeal);
      expect(control.onLabelColor, CupertinoColors.white);
      expect(control.offLabelColor, CupertinoColors.black);
      expect(control.activeThumbImage, thumbImage);
      expect(control.onActiveThumbImageError, same(imageError));
      expect(control.inactiveThumbImage, thumbImage);
      expect(control.onInactiveThumbImageError, same(imageError));
      expect(control.trackOutlineWidth, isNotNull);
      expect(control.trackOutlineColor, isNotNull);
      expect(control.thumbIcon, isNotNull);
      expect(control.mouseCursor, isNotNull);
      expect(control.autofocus, isTrue);
      expect(control.dragStartBehavior, DragStartBehavior.down);
      expect(widget.activeTrackColor, CupertinoColors.activeOrange);
      expect(widget.dragStartBehavior, DragStartBehavior.down);
      expect(focusChanges, isNotEmpty);
    });

    testWidgets('the focus node of the control is attached', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSwitch(field: form.terms),
      );

      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).focusNode,
        isNotNull,
      );
    });

    testWidgets('a given focus node is the one attached, and blur touches', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pump(
        tester,
        (form) =>
            FormidableCupertinoSwitch(field: form.terms, focusNode: focusNode),
      );
      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).focusNode,
        same(focusNode),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(form.terms.state.touched, isFalse);
      focusNode.unfocus();
      await tester.pump();

      expect(form.terms.state.touched, isTrue);
    });

    testWidgets('a tap still touches the Field on the first interaction', (
      tester,
    ) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSwitch(field: form.terms),
      );

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      expect(form.terms.value, isTrue);
      expect(form.terms.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoSlider', () {
    testWidgets('hands every parameter to the CupertinoSlider', (tester) async {
      final starts = <double>[];
      final ends = <double>[];
      late FormidableCupertinoSlider widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoSlider(
          field: form.volume,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: CupertinoColors.activeOrange,
          thumbColor: CupertinoColors.systemPink,
          onChangeStart: starts.add,
          onChangeEnd: ends.add,
        );
        return widget;
      });

      final slider = tester.widget<CupertinoSlider>(
        find.byType(CupertinoSlider),
      );
      expect(slider.min, 0);
      expect(slider.max, 10);
      expect(slider.divisions, 10);
      expect(slider.activeColor, CupertinoColors.activeOrange);
      expect(slider.thumbColor, CupertinoColors.systemPink);
      expect(widget.max, 10);
      expect(widget.thumbColor, CupertinoColors.systemPink);

      slider.onChangeStart!(2);
      slider.onChangeEnd!(3);

      expect(starts, [2]);
      expect(ends, [3]);
      expect(form.volume.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoRadioGroup', () {
    testWidgets('exposes its child', (tester) async {
      const child = SizedBox(key: Key('child'));
      late FormidableCupertinoRadioGroup<String> widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoRadioGroup<String>(
          field: form.plan,
          child: child,
        );
        return widget;
      });

      expect(widget.child, child);
      expect(find.byKey(const Key('child')), findsOneWidget);
    });
  });

  const plans = {
    'free': Text('Free'),
    'pro': Text('Pro'),
    'team': Text('Team'),
  };

  group('FormidableCupertinoSegmentedControl', () {
    testWidgets('hands every parameter to the CupertinoSegmentedControl', (
      tester,
    ) async {
      late FormidableCupertinoSegmentedControl<String> widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoSegmentedControl<String>(
          field: form.plan,
          children: plans,
          unselectedColor: CupertinoColors.systemGrey,
          selectedColor: CupertinoColors.activeOrange,
          borderColor: CupertinoColors.black,
          pressedColor: CupertinoColors.systemPink,
          disabledColor: CupertinoColors.systemYellow,
          disabledTextColor: CupertinoColors.systemTeal,
          padding: const EdgeInsets.all(3),
          disabledChildren: const {'team'},
        );
        return widget;
      });

      final control = tester.widget<CupertinoSegmentedControl<String>>(
        find.byType(CupertinoSegmentedControl<String>),
      );
      expect(control.unselectedColor, CupertinoColors.systemGrey);
      expect(control.selectedColor, CupertinoColors.activeOrange);
      expect(control.borderColor, CupertinoColors.black);
      expect(control.pressedColor, CupertinoColors.systemPink);
      expect(control.disabledColor, CupertinoColors.systemYellow);
      expect(control.disabledTextColor, CupertinoColors.systemTeal);
      expect(control.padding, const EdgeInsets.all(3));
      expect(control.disabledChildren, {'team'});
      expect(widget.children, plans);
      expect(widget.disabledChildren, {'team'});
    });
  });

  group('FormidableCupertinoSlidingSegmentedControl', () {
    testWidgets('hands every parameter to the control', (tester) async {
      late FormidableCupertinoSlidingSegmentedControl<String> widget;
      await pump(tester, (form) {
        widget = FormidableCupertinoSlidingSegmentedControl<String>(
          field: form.plan,
          children: plans,
          disabledChildren: const {'team'},
          thumbColor: CupertinoColors.activeOrange,
          padding: const EdgeInsets.all(3),
          backgroundColor: CupertinoColors.systemGrey,
          proportionalWidth: true,
          isMomentary: true,
        );
        return widget;
      });

      final control = tester.widget<CupertinoSlidingSegmentedControl<String>>(
        find.byType(CupertinoSlidingSegmentedControl<String>),
      );
      expect(control.disabledChildren, {'team'});
      expect(control.thumbColor, CupertinoColors.activeOrange);
      expect(control.padding, const EdgeInsets.all(3));
      expect(control.backgroundColor, CupertinoColors.systemGrey);
      expect(control.proportionalWidth, isTrue);
      expect(control.isMomentary, isTrue);
      expect(widget.proportionalWidth, isTrue);
    });

    testWidgets('keeps the defaults of Flutter when left out', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSlidingSegmentedControl<String>(
          field: form.plan,
          children: plans,
        ),
      );

      final control = tester.widget<CupertinoSlidingSegmentedControl<String>>(
        find.byType(CupertinoSlidingSegmentedControl<String>),
      );
      final defaults = CupertinoSlidingSegmentedControl<String>(
        children: plans,
        onValueChanged: (_) {},
      );
      expect(control.thumbColor, defaults.thumbColor);
      expect(control.padding, defaults.padding);
      expect(control.backgroundColor, defaults.backgroundColor);
      expect(control.proportionalWidth, isFalse);
      expect(control.isMomentary, isFalse);
    });
  });

  group('FormidableCupertinoDatePicker', () {
    testWidgets('hands every parameter to the CupertinoDatePicker', (
      tester,
    ) async {
      late FormidableCupertinoDatePicker widget;
      Widget? overlay(
        BuildContext context, {
        required int columnCount,
        required int selectedIndex,
      }) => null;
      bool predicate(DateTime _) => true;
      await pump(tester, (form) {
        widget = FormidableCupertinoDatePicker(
          field: form.born,
          mode: CupertinoDatePickerMode.date,
          minimumYear: 1990,
          maximumYear: 2030,
          dateOrder: DatePickerDateOrder.ymd,
          backgroundColor: CupertinoColors.systemGrey,
          showDayOfWeek: true,
          itemExtent: 40,
          selectionOverlayBuilder: overlay,
          selectableDayPredicate: predicate,
          changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
          height: 180,
        );
        return widget;
      }, born: DateTime(2000, 5, 17));

      final picker = tester.widget<CupertinoDatePicker>(
        find.byType(CupertinoDatePicker),
      );
      expect(picker.minimumYear, 1990);
      expect(picker.maximumYear, 2030);
      expect(picker.dateOrder, DatePickerDateOrder.ymd);
      expect(picker.backgroundColor, CupertinoColors.systemGrey);
      expect(picker.showDayOfWeek, isTrue);
      expect(picker.itemExtent, 40);
      expect(picker.selectionOverlayBuilder, same(overlay));
      expect(picker.selectableDayPredicate, same(predicate));
      expect(
        picker.changeReportingBehavior,
        ChangeReportingBehavior.onScrollEnd,
      );
      expect(widget.minimumYear, 1990);
      expect(widget.height, 180);
      expect(tester.getSize(find.byType(CupertinoDatePicker)).height, 180);
    });

    testWidgets('keeps the defaults of Flutter when left out', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoDatePicker(
          field: form.born,
          mode: CupertinoDatePickerMode.date,
        ),
        born: DateTime(2000, 5, 17),
      );

      final picker = tester.widget<CupertinoDatePicker>(
        find.byType(CupertinoDatePicker),
      );
      final defaults = CupertinoDatePicker(onDateTimeChanged: (_) {});
      expect(picker.itemExtent, defaults.itemExtent);
      expect(picker.minimumYear, 1);
      expect(picker.showTimeSeparator, isFalse);
    });
  });

  group('FormidableCupertinoTimerPicker', () {
    testWidgets('hands every parameter to the CupertinoTimerPicker', (
      tester,
    ) async {
      late FormidableCupertinoTimerPicker widget;
      Widget? overlay(
        BuildContext context, {
        required int columnCount,
        required int selectedIndex,
      }) => null;
      await pump(tester, (form) {
        widget = FormidableCupertinoTimerPicker(
          field: form.alarm,
          mode: CupertinoTimerPickerMode.hm,
          minuteInterval: 5,
          alignment: Alignment.centerLeft,
          backgroundColor: CupertinoColors.systemGrey,
          itemExtent: 40,
          changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
          selectionOverlayBuilder: overlay,
          height: 180,
        );
        return widget;
      });

      final picker = tester.widget<CupertinoTimerPicker>(
        find.byType(CupertinoTimerPicker),
      );
      expect(picker.mode, CupertinoTimerPickerMode.hm);
      expect(picker.minuteInterval, 5);
      expect(picker.alignment, Alignment.centerLeft);
      expect(picker.backgroundColor, CupertinoColors.systemGrey);
      expect(picker.itemExtent, 40);
      expect(
        picker.changeReportingBehavior,
        ChangeReportingBehavior.onScrollEnd,
      );
      expect(picker.selectionOverlayBuilder, same(overlay));
      expect(widget.alignment, Alignment.centerLeft);
      expect(widget.height, 180);
    });
  });
}

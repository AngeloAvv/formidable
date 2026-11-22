import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material slider bound to a numeric Field: `double`, `int` or `num`,
/// nullable or not.
///
/// The thumb rests at [min] while the Field is Unset, and the Field stays Unset
/// until the user moves it. A value outside [min] and [max] is shown at the
/// nearest end. On an `int` Field the thumb value is rounded.
///
/// The first interaction marks the Field touched, and the Validation Message
/// shows below the slider from then on.
///
/// The label above the thumb shows while the Field has a value, and needs
/// [divisions]. It is either the static [label] or, to follow the value,
/// whatever [labelBuilder] returns for it, as the Field has it.
///
/// It takes every parameter of [Slider] except the ones Formidable owns:
/// `value` and `onChanged` (the Field is the source of truth), and the
/// deprecated `year2023`. Each one is readable as a field of the widget.
/// [onChangeStart] and [onChangeEnd] receive the thumb value as the Slider
/// has it, a `double`. The Slider is disabled while the Field is.
class FormidableMaterialSlider<T extends num?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialSlider({
    super.key,
    required super.field,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.secondaryTrackValue,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.autofocus = false,
    this.allowedInteraction,
    this.padding,
    this.showValueIndicator,
    this.labelBuilder,
  }) : assert(
         label == null || labelBuilder == null,
         'Pass either label or labelBuilder, not both.',
       ),
       super(
         builder: (context, control) {
           final current = control.value?.toDouble();
           final value = (current == null ? min : current.clamp(min, max))
               .toDouble();
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Slider(
                 value: value,
                 label: current == null
                     ? null
                     : label ??
                           labelBuilder?.call(_toFieldType<T>(value) as num),
                 focusNode: control.focusNode,
                 onChanged: control.enabled
                     ? (next) =>
                           control.didChange(_toFieldType<T>(next), touched: true)
                     : null,
                 secondaryTrackValue: secondaryTrackValue,
                 onChangeStart: onChangeStart,
                 onChangeEnd: onChangeEnd,
                 min: min,
                 max: max,
                 divisions: divisions,
                 activeColor: activeColor,
                 inactiveColor: inactiveColor,
                 secondaryActiveColor: secondaryActiveColor,
                 thumbColor: thumbColor,
                 overlayColor: overlayColor,
                 mouseCursor: mouseCursor,
                 semanticFormatterCallback: semanticFormatterCallback,
                 autofocus: autofocus,
                 allowedInteraction: allowedInteraction,
                 padding: padding,
                 showValueIndicator: showValueIndicator,
               ),
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// See [Slider.secondaryTrackValue].
  final double? secondaryTrackValue;

  /// See [Slider.onChangeStart].
  final ValueChanged<double>? onChangeStart;

  /// See [Slider.onChangeEnd].
  final ValueChanged<double>? onChangeEnd;

  /// See [Slider.min].
  final double min;

  /// See [Slider.max].
  final double max;

  /// See [Slider.divisions].
  final int? divisions;

  /// See [Slider.label].
  final String? label;

  /// See [Slider.activeColor].
  final Color? activeColor;

  /// See [Slider.inactiveColor].
  final Color? inactiveColor;

  /// See [Slider.secondaryActiveColor].
  final Color? secondaryActiveColor;

  /// See [Slider.thumbColor].
  final Color? thumbColor;

  /// See [Slider.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [Slider.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [Slider.semanticFormatterCallback].
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// See [Slider.autofocus].
  final bool autofocus;

  /// See [Slider.allowedInteraction].
  final SliderInteraction? allowedInteraction;

  /// See [Slider.padding].
  final EdgeInsetsGeometry? padding;

  /// See [Slider.showValueIndicator].
  final ShowValueIndicator? showValueIndicator;

  /// Builds the label from the value of the Field, as the Field has it. Not
  /// together with [label].
  final String Function(num value)? labelBuilder;
}

/// The thumb value as the Field's type: a double stays one, anything else is
/// an `int` and is rounded.
T _toFieldType<T extends num?>(double next) =>
    (next is T ? next : next.round()) as T;

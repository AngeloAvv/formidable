import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart'
    show MaxLengthEnforcement, TextInputFormatter;
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'decoration.dart';
import 'style.dart';

/// A Material text field bound to a Field of type [T].
///
/// It shows the value, updates the Field as the user types, makes the Field
/// touched when it loses focus and shows the Validation Message in the
/// decoration once the Field is touched.
///
/// A Codec converts between [T] and the text. It is the [codec] of the widget,
/// else the one registered for [T] in the `FormidableConfig`, else a built-in
/// one: `String`, `int`, `double`, `num` and `DateTime`, also when nullable.
/// Blank text leaves the Field Unset. Text that can't be parsed stays visible
/// and makes the Field invalid with a parse error, even when it is optional.
///
/// It takes every parameter of [TextField] except the ones Formidable owns:
/// the controller (the Field is the source of truth), `enabled` (the Field
/// says it), `onChanged` and the deprecated parameters. Each one is readable
/// as a field of the widget. To react to what the user types, follow the Field
/// with a `FormidableFieldListener`.
///
/// The [decoration] is merged with what Formidable adds: it sets only
/// [InputDecoration.errorText], and only when your decoration has none, so a
/// custom `errorText` still wins. To build the decoration from the state of
/// the widget, pass a [decorationBuilder] instead (not both): it receives the
/// control, so the decoration can depend on the value, for example a button
/// that clears the field, shown only while there is text. Its result is merged
/// the same way. A null [decoration] draws no decoration, and so no Validation
/// Message either, like [TextField].
///
/// The [style] has a builder too: a [styleBuilder] receives the control and
/// returns the text style, so it can depend on the state of the Field, for
/// example red text while it has an error. It runs again whenever the Field
/// changes, and returning null gives the default style. Pass [style] or
/// [styleBuilder], not both.
///
/// The [textInputAction] defaults to "next" while another Field follows, and
/// to "done" on the last one. A multiline field keeps its newline key. Without
/// [onEditingComplete], pressing the action moves focus to the next Field in
/// Schema declaration order.
class FormidableMaterialTextField<T> extends FormidableTextFieldWidget<T> {
  FormidableMaterialTextField({
    super.key,
    required super.field,
    super.codec,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.groupId = EditableText,
    this.undoController,
    this.decoration = const InputDecoration(),
    this.decorationBuilder,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.styleBuilder,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.statesController,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectAllOnFocus,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.enableInlinePrediction,
    this.contextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.hintLocales,
  }) : assert(
         decorationBuilder == null ||
             identical(decoration, const InputDecoration()),
         'Pass either decoration or decorationBuilder, not both.',
       ),
       assert(
         style == null || styleBuilder == null,
         'Pass either style or styleBuilder, not both.',
       ),
       super(
         builder: (context, control) => TextField(
           groupId: groupId,
           controller: control.textController,
           focusNode: control.focusNode,
           undoController: undoController,
           decoration: decoration == null && decorationBuilder == null
               ? null
               : resolveInputDecoration(
                   context,
                   control,
                   decoration ?? const InputDecoration(),
                   decorationBuilder,
                 ),
           keyboardType: keyboardType,
           textInputAction:
               textInputAction ??
               (maxLines == 1 ? control.textInputAction : null),
           textCapitalization: textCapitalization,
           style: styleBuilder?.call(context, control) ?? style,
           strutStyle: strutStyle,
           textAlign: textAlign,
           textAlignVertical: textAlignVertical,
           textDirection: textDirection,
           readOnly: readOnly,
           showCursor: showCursor,
           autofocus: autofocus,
           statesController: statesController,
           obscuringCharacter: obscuringCharacter,
           obscureText: obscureText,
           autocorrect: autocorrect,
           smartDashesType: smartDashesType,
           smartQuotesType: smartQuotesType,
           enableSuggestions: enableSuggestions,
           maxLines: maxLines,
           minLines: minLines,
           expands: expands,
           maxLength: maxLength,
           maxLengthEnforcement: maxLengthEnforcement,
           onChanged: control.didChange,
           onEditingComplete: onEditingComplete ?? control.onEditingComplete,
           onSubmitted: onSubmitted,
           onAppPrivateCommand: onAppPrivateCommand,
           inputFormatters: inputFormatters,
           enabled: control.enabled,
           ignorePointers: ignorePointers,
           cursorWidth: cursorWidth,
           cursorHeight: cursorHeight,
           cursorRadius: cursorRadius,
           cursorOpacityAnimates: cursorOpacityAnimates,
           cursorColor: cursorColor,
           cursorErrorColor: cursorErrorColor,
           selectionHeightStyle: selectionHeightStyle,
           selectionWidthStyle: selectionWidthStyle,
           keyboardAppearance: keyboardAppearance,
           scrollPadding: scrollPadding,
           dragStartBehavior: dragStartBehavior,
           enableInteractiveSelection: enableInteractiveSelection,
           selectAllOnFocus: selectAllOnFocus,
           selectionControls: selectionControls,
           onTap: onTap,
           onTapAlwaysCalled: onTapAlwaysCalled,
           onTapOutside: onTapOutside,
           onTapUpOutside: onTapUpOutside,
           mouseCursor: mouseCursor,
           buildCounter: buildCounter,
           scrollController: scrollController,
           scrollPhysics: scrollPhysics,
           autofillHints: autofillHints,
           contentInsertionConfiguration: contentInsertionConfiguration,
           clipBehavior: clipBehavior,
           restorationId: restorationId,
           stylusHandwritingEnabled: stylusHandwritingEnabled,
           enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
           enableInlinePrediction: enableInlinePrediction,
           // Null keeps the menu of TextField; to remove it, build an empty one.
           contextMenuBuilder:
               contextMenuBuilder ?? const TextField().contextMenuBuilder,
           canRequestFocus: canRequestFocus,
           spellCheckConfiguration: spellCheckConfiguration,
           magnifierConfiguration: magnifierConfiguration,
           hintLocales: hintLocales,
         ),
       );

  /// See [TextField.groupId].
  final Object groupId;

  /// See [TextField.undoController].
  final UndoHistoryController? undoController;

  /// The decoration of the field. Formidable adds the Validation Message as
  /// its [InputDecoration.errorText] unless it has one. Null draws no
  /// decoration. Not together with [decorationBuilder].
  final InputDecoration? decoration;

  /// Builds the decoration from the control, so that it can depend on the
  /// value, the focus or the error. Merged like [decoration], which it
  /// replaces.
  final FormidableMaterialDecorationBuilder<T, String>? decorationBuilder;

  /// See [TextField.keyboardType].
  final TextInputType? keyboardType;

  /// The keyboard action. Null is "next" while another Field follows, and
  /// "done" on the last one. See [TextField.textInputAction].
  final TextInputAction? textInputAction;

  /// See [TextField.textCapitalization].
  final TextCapitalization textCapitalization;

  /// See [TextField.style]. Not together with [styleBuilder].
  final TextStyle? style;

  /// Builds the [style] from the control, so that it can depend on the value,
  /// the focus or the error. Replaces [style]; null gives the default style.
  final FormidableMaterialStyleBuilder<T, String>? styleBuilder;

  /// See [TextField.strutStyle].
  final StrutStyle? strutStyle;

  /// See [TextField.textAlign].
  final TextAlign textAlign;

  /// See [TextField.textAlignVertical].
  final TextAlignVertical? textAlignVertical;

  /// See [TextField.textDirection].
  final TextDirection? textDirection;

  /// See [TextField.readOnly].
  final bool readOnly;

  /// See [TextField.showCursor].
  final bool? showCursor;

  /// See [TextField.autofocus].
  final bool autofocus;

  /// See [TextField.statesController].
  final WidgetStatesController? statesController;

  /// See [TextField.obscuringCharacter].
  final String obscuringCharacter;

  /// See [TextField.obscureText].
  final bool obscureText;

  /// See [TextField.autocorrect].
  final bool? autocorrect;

  /// See [TextField.smartDashesType].
  final SmartDashesType? smartDashesType;

  /// See [TextField.smartQuotesType].
  final SmartQuotesType? smartQuotesType;

  /// See [TextField.enableSuggestions].
  final bool enableSuggestions;

  /// See [TextField.maxLines].
  final int? maxLines;

  /// See [TextField.minLines].
  final int? minLines;

  /// See [TextField.expands].
  final bool expands;

  /// See [TextField.maxLength].
  final int? maxLength;

  /// See [TextField.maxLengthEnforcement].
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Replaces the move to the next Field when the keyboard action is pressed.
  /// See [TextField.onEditingComplete].
  final VoidCallback? onEditingComplete;

  /// See [TextField.onSubmitted].
  final ValueChanged<String>? onSubmitted;

  /// See [TextField.onAppPrivateCommand].
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// See [TextField.inputFormatters].
  final List<TextInputFormatter>? inputFormatters;

  /// See [TextField.ignorePointers].
  final bool? ignorePointers;

  /// See [TextField.cursorWidth].
  final double cursorWidth;

  /// See [TextField.cursorHeight].
  final double? cursorHeight;

  /// See [TextField.cursorRadius].
  final Radius? cursorRadius;

  /// See [TextField.cursorOpacityAnimates].
  final bool? cursorOpacityAnimates;

  /// See [TextField.cursorColor].
  final Color? cursorColor;

  /// See [TextField.cursorErrorColor].
  final Color? cursorErrorColor;

  /// See [TextField.selectionHeightStyle].
  final ui.BoxHeightStyle? selectionHeightStyle;

  /// See [TextField.selectionWidthStyle].
  final ui.BoxWidthStyle? selectionWidthStyle;

  /// See [TextField.keyboardAppearance].
  final Brightness? keyboardAppearance;

  /// See [TextField.scrollPadding].
  final EdgeInsets scrollPadding;

  /// See [TextField.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [TextField.enableInteractiveSelection].
  final bool? enableInteractiveSelection;

  /// See [TextField.selectAllOnFocus].
  final bool? selectAllOnFocus;

  /// See [TextField.selectionControls].
  final TextSelectionControls? selectionControls;

  /// See [TextField.onTap].
  final GestureTapCallback? onTap;

  /// See [TextField.onTapAlwaysCalled].
  final bool onTapAlwaysCalled;

  /// See [TextField.onTapOutside].
  final TapRegionCallback? onTapOutside;

  /// See [TextField.onTapUpOutside].
  final TapRegionUpCallback? onTapUpOutside;

  /// See [TextField.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [TextField.buildCounter].
  final InputCounterWidgetBuilder? buildCounter;

  /// See [TextField.scrollController].
  final ScrollController? scrollController;

  /// See [TextField.scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// See [TextField.autofillHints].
  final Iterable<String>? autofillHints;

  /// See [TextField.contentInsertionConfiguration].
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// See [TextField.clipBehavior].
  final Clip clipBehavior;

  /// See [TextField.restorationId].
  final String? restorationId;

  /// See [TextField.stylusHandwritingEnabled].
  final bool stylusHandwritingEnabled;

  /// See [TextField.enableIMEPersonalizedLearning].
  final bool enableIMEPersonalizedLearning;

  /// See [TextField.enableInlinePrediction].
  final bool? enableInlinePrediction;

  /// Null keeps the menu of [TextField]. See [TextField.contextMenuBuilder].
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// See [TextField.canRequestFocus].
  final bool canRequestFocus;

  /// See [TextField.spellCheckConfiguration].
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// See [TextField.magnifierConfiguration].
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// See [TextField.hintLocales].
  final List<Locale>? hintLocales;
}

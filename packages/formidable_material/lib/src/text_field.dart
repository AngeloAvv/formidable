import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart'
    show MaxLengthEnforcement, TextInputFormatter;
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

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
/// says it), `onChanged` and the deprecated parameters. To react to what the
/// user types, follow the Field with a `FormidableFieldListener`.
///
/// The [decoration] is merged with what Formidable adds, there is no builder
/// for it. Formidable sets only [InputDecoration.errorText], and only when your
/// decoration has none, so a custom `errorText` still wins. For a decoration
/// that depends on the value, build the widget inside a
/// `FormidableFieldBuilder` or `FormidableFieldSelector`. A null [decoration]
/// draws no decoration, and so no Validation Message either, like [TextField].
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
    Object groupId = EditableText,
    UndoHistoryController? undoController,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    bool readOnly = false,
    bool? showCursor,
    bool autofocus = false,
    WidgetStatesController? statesController,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool? autocorrect,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    AppPrivateCommandCallback? onAppPrivateCommand,
    List<TextInputFormatter>? inputFormatters,
    bool? ignorePointers,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    bool? cursorOpacityAnimates,
    Color? cursorColor,
    Color? cursorErrorColor,
    ui.BoxHeightStyle? selectionHeightStyle,
    ui.BoxWidthStyle? selectionWidthStyle,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    bool? selectAllOnFocus,
    TextSelectionControls? selectionControls,
    GestureTapCallback? onTap,
    bool onTapAlwaysCalled = false,
    TapRegionCallback? onTapOutside,
    TapRegionUpCallback? onTapUpOutside,
    MouseCursor? mouseCursor,
    InputCounterWidgetBuilder? buildCounter,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints = const <String>[],
    ContentInsertionConfiguration? contentInsertionConfiguration,
    Clip clipBehavior = Clip.hardEdge,
    String? restorationId,
    bool stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    bool enableIMEPersonalizedLearning = true,
    bool? enableInlinePrediction,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    bool canRequestFocus = true,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
    List<Locale>? hintLocales,
  }) : super(
         builder: (context, control) => TextField(
           groupId: groupId,
           controller: control.textController,
           focusNode: control.focusNode,
           undoController: undoController,
           decoration: decoration?.copyWith(
             errorText: decoration.errorText ?? control.errorText,
           ),
           keyboardType: keyboardType,
           textInputAction:
               textInputAction ??
               (maxLines == 1 ? control.textInputAction : null),
           textCapitalization: textCapitalization,
           style: style,
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
}

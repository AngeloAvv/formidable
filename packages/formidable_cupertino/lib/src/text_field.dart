import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart'
    show MaxLengthEnforcement, TextInputFormatter;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino text field bound to a Field of type [T].
///
/// It shows the value, updates the Field as the user types, makes the Field
/// touched when it loses focus and shows the Validation Message under the
/// field once the Field is touched. Cupertino has no decoration for errors, so
/// the message is drawn by a [FormidableCupertinoErrorCaption].
///
/// A Codec converts between [T] and the text. It is the [codec] of the widget,
/// else the one registered for [T] in the `FormidableConfig`, else a built-in
/// one: `String`, `int`, `double`, `num` and `DateTime`, also when nullable.
/// Blank text leaves the Field Unset. Text that can't be parsed stays visible
/// and makes the Field invalid with a parse error, even when it is optional.
///
/// It takes every parameter of [CupertinoTextField] except the ones Formidable
/// owns: the controller (the Field is the source of truth), `enabled` (the
/// Field says it), `onChanged` and the deprecated parameters. To react to what
/// the user types, follow the Field with a `FormidableFieldListener`.
///
/// A null [decoration] gives the default rounded border of
/// [CupertinoTextField], and a null `contextMenuBuilder` its default menu; to
/// remove the box pass `const BoxDecoration()`.
///
/// The [textInputAction] defaults to "next" while another Field follows, and
/// to "done" on the last one. A multiline field keeps its newline key. Without
/// [onEditingComplete], pressing the action moves focus to the next Field in
/// Schema declaration order.
class FormidableCupertinoTextField<T> extends FormidableTextFieldWidget<T> {
  FormidableCupertinoTextField({
    super.key,
    required super.field,
    super.codec,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    Object groupId = EditableText,
    UndoHistoryController? undoController,
    BoxDecoration? decoration,
    EdgeInsetsGeometry padding = const EdgeInsets.all(7.0),
    String? placeholder,
    TextStyle? placeholderStyle,
    Widget? prefix,
    OverlayVisibilityMode prefixMode = OverlayVisibilityMode.always,
    Widget? suffix,
    OverlayVisibilityMode suffixMode = OverlayVisibilityMode.always,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    OverlayVisibilityMode clearButtonMode = OverlayVisibilityMode.never,
    String? clearButtonSemanticLabel,
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
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
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
    TapRegionCallback? onTapOutside,
    TapRegionCallback? onTapUpOutside,
    List<TextInputFormatter>? inputFormatters,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius cursorRadius = const Radius.circular(2.0),
    bool cursorOpacityAnimates = true,
    Color? cursorColor,
    ui.BoxHeightStyle? selectionHeightStyle,
    ui.BoxWidthStyle? selectionWidthStyle,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    bool? selectAllOnFocus,
    TextSelectionControls? selectionControls,
    GestureTapCallback? onTap,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints = const <String>[],
    ContentInsertionConfiguration? contentInsertionConfiguration,
    Clip clipBehavior = Clip.hardEdge,
    String? restorationId,
    bool stylusHandwritingEnabled = true,
    bool enableIMEPersonalizedLearning = true,
    bool? enableInlinePrediction,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
  }) : super(
         builder: (context, control) {
           const defaults = CupertinoTextField();
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: CupertinoTextField(
               groupId: groupId,
               controller: control.textController,
               focusNode: control.focusNode,
               undoController: undoController,
               decoration: decoration ?? defaults.decoration,
               padding: padding,
               placeholder: placeholder,
               placeholderStyle: placeholderStyle ?? defaults.placeholderStyle,
               prefix: prefix,
               prefixMode: prefixMode,
               suffix: suffix,
               suffixMode: suffixMode,
               crossAxisAlignment: crossAxisAlignment,
               clearButtonMode: clearButtonMode,
               clearButtonSemanticLabel: clearButtonSemanticLabel,
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
               onEditingComplete:
                   onEditingComplete ?? control.onEditingComplete,
               onSubmitted: onSubmitted,
               onTapOutside: onTapOutside,
               onTapUpOutside: onTapUpOutside,
               inputFormatters: inputFormatters,
               enabled: control.enabled,
               cursorWidth: cursorWidth,
               cursorHeight: cursorHeight,
               cursorRadius: cursorRadius,
               cursorOpacityAnimates: cursorOpacityAnimates,
               cursorColor: cursorColor,
               selectionHeightStyle: selectionHeightStyle,
               selectionWidthStyle: selectionWidthStyle,
               keyboardAppearance: keyboardAppearance,
               scrollPadding: scrollPadding,
               dragStartBehavior: dragStartBehavior,
               enableInteractiveSelection: enableInteractiveSelection,
               selectAllOnFocus: selectAllOnFocus,
               selectionControls: selectionControls,
               onTap: onTap,
               scrollController: scrollController,
               scrollPhysics: scrollPhysics,
               autofillHints: autofillHints,
               contentInsertionConfiguration: contentInsertionConfiguration,
               clipBehavior: clipBehavior,
               restorationId: restorationId,
               stylusHandwritingEnabled: stylusHandwritingEnabled,
               enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
               enableInlinePrediction: enableInlinePrediction,
               contextMenuBuilder:
                   contextMenuBuilder ?? defaults.contextMenuBuilder,
               spellCheckConfiguration: spellCheckConfiguration,
               magnifierConfiguration: magnifierConfiguration,
             ),
           );
         },
       );
}

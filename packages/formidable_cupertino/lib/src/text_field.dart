import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart'
    show MaxLengthEnforcement, TextInputFormatter;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// Builds the [BoxDecoration] of a [FormidableCupertinoTextField] from its
/// [control].
typedef FormidableCupertinoTextFieldDecorationBuilder<T> =
    BoxDecoration? Function(
      BuildContext context,
      FormidableFieldWidgetState<T, String> control,
    );

/// Builds a widget of a [FormidableCupertinoTextField], such as its prefix or
/// suffix, from its [control]. Null shows nothing.
typedef FormidableCupertinoTextFieldWidgetBuilder<T> = Widget? Function(
  BuildContext context,
  FormidableFieldWidgetState<T, String> control,
);

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
    this.groupId = EditableText,
    this.undoController,
    this.decoration,
    this.padding = const EdgeInsets.all(7.0),
    this.placeholder,
    this.placeholderStyle,
    this.prefix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.suffix,
    this.suffixMode = OverlayVisibilityMode.always,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.clearButtonMode = OverlayVisibilityMode.never,
    this.clearButtonSemanticLabel,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
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
    this.onTapOutside,
    this.onTapUpOutside,
    this.inputFormatters,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorOpacityAnimates = true,
    this.cursorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectAllOnFocus,
    this.selectionControls,
    this.onTap,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.stylusHandwritingEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.enableInlinePrediction,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.decorationBuilder,
    this.prefixBuilder,
    this.suffixBuilder,
  }) : assert(
         decoration == null || decorationBuilder == null,
         'Pass either decoration or decorationBuilder, not both.',
       ),
       assert(
         prefix == null || prefixBuilder == null,
         'Pass either prefix or prefixBuilder, not both.',
       ),
       assert(
         suffix == null || suffixBuilder == null,
         'Pass either suffix or suffixBuilder, not both.',
       ),
       super(
         builder: (context, control) {
           const defaults = CupertinoTextField();
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: CupertinoTextField(
               groupId: groupId,
               controller: control.textController,
               focusNode: control.focusNode,
               undoController: undoController,
               decoration:
                   decorationBuilder?.call(context, control) ??
                   decoration ??
                   defaults.decoration,
               padding: padding,
               placeholder: placeholder,
               placeholderStyle: placeholderStyle ?? defaults.placeholderStyle,
               prefix: prefixBuilder?.call(context, control) ?? prefix,
               prefixMode: prefixMode,
               suffix: suffixBuilder?.call(context, control) ?? suffix,
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

  /// See [CupertinoTextField.groupId].
  final Object groupId;

  /// See [CupertinoTextField.undoController].
  final UndoHistoryController? undoController;

  /// See [CupertinoTextField.decoration].
  final BoxDecoration? decoration;

  /// See [CupertinoTextField.padding].
  final EdgeInsetsGeometry padding;

  /// See [CupertinoTextField.placeholder].
  final String? placeholder;

  /// See [CupertinoTextField.placeholderStyle].
  final TextStyle? placeholderStyle;

  /// See [CupertinoTextField.prefix].
  final Widget? prefix;

  /// See [CupertinoTextField.prefixMode].
  final OverlayVisibilityMode prefixMode;

  /// See [CupertinoTextField.suffix].
  final Widget? suffix;

  /// See [CupertinoTextField.suffixMode].
  final OverlayVisibilityMode suffixMode;

  /// See [CupertinoTextField.crossAxisAlignment].
  final CrossAxisAlignment crossAxisAlignment;

  /// See [CupertinoTextField.clearButtonMode].
  final OverlayVisibilityMode clearButtonMode;

  /// See [CupertinoTextField.clearButtonSemanticLabel].
  final String? clearButtonSemanticLabel;

  /// See [CupertinoTextField.keyboardType].
  final TextInputType? keyboardType;

  /// See [CupertinoTextField.textInputAction].
  final TextInputAction? textInputAction;

  /// See [CupertinoTextField.textCapitalization].
  final TextCapitalization textCapitalization;

  /// See [CupertinoTextField.style].
  final TextStyle? style;

  /// See [CupertinoTextField.strutStyle].
  final StrutStyle? strutStyle;

  /// See [CupertinoTextField.textAlign].
  final TextAlign textAlign;

  /// See [CupertinoTextField.textAlignVertical].
  final TextAlignVertical? textAlignVertical;

  /// See [CupertinoTextField.textDirection].
  final TextDirection? textDirection;

  /// See [CupertinoTextField.readOnly].
  final bool readOnly;

  /// See [CupertinoTextField.showCursor].
  final bool? showCursor;

  /// See [CupertinoTextField.autofocus].
  final bool autofocus;

  /// See [CupertinoTextField.obscuringCharacter].
  final String obscuringCharacter;

  /// See [CupertinoTextField.obscureText].
  final bool obscureText;

  /// See [CupertinoTextField.autocorrect].
  final bool autocorrect;

  /// See [CupertinoTextField.smartDashesType].
  final SmartDashesType? smartDashesType;

  /// See [CupertinoTextField.smartQuotesType].
  final SmartQuotesType? smartQuotesType;

  /// See [CupertinoTextField.enableSuggestions].
  final bool enableSuggestions;

  /// See [CupertinoTextField.maxLines].
  final int? maxLines;

  /// See [CupertinoTextField.minLines].
  final int? minLines;

  /// See [CupertinoTextField.expands].
  final bool expands;

  /// See [CupertinoTextField.maxLength].
  final int? maxLength;

  /// See [CupertinoTextField.maxLengthEnforcement].
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// See [CupertinoTextField.onEditingComplete].
  final VoidCallback? onEditingComplete;

  /// See [CupertinoTextField.onSubmitted].
  final ValueChanged<String>? onSubmitted;

  /// See [CupertinoTextField.onTapOutside].
  final TapRegionCallback? onTapOutside;

  /// See [CupertinoTextField.onTapUpOutside].
  final TapRegionCallback? onTapUpOutside;

  /// See [CupertinoTextField.inputFormatters].
  final List<TextInputFormatter>? inputFormatters;

  /// See [CupertinoTextField.cursorWidth].
  final double cursorWidth;

  /// See [CupertinoTextField.cursorHeight].
  final double? cursorHeight;

  /// See [CupertinoTextField.cursorRadius].
  final Radius cursorRadius;

  /// See [CupertinoTextField.cursorOpacityAnimates].
  final bool cursorOpacityAnimates;

  /// See [CupertinoTextField.cursorColor].
  final Color? cursorColor;

  /// See [CupertinoTextField.selectionHeightStyle].
  final ui.BoxHeightStyle? selectionHeightStyle;

  /// See [CupertinoTextField.selectionWidthStyle].
  final ui.BoxWidthStyle? selectionWidthStyle;

  /// See [CupertinoTextField.keyboardAppearance].
  final Brightness? keyboardAppearance;

  /// See [CupertinoTextField.scrollPadding].
  final EdgeInsets scrollPadding;

  /// See [CupertinoTextField.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [CupertinoTextField.enableInteractiveSelection].
  final bool? enableInteractiveSelection;

  /// See [CupertinoTextField.selectAllOnFocus].
  final bool? selectAllOnFocus;

  /// See [CupertinoTextField.selectionControls].
  final TextSelectionControls? selectionControls;

  /// See [CupertinoTextField.onTap].
  final GestureTapCallback? onTap;

  /// See [CupertinoTextField.scrollController].
  final ScrollController? scrollController;

  /// See [CupertinoTextField.scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// See [CupertinoTextField.autofillHints].
  final Iterable<String>? autofillHints;

  /// See [CupertinoTextField.contentInsertionConfiguration].
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// See [CupertinoTextField.clipBehavior].
  final Clip clipBehavior;

  /// See [CupertinoTextField.restorationId].
  final String? restorationId;

  /// See [CupertinoTextField.stylusHandwritingEnabled].
  final bool stylusHandwritingEnabled;

  /// See [CupertinoTextField.enableIMEPersonalizedLearning].
  final bool enableIMEPersonalizedLearning;

  /// See [CupertinoTextField.enableInlinePrediction].
  final bool? enableInlinePrediction;

  /// See [CupertinoTextField.contextMenuBuilder].
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// See [CupertinoTextField.spellCheckConfiguration].
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// See [CupertinoTextField.magnifierConfiguration].
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Builds the [decoration] from the control, to follow the state of the
  /// Field (the error, the value). Replaces [decoration]; pass one or the
  /// other. Returning null gives the default of [CupertinoTextField].
  final FormidableCupertinoTextFieldDecorationBuilder<T>? decorationBuilder;

  /// Builds the [prefix] from the control, for a widget that depends on the
  /// value. Replaces [prefix]; pass one or the other. Returning null shows no
  /// prefix.
  final FormidableCupertinoTextFieldWidgetBuilder<T>? prefixBuilder;

  /// Builds the [suffix] from the control, for a widget that depends on the
  /// value, such as a clear button shown once there is text. Replaces
  /// [suffix]; pass one or the other. Returning null shows no suffix.
  final FormidableCupertinoTextFieldWidgetBuilder<T>? suffixBuilder;
}

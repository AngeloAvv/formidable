import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'messages.dart';

/// App-wide configuration of Formidable.
///
/// Place it above the widgets that show Fields, usually around the app. It is
/// an inherited dependency: when the config changes, the widgets that read it
/// rebuild.
///
/// Create the [messages] once and keep them (as a constant or a field), as a
/// new registry is a change even when it holds the same messages.
class FormidableConfig extends InheritedWidget {
  const FormidableConfig({
    super.key,
    this.messages = const FormidableMessages(),
    this.codecs = FormidableCodecs.defaults,
    required super.child,
  });

  /// The messages for custom errors, or for built-in errors whose wording
  /// should differ from the localizations.
  final FormidableMessages messages;

  /// The Codecs widgets pick from, by the type of the Field and the type the
  /// widget shows. Extend the built-in ones with
  /// `FormidableCodecs.defaults.add(codec)`. Two registries with the same
  /// Codecs are equal, so rebuilding the config does not notify.
  final FormidableCodecs codecs;

  /// The nearest config, or null when there is none.
  static FormidableConfig? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormidableConfig>();

  /// The nearest config, or throws when there is none.
  static FormidableConfig of(BuildContext context) {
    final config = maybeOf(context);
    if (config == null) {
      throw FlutterError(
        'No FormidableConfig found in the widget tree.\n'
        'Wrap the app in a FormidableConfig.',
      );
    }
    return config;
  }

  @override
  bool updateShouldNotify(FormidableConfig oldWidget) =>
      messages != oldWidget.messages || codecs != oldWidget.codecs;
}

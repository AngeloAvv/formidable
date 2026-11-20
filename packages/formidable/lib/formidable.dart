/// Pure Dart core of Formidable: annotations, runtime, Validators and
/// Validation Errors. It has no Flutter dependency.
library;

export 'src/annotations/formidable.dart';
export 'src/annotations/passthrough.dart';
export 'src/annotations/required.dart';
export 'src/codecs/codec.dart';
export 'src/codecs/codecs.dart';
export 'src/codecs/parse_error.dart';
export 'src/codecs/parse_result.dart';
export 'src/codecs/text_codecs.dart';
export 'src/runtime/field.dart';
export 'src/runtime/field_state.dart';
export 'src/runtime/form.dart';
export 'src/runtime/form_state.dart';
export 'src/runtime/node.dart';
export 'src/runtime/passthrough.dart';
export 'src/runtime/notifier.dart';
export 'src/runtime/status.dart';
export 'src/runtime/submit_result.dart';
export 'src/validation/required_error.dart';
export 'src/validation/validation_error.dart';
export 'src/validation/validator.dart';
export 'src/validators/min_length.dart';

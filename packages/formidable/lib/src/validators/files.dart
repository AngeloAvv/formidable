import '../files/file.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The file is smaller than the minimum size.
final class FormidableMinFileSizeError extends FormidableValidationError {
  const FormidableMinFileSizeError({
    required this.minBytes,
    required this.actualBytes,
  });

  final int minBytes;
  final int actualBytes;

  @override
  List<Object?> get props => [minBytes, actualBytes];

  @override
  String toString() =>
      'Must be at least $minBytes bytes (got $actualBytes bytes).';
}

/// The file has at least [bytes] bytes.
class MinFileSize extends FormidableValidator<FormidableFile> {
  const MinFileSize(this.bytes);

  final int bytes;

  @override
  List<FormidableValidationError> validate(FormidableFile value) =>
      value.size < bytes
      ? [FormidableMinFileSizeError(minBytes: bytes, actualBytes: value.size)]
      : const [];
}

/// The file is larger than the maximum size.
final class FormidableMaxFileSizeError extends FormidableValidationError {
  const FormidableMaxFileSizeError({
    required this.maxBytes,
    required this.actualBytes,
  });

  final int maxBytes;
  final int actualBytes;

  @override
  List<Object?> get props => [maxBytes, actualBytes];

  @override
  String toString() =>
      'Must be at most $maxBytes bytes (got $actualBytes bytes).';
}

/// The file has at most [bytes] bytes.
class MaxFileSize extends FormidableValidator<FormidableFile> {
  const MaxFileSize(this.bytes);

  final int bytes;

  @override
  List<FormidableValidationError> validate(FormidableFile value) =>
      value.size > bytes
      ? [FormidableMaxFileSizeError(maxBytes: bytes, actualBytes: value.size)]
      : const [];
}

/// The file extension is not one of the allowed ones.
final class FormidableFileExtensionError extends FormidableValidationError {
  const FormidableFileExtensionError({
    required this.allowed,
    required this.actual,
  });

  /// The allowed extensions, lower case and without the dot.
  final List<String> allowed;

  /// The extension of the file, or null when it has none.
  final String? actual;

  @override
  List<Object?> get props => [actual, ...allowed];

  @override
  String toString() => 'The file type must be ${allowed.join(', ')}.';
}

/// The file has one of the allowed extensions.
///
/// Extensions are compared without regard to case, and may be written with or
/// without the leading dot.
class FileExtension extends FormidableValidator<FormidableFile> {
  const FileExtension(this.extensions);

  final List<String> extensions;

  @override
  List<FormidableValidationError> validate(FormidableFile value) {
    final allowed = [
      for (final extension in extensions)
        (extension.startsWith('.') ? extension.substring(1) : extension)
            .toLowerCase(),
    ];
    final actual = value.extension;
    return actual != null && allowed.contains(actual)
        ? const []
        : [FormidableFileExtensionError(allowed: allowed, actual: actual)];
  }
}

/// The MIME type of the file is not one of the allowed ones.
final class FormidableMimeTypeError extends FormidableValidationError {
  const FormidableMimeTypeError({required this.allowed, required this.actual});

  /// The allowed MIME types.
  final List<String> allowed;

  /// The MIME type of the file, or null when it is unknown.
  final String? actual;

  @override
  List<Object?> get props => [actual, ...allowed];

  @override
  String toString() => 'The file type must be ${allowed.join(', ')}.';
}

/// The MIME type of the file is one of [types].
///
/// A type such as `image/*` allows every subtype. Types are compared without
/// regard to case. A file whose MIME type is unknown never matches.
class MimeType extends FormidableValidator<FormidableFile> {
  const MimeType(this.types);

  final List<String> types;

  @override
  List<FormidableValidationError> validate(FormidableFile value) {
    final actual = value.mimeType;
    if (actual != null) {
      final lower = actual.toLowerCase();
      for (final type in types) {
        final allowed = type.toLowerCase();
        if (allowed == lower ||
            (allowed.endsWith('/*') &&
                lower.startsWith(allowed.substring(0, allowed.length - 1)))) {
          return const [];
        }
      }
    }
    return [FormidableMimeTypeError(allowed: types, actual: actual)];
  }
}

/// The file is not an image.
final class FormidableImageFileError extends FormidableValidationError {
  const FormidableImageFileError();

  @override
  String toString() => 'Must be an image.';
}

const _imageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'bmp',
  'svg',
  'heic',
  'heif',
  'avif',
  'tif',
  'tiff',
  'ico',
};

/// The file is an image.
///
/// The MIME type decides when the file has one. Otherwise the extension does.
class ImageFile extends FormidableValidator<FormidableFile> {
  const ImageFile();

  @override
  List<FormidableValidationError> validate(FormidableFile value) {
    final mimeType = value.mimeType;
    final isImage = mimeType != null
        ? mimeType.toLowerCase().startsWith('image/')
        : _imageExtensions.contains(value.extension);
    return isImage ? const [] : const [FormidableImageFileError()];
  }
}

/// The name of the file is not a valid file name.
final class FormidableFileNameError extends FormidableValidationError {
  const FormidableFileNameError({required this.maxLength});

  /// The longest name the Validator allows.
  final int maxLength;

  @override
  List<Object?> get props => [maxLength];

  @override
  String toString() =>
      'Must be a valid file name of at most $maxLength characters.';
}

final _forbiddenInFileName = RegExp(r'[\u0000-\u001F<>:"/\\|?*]');

/// The name of the file works on every common file system: it is not empty or
/// longer than [maxLength], has no path separator, control or reserved
/// character (`< > : " / \ | ? *`), is not `.` or `..`, and does not end with a
/// space or a dot.
class FileName extends FormidableValidator<FormidableFile> {
  const FileName({this.maxLength = 255});

  final int maxLength;

  @override
  List<FormidableValidationError> validate(FormidableFile value) {
    final name = value.name;
    final valid =
        name.isNotEmpty &&
        name.length <= maxLength &&
        name != '.' &&
        name != '..' &&
        !name.endsWith(' ') &&
        !name.endsWith('.') &&
        !_forbiddenInFileName.hasMatch(name);
    return valid ? const [] : [FormidableFileNameError(maxLength: maxLength)];
  }
}

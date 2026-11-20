import 'package:formidable/formidable.dart';

/// Messages for the errors of the file Validators.
abstract mixin class FormidableFileMessages {
  /// The file is smaller than [minBytes].
  String minFileSize(int minBytes, int actualBytes);

  /// The file is larger than [maxBytes].
  String maxFileSize(int maxBytes, int actualBytes);

  /// The extension [actual] (null when there is none) is not one of [allowed].
  String fileExtension(List<String> allowed, String? actual);

  /// The MIME type [actual] (null when unknown) is not one of [allowed].
  String mimeType(List<String> allowed, String? actual);

  /// The file is not an image.
  String imageFile();

  /// The file name is not valid or longer than [maxLength].
  String fileName(int maxLength);

  /// The message for a file error, or null for any other error.
  String? fileMessageOf(FormidableValidationError error) => switch (error) {
    FormidableMinFileSizeError(:final minBytes, :final actualBytes) =>
      minFileSize(minBytes, actualBytes),
    FormidableMaxFileSizeError(:final maxBytes, :final actualBytes) =>
      maxFileSize(maxBytes, actualBytes),
    FormidableFileExtensionError(:final allowed, :final actual) =>
      fileExtension(allowed, actual),
    FormidableMimeTypeError(:final allowed, :final actual) => mimeType(
      allowed,
      actual,
    ),
    FormidableImageFileError() => imageFile(),
    FormidableFileNameError(:final maxLength) => fileName(maxLength),
    _ => null,
  };
}

/// A size in bytes written for people, such as `5 MB` or `1.5 KB`, using
/// [decimal] as the decimal separator.
String _fileSize(int bytes, {String decimal = '.'}) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  final text = size == size.roundToDouble()
      ? size.round().toString()
      : size.toStringAsFixed(1).replaceFirst('.', decimal);
  return '$text ${units[unit]}';
}

String _extensions(List<String> allowed) =>
    allowed.map((extension) => '.$extension').join(', ');

const _forbiddenCharacters = r'/ \ : * ? " < > |';

mixin FormidableFileMessagesEn implements FormidableFileMessages {
  @override
  String minFileSize(int minBytes, int actualBytes) =>
      'The file must be at least ${_fileSize(minBytes)} '
      '(it is ${_fileSize(actualBytes)}).';

  @override
  String maxFileSize(int maxBytes, int actualBytes) =>
      'The file must be at most ${_fileSize(maxBytes)} '
      '(it is ${_fileSize(actualBytes)}).';

  @override
  String fileExtension(List<String> allowed, String? actual) =>
      'The file must be one of these types: ${_extensions(allowed)}.';

  @override
  String mimeType(List<String> allowed, String? actual) =>
      'The file type must be one of: ${allowed.join(', ')}.';

  @override
  String imageFile() => 'The file must be an image.';

  @override
  String fileName(int maxLength) =>
      'The file name is not valid (at most $maxLength characters, '
      'without $_forbiddenCharacters).';
}

mixin FormidableFileMessagesIt implements FormidableFileMessages {
  @override
  String minFileSize(int minBytes, int actualBytes) =>
      'Il file deve essere di almeno '
      '${_fileSize(minBytes, decimal: ',')} '
      '(è ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String maxFileSize(int maxBytes, int actualBytes) =>
      'Il file deve essere al massimo '
      '${_fileSize(maxBytes, decimal: ',')} '
      '(è ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String fileExtension(List<String> allowed, String? actual) =>
      'Il file deve essere di uno di questi tipi: ${_extensions(allowed)}.';

  @override
  String mimeType(List<String> allowed, String? actual) =>
      'Il tipo del file deve essere uno tra: ${allowed.join(', ')}.';

  @override
  String imageFile() => "Il file deve essere un'immagine.";

  @override
  String fileName(int maxLength) =>
      'Il nome del file non è valido (massimo $maxLength caratteri, '
      'senza $_forbiddenCharacters).';
}

mixin FormidableFileMessagesEs implements FormidableFileMessages {
  @override
  String minFileSize(int minBytes, int actualBytes) =>
      'El archivo debe pesar al menos '
      '${_fileSize(minBytes, decimal: ',')} '
      '(pesa ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String maxFileSize(int maxBytes, int actualBytes) =>
      'El archivo debe pesar como máximo '
      '${_fileSize(maxBytes, decimal: ',')} '
      '(pesa ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String fileExtension(List<String> allowed, String? actual) =>
      'El archivo debe ser de uno de estos tipos: ${_extensions(allowed)}.';

  @override
  String mimeType(List<String> allowed, String? actual) =>
      'El tipo de archivo debe ser uno de: ${allowed.join(', ')}.';

  @override
  String imageFile() => 'El archivo debe ser una imagen.';

  @override
  String fileName(int maxLength) =>
      'El nombre del archivo no es válido (máximo $maxLength caracteres, '
      'sin $_forbiddenCharacters).';
}

mixin FormidableFileMessagesFr implements FormidableFileMessages {
  @override
  String minFileSize(int minBytes, int actualBytes) =>
      'Le fichier doit faire au moins '
      '${_fileSize(minBytes, decimal: ',')} '
      '(il fait ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String maxFileSize(int maxBytes, int actualBytes) =>
      'Le fichier doit faire au plus '
      '${_fileSize(maxBytes, decimal: ',')} '
      '(il fait ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String fileExtension(List<String> allowed, String? actual) =>
      "Le fichier doit être de l'un de ces types : ${_extensions(allowed)}.";

  @override
  String mimeType(List<String> allowed, String? actual) =>
      "Le type du fichier doit être l'un de : ${allowed.join(', ')}.";

  @override
  String imageFile() => 'Le fichier doit être une image.';

  @override
  String fileName(int maxLength) =>
      "Le nom du fichier n'est pas valide (au maximum $maxLength caractères, "
      'sans $_forbiddenCharacters).';
}

mixin FormidableFileMessagesDe implements FormidableFileMessages {
  @override
  String minFileSize(int minBytes, int actualBytes) =>
      'Die Datei muss mindestens '
      '${_fileSize(minBytes, decimal: ',')} groß sein '
      '(aktuell ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String maxFileSize(int maxBytes, int actualBytes) =>
      'Die Datei darf höchstens '
      '${_fileSize(maxBytes, decimal: ',')} groß sein '
      '(aktuell ${_fileSize(actualBytes, decimal: ',')}).';

  @override
  String fileExtension(List<String> allowed, String? actual) =>
      'Die Datei muss einen dieser Typen haben: ${_extensions(allowed)}.';

  @override
  String mimeType(List<String> allowed, String? actual) =>
      'Der Dateityp muss einer von diesen sein: ${allowed.join(', ')}.';

  @override
  String imageFile() => 'Die Datei muss ein Bild sein.';

  @override
  String fileName(int maxLength) =>
      'Der Dateiname ist ungültig (höchstens $maxLength Zeichen, '
      'ohne $_forbiddenCharacters).';
}

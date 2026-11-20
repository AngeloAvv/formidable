/// A file chosen by the user, as far as a Validator needs to know about it.
///
/// It describes the file and does not hold its bytes, so a Field of this type
/// stays cheap to compare and copy. A file picker adapts its own type to this
/// one.
final class FormidableFile {
  const FormidableFile({
    required this.name,
    required this.size,
    this.mimeType,
    this.path,
  });

  /// The name of the file, with its extension and without any directory.
  final String name;

  /// The size in bytes.
  final int size;

  /// The MIME type, for example `image/png`, or null when the source does not
  /// know it.
  final String? mimeType;

  /// Where the file is, or null when it has no path (the web).
  final String? path;

  /// The extension of [name], in lower case and without the dot, or null when
  /// the name has none. A name that only starts with a dot, such as
  /// `.gitignore`, has no extension.
  String? get extension {
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return null;
    return name.substring(dot + 1).toLowerCase();
  }

  @override
  bool operator ==(Object other) =>
      other is FormidableFile &&
      other.name == name &&
      other.size == size &&
      other.mimeType == mimeType &&
      other.path == path;

  @override
  int get hashCode => Object.hash(name, size, mimeType, path);

  @override
  String toString() => 'FormidableFile($name, $size bytes)';
}

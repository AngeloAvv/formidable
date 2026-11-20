import 'package:formidable/formidable.dart';

part 'catalog_files.formidable.dart';

/// One Field per file Validator of the built-in catalog.
@Formidable()
class Upload {
  const Upload({
    required this.atLeast,
    required this.atMost,
    required this.document,
    required this.media,
    required this.photo,
    required this.named,
  });

  @MinFileSize(10)
  final FormidableFile atLeast;

  @MaxFileSize(1000)
  final FormidableFile atMost;

  @FileExtension(['pdf', '.docx'])
  final FormidableFile document;

  @MimeType(['application/pdf', 'image/*'])
  final FormidableFile media;

  @ImageFile()
  final FormidableFile photo;

  @FileName(maxLength: 20)
  final FormidableFile named;
}

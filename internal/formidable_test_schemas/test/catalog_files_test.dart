import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/catalog_files.dart';
import 'package:test/test.dart';

/// Seam 1: the file Validators of the built-in catalog, on the file value type
/// defined by the core.
void main() {
  UploadForm form() => UploadForm();

  FormidableFile file(String name, {int size = 100, String? mimeType}) =>
      FormidableFile(name: name, size: size, mimeType: mimeType);

  group('FormidableFile', () {
    test('has value equality', () {
      expect(
        file('a.txt', mimeType: 'text/plain'),
        file('a.txt', mimeType: 'text/plain'),
      );
      expect(file('a.txt'), isNot(file('b.txt')));
      expect(file('a.txt').hashCode, file('a.txt').hashCode);
    });

    test('reads the extension of its name, lowercased and without the dot', () {
      expect(file('Report.final.PDF').extension, 'pdf');
      expect(file('README').extension, isNull);
      expect(file('.gitignore').extension, isNull);
      expect(file('trailing.').extension, isNull);
    });
  });

  group('MinFileSize', () {
    test('rejects a file below the minimum and reports both sizes', () {
      final f = form()..atLeast.setValue(file('a', size: 4));

      expect(f.atLeast.state.errors, [
        const FormidableMinFileSizeError(minBytes: 10, actualBytes: 4),
      ]);
    });

    test('accepts a file at or above the minimum', () {
      final f = form()..atLeast.setValue(file('a', size: 10));

      expect(f.atLeast.state.errors, isEmpty);
    });
  });

  group('MaxFileSize', () {
    test('rejects a file above the maximum and reports both sizes', () {
      final f = form()..atMost.setValue(file('a', size: 1001));

      expect(f.atMost.state.errors, [
        const FormidableMaxFileSizeError(maxBytes: 1000, actualBytes: 1001),
      ]);
    });

    test('accepts a file at or below the maximum', () {
      final f = form()..atMost.setValue(file('a', size: 1000));

      expect(f.atMost.state.errors, isEmpty);
    });
  });

  group('FileExtension', () {
    test('accepts an allowed extension in any case, with or without a dot', () {
      final f = form();
      for (final name in ['a.pdf', 'a.PDF', 'a.docx', 'a.b.Docx']) {
        f.document.setValue(file(name));
        expect(f.document.state.errors, isEmpty, reason: name);
      }
    });

    test('rejects any other extension and a missing one', () {
      final f = form()..document.setValue(file('a.png'));
      expect(f.document.state.errors, [
        const FormidableFileExtensionError(
          allowed: ['pdf', 'docx'],
          actual: 'png',
        ),
      ]);

      f.document.setValue(file('README'));
      expect(f.document.state.errors, [
        const FormidableFileExtensionError(
          allowed: ['pdf', 'docx'],
          actual: null,
        ),
      ]);
    });
  });

  group('MimeType', () {
    test('accepts an exact type and a wildcard subtype, ignoring case', () {
      final f = form();
      for (final type in ['application/pdf', 'Application/PDF', 'image/png']) {
        f.media.setValue(file('a', mimeType: type));
        expect(f.media.state.errors, isEmpty, reason: type);
      }
    });

    test('rejects other types and an unknown one', () {
      final f = form()..media.setValue(file('a', mimeType: 'text/plain'));
      expect(f.media.state.errors, [
        const FormidableMimeTypeError(
          allowed: ['application/pdf', 'image/*'],
          actual: 'text/plain',
        ),
      ]);

      f.media.setValue(file('a'));
      expect(f.media.state.errors, [
        const FormidableMimeTypeError(
          allowed: ['application/pdf', 'image/*'],
          actual: null,
        ),
      ]);
    });

    test('does not let a wildcard match a longer type name', () {
      expect(
        const MimeType(['image/*']).validate(file('a', mimeType: 'imagery/x')),
        isNotEmpty,
      );
    });
  });

  group('ImageFile', () {
    test('accepts an image by its MIME type', () {
      final f = form()..photo.setValue(file('a.bin', mimeType: 'image/webp'));

      expect(f.photo.state.errors, isEmpty);
    });

    test('falls back to the extension when the MIME type is unknown', () {
      final f = form()..photo.setValue(file('holiday.JPG'));

      expect(f.photo.state.errors, isEmpty);
    });

    test('rejects other files, trusting the MIME type over the name', () {
      final f = form()..photo.setValue(file('a.txt', mimeType: 'text/plain'));
      expect(f.photo.state.errors, [const FormidableImageFileError()]);

      f.photo.setValue(file('a.png', mimeType: 'application/pdf'));
      expect(f.photo.state.errors, [const FormidableImageFileError()]);

      f.photo.setValue(file('a.txt'));
      expect(f.photo.state.errors, [const FormidableImageFileError()]);
    });
  });

  group('FileName', () {
    test('accepts a plain name', () {
      final f = form()..named.setValue(file('my report (1).pdf'));

      expect(f.named.state.errors, isEmpty);
    });

    test('rejects separators, reserved characters and dot names', () {
      final f = form();
      for (final name in [
        'a/b.txt',
        r'a\b.txt',
        'a:b',
        'a*b',
        'a?b',
        'a"b',
        'a<b>',
        'a|b',
        'a\u0000b',
        '',
        '.',
        '..',
        'trailing ',
        'trailing.',
      ]) {
        f.named.setValue(file(name));
        expect(f.named.state.errors, [
          const FormidableFileNameError(maxLength: 20),
        ], reason: 'name: "$name"');
      }
    });

    test('rejects a name longer than the maximum', () {
      final f = form()..named.setValue(file('${'a' * 21}.txt'));

      expect(f.named.state.errors, [
        const FormidableFileNameError(maxLength: 20),
      ]);
    });

    test('allows 255 characters by default', () {
      expect(const FileName().validate(file('a' * 255)), isEmpty);
      expect(const FileName().validate(file('a' * 256)), isNotEmpty);
    });
  });
}

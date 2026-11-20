import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Dart snippet of the guides is an excerpt of the example app, which
/// compiles and is tested. A snippet names its source in its first line
/// (`// example/lib/...`) and `// ...` separates the excerpts. This test fails
/// when a snippet drifts from the source it claims to mirror.
void main() {
  final guides = Directory('../docs/guides')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.mdx'))
      .toList();

  test('there is a guide for every flow of the example app', () {
    final names = guides.map((file) => file.uri.pathSegments.last).toSet();
    expect(
      names,
      containsAll([
        'index.mdx',
        'sign-up.mdx',
        'submit-patterns.mdx',
        'edit-form.mdx',
        'dynamic-lists.mdx',
        'wizard.mdx',
        'questionnaire.mdx',
      ]),
    );
  });

  for (final guide in guides) {
    final name = guide.uri.pathSegments.last;
    final snippets = _dartSnippets(guide.readAsStringSync());

    test('the snippets of $name mirror the example app', () {
      for (final snippet in snippets) {
        final source = _normalize(File('../${snippet.path}').readAsLinesSync());
        for (final excerpt in snippet.excerpts) {
          expect(
            _contains(source, _normalize(excerpt)),
            isTrue,
            reason:
                '$name: not found in ${snippet.path}:\n${excerpt.join('\n')}',
          );
        }
      }
    });
  }
}

class _Snippet {
  _Snippet(this.path, this.excerpts);

  final String path;
  final List<List<String>> excerpts;
}

final _fence = RegExp(
  r'^```dart\n(// example/lib/\S+)\n(.*?)^```',
  multiLine: true,
  dotAll: true,
);

List<_Snippet> _dartSnippets(String mdx) => [
  for (final match in _fence.allMatches(mdx))
    _Snippet(match.group(1)!.substring(3), _split(match.group(2)!.split('\n'))),
];

/// Splits at the `// ...` lines.
List<List<String>> _split(List<String> lines) {
  final excerpts = <List<String>>[[]];
  for (final line in lines) {
    if (line.trim() == '// ...') {
      excerpts.add([]);
    } else {
      excerpts.last.add(line);
    }
  }
  return excerpts
      .where((excerpt) => excerpt.any((l) => l.trim().isNotEmpty))
      .toList();
}

/// Trimmed, without blank lines: indentation changes when an excerpt is
/// dedented, and formatting of blank lines is irrelevant.
List<String> _normalize(List<String> lines) => [
  for (final line in lines)
    if (line.trim().isNotEmpty) line.trim(),
];

bool _contains(List<String> source, List<String> excerpt) {
  for (var i = 0; i + excerpt.length <= source.length; i++) {
    var same = true;
    for (var j = 0; j < excerpt.length && same; j++) {
      same = source[i + j] == excerpt[j];
    }
    if (same) return true;
  }
  return false;
}

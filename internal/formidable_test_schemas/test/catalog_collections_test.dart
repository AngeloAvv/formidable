import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/catalog_collections.dart';
import 'package:test/test.dart';

/// Seam 1: the collection Validators of the built-in catalog.
void main() {
  BasketForm form() => BasketForm();

  group('NotEmpty', () {
    test('rejects an empty list and accepts one with items', () {
      final f = form()
        ..items.setValue([])
        ..counts.setValue({});
      expect(f.items.state.errors, [const FormidableNotEmptyError()]);
      expect(f.counts.state.errors, [const FormidableNotEmptyError()]);

      f
        ..items.setValue(['a'])
        ..counts.setValue({'a': 1});
      expect(f.items.state.errors, isEmpty);
      expect(f.counts.state.errors, isEmpty);
    });

    test('also judges strings, and rejects a type it cannot judge', () {
      expect(const NotEmpty().validate(''), [const FormidableNotEmptyError()]);
      expect(const NotEmpty().validate('a'), isEmpty);
      expect(() => const NotEmpty().validate(3), throwsArgumentError);
    });
  });

  group('Unique', () {
    test('reports each duplicated value once', () {
      final f = form()..codes.setValue([1, 2, 2, 3, 3, 3]);

      expect(f.codes.state.errors, [
        const FormidableUniqueError(duplicates: [2, 3]),
      ]);
    });

    test('accepts distinct values', () {
      final f = form()..codes.setValue([1, 2, 3]);

      expect(f.codes.state.errors, isEmpty);
    });

    test('is case sensitive unless told otherwise', () {
      expect(const Unique().validate(['a', 'A']), isEmpty);
    });

    test('ignores case on request', () {
      final f = form()..names.setValue(['Ann', 'bob', 'ANN']);

      expect(f.names.state.errors, [
        const FormidableUniqueError(duplicates: ['Ann']),
      ]);
    });
  });

  group('ContainsAll', () {
    test('lists the missing values', () {
      final f = form()..roles.setValue({'user', 'guest'});

      expect(f.roles.state.errors, [
        const FormidableContainsAllError(missing: ['admin']),
      ]);
    });

    test('accepts a superset', () {
      final f = form()..roles.setValue({'user', 'guest', 'admin'});

      expect(f.roles.state.errors, isEmpty);
    });
  });

  group('ContainsNone', () {
    test('lists the forbidden values found', () {
      final f = form()..banned.setValue(['a', 'root']);

      expect(f.banned.state.errors, [
        const FormidableContainsNoneError(found: ['root']),
      ]);
    });

    test('accepts a collection without them', () {
      final f = form()..banned.setValue(['a']);

      expect(f.banned.state.errors, isEmpty);
    });
  });

  group('HasKeys', () {
    test('lists the missing keys', () {
      final f = form()..settings.setValue({'host': 'x'});

      expect(f.settings.state.errors, [
        const FormidableHasKeysError(missing: ['port']),
      ]);
    });

    test('accepts a map with every key', () {
      final f = form()..settings.setValue({'host': 'x', 'port': 1, 'z': 2});

      expect(f.settings.state.errors, isEmpty);
    });
  });

  group('Each', () {
    test('applies the Validators to every element', () {
      final f = form()..words.setValue(['abc', 'a', 'abcd', 'ab']);

      final error = f.words.state.errors.single as FormidableEachError;
      expect(error.failures.keys, [1, 3]);
      expect(error.failures[1], [isA<FormidableMinLengthError>()]);
    });

    test('accepts a list whose elements all pass, or an empty one', () {
      final f = form()..words.setValue(['abc', 'abcd']);
      expect(f.words.state.errors, isEmpty);

      f.words.setValue([]);
      expect(f.words.state.errors, isEmpty);
    });

    test('skips null elements for Validators that do not accept null', () {
      final f = form()..maybeWords.setValue(['abc', null]);

      expect(f.maybeWords.state.errors, isEmpty);
    });

    test('errors are equal when their failures are equal', () {
      final a = const Each([MinLength(3)]).validate(['a']);
      final b = const Each([MinLength(3)]).validate(['a']);

      expect(a, b);
    });
  });
}

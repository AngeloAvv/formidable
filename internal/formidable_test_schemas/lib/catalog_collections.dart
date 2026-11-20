import 'package:formidable/formidable.dart';

part 'catalog_collections.formidable.dart';

/// One Field per collection Validator of the built-in catalog.
@Formidable()
class Basket {
  const Basket({
    required this.items,
    required this.counts,
    required this.codes,
    required this.names,
    required this.roles,
    required this.banned,
    required this.settings,
    required this.words,
    required this.maybeWords,
  });

  @NotEmpty()
  final List<String> items;

  @NotEmpty()
  final Map<String, int> counts;

  @Unique()
  final List<int> codes;

  @Unique(ignoreCase: true)
  final List<String> names;

  @ContainsAll(['admin', 'user'])
  final Set<String> roles;

  @ContainsNone(['root'])
  final List<String> banned;

  @HasKeys(['host', 'port'])
  final Map<String, Object> settings;

  @Each([MinLength(3)])
  final List<String> words;

  @Each([MinLength(3)])
  final List<String?> maybeWords;
}

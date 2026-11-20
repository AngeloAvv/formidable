import 'package:formidable/formidable.dart';

import 'async_validation.dart';

part 'async_collections.formidable.dart';

/// An item of a Field Array whose Field has an Async Validator.
@Formidable()
class Member {
  const Member({required this.username});

  @MinLength(3)
  @AsyncValidator<UsernameAvailable>()
  final String username;
}

/// A Field Array of Nested Forms that carry Async Validators.
@Formidable()
class Club {
  const Club({this.members = const []});

  final List<Member> members;
}

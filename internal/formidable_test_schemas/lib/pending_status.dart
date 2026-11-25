import 'package:formidable/formidable.dart';

import 'async_validation.dart';

part 'pending_status.formidable.dart';

/// A leaf Schema whose only Field has an Async Validator.
@Formidable()
class Owner {
  const Owner({required this.username});

  @AsyncValidator<UsernameAvailable>()
  final String username;
}

/// Every kind of container around an Async Validator: a Nested Form, a Field
/// Array of Nested Forms and a Dynamic Form.
@Formidable()
class Workspace {
  const Workspace({
    required this.owner,
    this.others = const [],
    required this.extras,
  });

  final Owner owner;

  final List<Owner> others;

  @Dynamic()
  final Map<String, Object?> extras;
}

import 'package:formidable/formidable.dart';

part 'state_names.formidable.dart';

/// Fields named like the metadata of a Form state (`status`, `dirty`,
/// `pending`, `errors`), which live under `state.form`, so a Schema may use
/// these names for its own Fields.
@Formidable()
class StateNames {
  const StateNames({
    required this.status,
    required this.dirty,
    required this.pending,
    this.errors,
  });

  @MinLength(2)
  final String status;

  final bool dirty;

  @Passthrough()
  final int pending;

  final String? errors;
}

/// How many times [Counted] was constructed.
int countedBuilds = 0;

/// A Schema whose constructor counts its calls, to prove the value of the
/// state is lazy.
@Formidable()
class Counted {
  Counted({required this.name}) {
    countedBuilds++;
  }

  @MinLength(2)
  final String name;
}

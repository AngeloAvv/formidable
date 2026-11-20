import 'package:formidable/formidable.dart';

part 'choice_validators.formidable.dart';

enum Plan { free, pro, team }

/// One Field per built-in choice and equality Validator.
@Formidable()
class ChoiceRules {
  const ChoiceRules({
    this.isTrue,
    this.accepted,
    this.isFalse,
    this.declined,
    this.oneOf,
    this.oneOfIgnoreCase,
    this.oneOfNumber,
    this.oneOfPlan,
    this.noneOf,
    this.noneOfIgnoreCase,
    this.equalTo,
    this.equalToNumber,
    this.notEqualTo,
  });

  @IsTrue()
  final bool? isTrue;

  @Accepted()
  final bool? accepted;

  @IsFalse()
  final bool? isFalse;

  @Declined()
  final bool? declined;

  @OneOf(['red', 'green'])
  final String? oneOf;

  @OneOf(['red', 'green'], ignoreCase: true)
  final String? oneOfIgnoreCase;

  @OneOf([1, 2, 3])
  final int? oneOfNumber;

  @OneOf([Plan.pro, Plan.team])
  final Plan? oneOfPlan;

  @NoneOf(['admin', 'root'])
  final String? noneOf;

  @NoneOf(['admin', 'root'], ignoreCase: true)
  final String? noneOfIgnoreCase;

  @EqualTo('agree')
  final String? equalTo;

  @EqualTo(42)
  final int? equalToNumber;

  @NotEqualTo('password')
  final String? notEqualTo;
}

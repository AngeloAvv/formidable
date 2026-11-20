import 'package:formidable/formidable.dart';

part 'cross_field.formidable.dart';

/// Cross-field rules that compare two Fields.
@Formidable()
class PasswordChange {
  const PasswordChange({required this.password, required this.confirmation});

  final String password;

  @MustMatch(#password)
  final String confirmation;
}

@Formidable()
class Credentials {
  const Credentials({required this.oldPassword, required this.newPassword});

  final String oldPassword;

  @Different(#oldPassword)
  final String newPassword;
}

@Formidable()
class Booking {
  const Booking({
    required this.start,
    required this.end,
    required this.budget,
    required this.spent,
    this.deadline,
    this.reminder,
  });

  final DateTime start;

  @DateRangeOrder(#start)
  final DateTime end;

  final double budget;

  /// An `int` compared with a `double`.
  @Compare(FormidableComparison.lessThan, #budget)
  final int spent;

  final DateTime? deadline;

  @DateRangeOrder(#start, allowSame: false)
  final DateTime? reminder;
}

enum Kind { person, company }

/// The required-if family.
@Formidable()
class Conditional {
  const Conditional({
    required this.kind,
    this.email,
    this.phone,
    this.vat,
    this.taxCode,
    this.emailNote,
    this.contactName,
    this.postalAddress,
    this.fallback,
    this.subscribe,
    this.newsletterEmail,
    this.unsubscribeReason,
  });

  final Kind kind;
  final String? email;
  final String? phone;

  @RequiredIf(#kind, Kind.company)
  final String? vat;

  @RequiredUnless(#kind, Kind.company)
  final String? taxCode;

  @RequiredWith([#email])
  final String? emailNote;

  @RequiredWithAll([#email, #phone])
  final String? contactName;

  @RequiredWithout([#email])
  final String? postalAddress;

  @RequiredWithoutAll([#email, #phone])
  final String? fallback;

  final bool? subscribe;

  @RequiredIfAccepted(#subscribe)
  final String? newsletterEmail;

  @RequiredIfDeclined(#subscribe)
  final String? unsubscribeReason;
}

/// The prohibited and conditional acceptance rules.
@Formidable()
class Exclusive {
  const Exclusive({
    this.kind,
    this.vat,
    this.employees,
    this.email,
    this.phone,
    this.minor,
    this.parentConsent,
    this.marketing,
  });

  final Kind? kind;

  @ProhibitedIf(#kind, Kind.person)
  final String? vat;

  @ProhibitedUnless(#kind, Kind.company)
  final String? employees;

  @Prohibits([#phone])
  final String? email;

  final String? phone;

  final bool? minor;

  @AcceptedIf(#minor, true)
  final bool? parentConsent;

  @DeclinedIf(#minor, true)
  final bool? marketing;
}

/// The group rules, one per Field of the group.
@Formidable()
class Reach {
  const Reach({
    this.email,
    this.phone,
    this.a,
    this.b,
    this.c,
    this.x,
    this.y,
    this.z,
  });

  @AtLeastOneOf([#phone])
  final String? email;
  final String? phone;

  @ExactlyOneOf([#b, #c])
  final String? a;
  final String? b;
  final String? c;

  @AtMostOneOf([#y, #z])
  final String? x;
  final String? y;
  final String? z;
}

String lowerCase(String value) => value.toLowerCase();

@Formidable()
class Tagging {
  const Tagging({this.options, this.existing, this.choice, this.name});

  final List<String>? options;
  final List<String>? existing;

  @InList(#options)
  final String? choice;

  @UniqueBy(#existing, lowerCase)
  final String? name;
}

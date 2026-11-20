import 'dart:async';

import 'package:formidable/formidable.dart';

part 'async_validation.formidable.dart';

final class TakenError extends FormidableValidationError {
  const TakenError(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// An Async Validator whose answers the test controls: every call waits until
/// the test calls [answer] or [fail].
abstract class ControlledValidator extends FormidableAsyncValidator<String> {
  ControlledValidator({this.debounce = const Duration(milliseconds: 300)});

  @override
  final Duration debounce;

  /// The values the validator was called with, in order.
  final List<String> calls = [];
  final Map<String, List<Completer<List<FormidableValidationError>>>> _waiting =
      {};

  @override
  Future<List<FormidableValidationError>> validate(String value) {
    calls.add(value);
    final completer = Completer<List<FormidableValidationError>>();
    (_waiting[value] ??= []).add(completer);
    return completer.future;
  }

  /// Answers every call that waits for [value]: taken or free.
  void answer(String value, {required bool taken}) {
    for (final completer in _waiting.remove(value) ?? const []) {
      completer.complete(
        taken ? [TakenError(value)] : const <FormidableValidationError>[],
      );
    }
  }

  /// Makes every call that waits for [value] throw.
  void fail(String value, Object error) {
    for (final completer in _waiting.remove(value) ?? const []) {
      completer.completeError(error);
    }
  }
}

class UsernameAvailable extends ControlledValidator {
  UsernameAvailable({super.debounce});
}

class EmailAvailable extends ControlledValidator {
  EmailAvailable({super.debounce});
}

/// Two Fields, each with its own Async Validator, plus a Field without one.
@Formidable()
class Registration {
  const Registration({
    required this.username,
    required this.email,
    required this.note,
  });

  @MinLength(3)
  @AsyncValidator<UsernameAvailable>()
  final String username;

  @AsyncValidator<EmailAvailable>()
  final String email;

  final String note;
}

final class CityMismatchError extends FormidableValidationError {
  const CityMismatchError();
}

/// An asynchronous Form Validator that reads two Fields. Every call waits until
/// the test calls [answer] or [fail].
class PostalCodeMatchesCity extends FormidableAsyncFormValidator<ShippingForm> {
  PostalCodeMatchesCity({this.debounce = const Duration(milliseconds: 300)});

  @override
  final Duration debounce;

  /// The `postalCode/city` pairs the validator was called with, in order.
  final List<String> calls = [];
  final Map<String, List<Completer<bool>>> _waiting = {};

  @override
  List<FormidableField<Object?>> dependencies(ShippingForm form) => [
    form.postalCode,
    form.city,
  ];

  @override
  Future<List<FormidableFieldError>> validate(ShippingForm form) async {
    final key = '${form.postalCode.value}/${form.city.value}';
    calls.add(key);
    final completer = Completer<bool>();
    (_waiting[key] ??= []).add(completer);
    final mismatch = await completer.future;
    return mismatch
        ? [FormidableFieldError(form.city, const CityMismatchError())]
        : const [];
  }

  /// Answers every call that waits for [key]: a mismatch is an error on `city`.
  void answer(String key, {required bool mismatch}) {
    for (final completer in _waiting.remove(key) ?? const []) {
      completer.complete(mismatch);
    }
  }

  void fail(String key, Object error) {
    for (final completer in _waiting.remove(key) ?? const []) {
      completer.completeError(error);
    }
  }
}

@Formidable()
@AsyncFormValidator<PostalCodeMatchesCity>()
class Shipping {
  const Shipping({
    required this.postalCode,
    required this.city,
    required this.note,
  });

  @MinLength(5)
  final String postalCode;

  final String city;

  final String note;
}

/// A Schema whose Nested Form has an asynchronous Form Validator: the parent
/// Form takes the validator instance too and hands it down.
@Formidable()
class Order {
  const Order({required this.shipping, required this.reference});

  final Shipping shipping;

  final String reference;
}

/// A Field with a cross-field rule and an Async Validator: the check may only
/// run once the rule passes.
@Formidable()
class Invitation {
  const Invitation({required this.code, required this.confirmation});

  final String code;

  @MustMatch(#code)
  @AsyncValidator<UsernameAvailable>()
  final String confirmation;
}

/// The same Field one level down, in a Nested Form.
@Formidable()
class Referral {
  const Referral({required this.invitation, required this.note});

  final Invitation invitation;

  final String note;
}

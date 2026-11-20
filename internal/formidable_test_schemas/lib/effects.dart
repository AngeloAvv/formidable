import 'package:formidable/formidable.dart';

part 'effects.formidable.dart';

/// Form Effects coverage: dependent Fields, a derived Field and a Passthrough
/// Field written by Effects.
@Formidable()
@Effects([
  ClearProvinceOnCountryChange(),
  DeriveLabel(),
  BumpRevisionOnProvinceChange(),
])
class Address {
  const Address({
    required this.revision,
    required this.country,
    this.province,
    this.label,
  });

  @Passthrough()
  final int revision;

  @Trim()
  final String country;

  @MinLength(2)
  final String? province;

  /// Always `country/province`, maintained by an Effect.
  final String? label;
}

/// Clears the province when the country changes.
class ClearProvinceOnCountryChange extends FormidableEffect<AddressForm> {
  const ClearProvinceOnCountryChange();

  @override
  void apply(AddressForm form, FormidableEffectContext context) {
    if (context.changed(form.country)) form.province.clear();
  }
}

/// Keeps the label in sync with the Fields it is made of.
class DeriveLabel extends FormidableEffect<AddressForm> {
  const DeriveLabel();

  @override
  void apply(AddressForm form, FormidableEffectContext context) {
    form.label.setValue(
      '${form.country.value ?? ''}/${form.province.value ?? '-'}',
    );
  }
}

/// Counts how many times the province changed, in a Passthrough Field.
class BumpRevisionOnProvinceChange extends FormidableEffect<AddressForm> {
  const BumpRevisionOnProvinceChange();

  @override
  void apply(AddressForm form, FormidableEffectContext context) {
    if (context.changed(form.province)) {
      form.revision.setValue(form.revision.value + 1);
    }
  }
}

/// Everything that happened in [EffectOrder], in order.
final effectLog = <String>[];

/// Records that a value reached validation.
class RecordingValidator extends FormidableValidator<String> {
  const RecordingValidator();

  @override
  List<FormidableValidationError> validate(String value) {
    effectLog.add('validate:$value');
    return const [];
  }
}

class LogEffect extends FormidableEffect<EffectOrderForm> {
  const LogEffect(this.name);

  final String name;

  @override
  void apply(EffectOrderForm form, FormidableEffectContext context) {
    effectLog.add('$name:${form.title.value}');
  }
}

/// Pins the order Normalizers, Effects, Validators.
@Formidable()
@Effects([LogEffect('first'), LogEffect('second')])
class EffectOrder {
  const EffectOrder({required this.title});

  @Trim()
  @RecordingValidator()
  final String title;
}

/// Effects that trigger each other forever once `armed` is true.
@Formidable()
@Effects([PingEffect(), PongEffect()])
class EffectLoop {
  const EffectLoop({this.armed = false, this.ping, this.pong});

  final bool armed;
  final int? ping;
  final int? pong;
}

class PingEffect extends FormidableEffect<EffectLoopForm> {
  const PingEffect();

  @override
  void apply(EffectLoopForm form, FormidableEffectContext context) {
    if (form.armed.value == true) {
      form.ping.setValue((form.pong.value ?? 0) + 1);
    }
  }
}

class PongEffect extends FormidableEffect<EffectLoopForm> {
  const PongEffect();

  @override
  void apply(EffectLoopForm form, FormidableEffectContext context) {
    if (form.armed.value == true) {
      form.pong.setValue((form.ping.value ?? 0) + 1);
    }
  }
}

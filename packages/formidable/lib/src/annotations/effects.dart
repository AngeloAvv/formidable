import '../runtime/effect.dart';
import '../runtime/form.dart';

/// Declares the Form Effects of a Schema.
///
/// Put it on the Schema class next to `@Formidable()`. The Effects receive the
/// generated Form and run in the order listed.
///
/// ```dart
/// @Formidable()
/// @Effects([ClearProvinceOnCountryChange()])
/// class Address {
///   const Address({required this.country, this.province});
///
///   final String country;
///   final String? province;
/// }
///
/// class ClearProvinceOnCountryChange extends FormidableEffect<AddressForm> {
///   const ClearProvinceOnCountryChange();
///
///   @override
///   void apply(AddressForm form, FormidableEffectContext context) {
///     if (context.changed(form.country)) form.province.clear();
///   }
/// }
/// ```
class Effects {
  const Effects(this.effects);

  final List<FormidableEffect<FormidableForm<Object?>>> effects;
}

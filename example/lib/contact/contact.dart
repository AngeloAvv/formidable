import 'package:flutter/foundation.dart';
import 'package:formidable/formidable.dart';

part 'contact.formidable.dart';

/// A Form Effect: when the country changes, the province no longer applies.
///
/// It is typed on the generated Form, so it reaches the Fields through typed
/// handles, and it runs on every change, from the user or from code.
class ClearProvinceOnCountryChange extends FormidableEffect<AddressForm> {
  const ClearProvinceOnCountryChange();

  @override
  void apply(AddressForm form, FormidableEffectContext context) {
    if (context.changed(form.country)) form.province.clear();
  }
}

/// A Nested Form of [Contact]: `ContactForm.address` is an `AddressForm`.
@Formidable()
@Effects([ClearProvinceOnCountryChange()])
class Address {
  const Address({required this.street, this.country = 'IT', this.province});

  @Trim()
  @MinLength(2)
  final String street;

  final String country;

  @Trim()
  final String? province;
}

/// The Schema of the edit guide. `ContactForm.from(contact)` starts the Form
/// from a saved contact, and `commit()` records a save.
@Formidable()
class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.email,
    required this.address,
  });

  /// A Passthrough Field is not an input: the Form carries it from the
  /// Schema instance to the output, and no widget is bound to it.
  @Passthrough()
  final int id;

  @Trim()
  @MinLength(2)
  final String name;

  @Trim()
  @Email()
  final String? email;

  final Address address;
}

/// What the service says when an email is already registered.
final class EmailInUseError extends FormidableValidationError {
  const EmailInUseError();
}

/// A service that rejects one address. A real app would call an API.
bool emailIsInUse(String? email) => email == 'taken@example.com';

/// Where the saved contact lives. A real app would call an API.
class ContactStore extends ChangeNotifier {
  ContactStore([
    Contact contact = const Contact(
      id: 7,
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      address: Address(street: '1 Main St', province: 'RM'),
    ),
  ]) : _contact = contact;

  Contact _contact;

  Contact get contact => _contact;

  void save(Contact contact) {
    _contact = contact;
    notifyListeners();
  }
}

/// The summary line of an address.
String describeAddress(Address address) => [
  address.street,
  if (address.province != null) address.province,
  address.country,
].join(', ');

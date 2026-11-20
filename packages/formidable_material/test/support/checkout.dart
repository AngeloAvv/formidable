import 'package:formidable/formidable.dart';

part 'checkout.formidable.dart';

@Formidable()
class Address {
  const Address({required this.street, this.zip});

  @MinLength(3)
  final String street;

  final String? zip;
}

@Formidable()
class Checkout {
  const Checkout({required this.name, required this.billing, this.shipping});

  final String name;
  final Address billing;
  final Address? shipping;
}

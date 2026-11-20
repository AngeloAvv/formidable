import 'package:formidable/formidable.dart';

part 'contact.formidable.dart';

@Formidable()
class Contact {
  const Contact({required this.reference});

  @AnyOf([MinLength(10), MinLength(20)])
  final String reference;
}

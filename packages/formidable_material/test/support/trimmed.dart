import 'package:formidable/formidable.dart';

part 'trimmed.formidable.dart';

@Formidable()
class Trimmed {
  const Trimmed({required this.city});

  @Trim()
  final String city;
}

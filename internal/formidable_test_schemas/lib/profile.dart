import 'package:formidable/formidable.dart';

part 'profile.formidable.dart';

/// Minimal presence coverage: a nullable Field and a Field with a default.
@Formidable()
class Profile {
  const Profile({this.nickname, this.bio = '', required this.email});

  final String? nickname;
  final String bio;
  final String email;
}

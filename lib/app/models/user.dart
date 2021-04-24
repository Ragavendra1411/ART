import 'package:meta/meta.dart';

@immutable
class User {
  final String uid;
  final String email;
  final String userName;
  final int role;
  final String imageUrl;


  const User({
    @required this.uid,
    this.email,
    this.userName,
    this.role,
    this.imageUrl,
  });
}

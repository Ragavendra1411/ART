import 'package:meta/meta.dart';

@immutable
class UserStore {
  final String usersId;
  final String email;
  final String userName;
  final int role;
  final String imageUrl;


  const UserStore({
    @required this.usersId,
    this.email,
    this.userName,
    this.role,
    this.imageUrl,
  });
}

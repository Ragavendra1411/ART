import 'package:flutter/material.dart';


class TagsProvider with ChangeNotifier{

  int userType;
  String userId;

  ///To get the use role ///////////////////////////////////
  int get userRole{
    return userType;
  }
  ///Setting the user type
  void setUserRole(int userRole){
    userType = userRole;
    notifyListeners();
  }
  /// //////////////////////////////////////////////////////

  ///To get the use id ///////////////////////////////////
  String get getUserId{
    return userId;
  }
  ///Setting the user id
  void setUserId(String userIdValue){
    userId = userIdValue;
    notifyListeners();
  }
/// //////////////////////////////////////////////////////





}
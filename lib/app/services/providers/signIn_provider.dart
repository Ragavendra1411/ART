import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_market/app/services/firebase_authentication_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SignInProvider extends ChangeNotifier {
//  SignInProvider(this.locator);

//  final Locator locator;
  int userType;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int get userRole{
    return userType;
  }

  void setUserRole(int userRole){
    userType = userRole;
    notifyListeners();
  }

  
   Future<void> signUpWithEmail(BuildContext context, String email , String password , String name) async {
    _setLoadingTrue();
    await context.read<FirebaseAuthService>().registerUserWithEmailAndPassword(email, password, name);
    _setLoadingFalse();
  }

   Future<Map> signInWithEmail(String email , String password ) async {
    _setLoadingTrue();
    var returnData = await FirebaseAuthService().loginUserWithEmailAndPassword(email, password);
    _setLoadingFalse();
    return returnData;
   }

  _setLoadingTrue() {
    _isLoading = true;
    notifyListeners();
  }

  _setLoadingFalse() {
    _isLoading = false;
    notifyListeners();
  }

  Future<Map> validateAndLoginApi(
      String userName, String password) async {
    final databaseReference = Firestore.instance;
    Map resultData;
    await databaseReference
        .collection("users")
        .where('id', isEqualTo: userName)
        .getDocuments()
        .then((value) {
          if( value.documents.length!=0){
            var dataSend = {
              'email': value.documents[0]['email'],
            };

            resultData = {"notError": "success", 'data': dataSend};
          }else{
            resultData = {"notError": "Account not found"};
          }
    }).catchError((error) {
      print(error);
      if (error.toString() ==
          "NoSuchMethodError: invalid member on null: '_get'") {
        resultData = {"notError": "Account not found"};
      } else {
        resultData = {"notError": "Unknown error occurred"};
      }
    });
    return resultData;
  }

  Future forgotPassword(String userId) async{
    final databaseReference = Firestore.instance;
    Map resultData;
    await databaseReference
        .collection("users")
        .where('id', isEqualTo: userId).getDocuments().then((value) async{
      await _firebaseAuth.sendPasswordResetEmail(email: value.documents[0]["email"]);
    resultData = {"isSuccess":true};
    }).catchError((error){
      resultData = {"isSuccess":false};
    });
    return resultData;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProviderServices {
  CollectionReference userRef = Firestore.instance.collection("users");
  Map responseMap = {};
  var error;
  Future addUser(Map data) async {
    await userRef
        .where("id", isEqualTo: data["id"].toString())
        .getDocuments()
        .then((value) async {
      if (value.documents.length == 0) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: data["email"], password: data["password"])
            .then((signedInUser) async {
          data.remove("password");
          data["userUid"] = signedInUser.user.uid;
          await userRef
              .document(signedInUser.user.uid)
              .setData(data)
              .then((value) {
            responseMap["isSuccess"] = true;
          }).onError((error, stackTrace) {
            responseMap["isSuccess"] = false;
            print("Error - $error");
          }).catchError((error) {
            responseMap["isSuccess"] = false;
            print("Error - $error");
          });
        }).catchError((e) {
          if (e.toString() ==
              "FirebaseError: The email address is already in use by another account. (auth/email-already-in-use)") {
            responseMap["isSuccess"] = false;
            responseMap["message"] =
                "Account already exists with this email id";
          } else if (e.toString() ==
              "FirebaseError: The email address is badly formatted. (auth/invalid-email)") {
            responseMap["isSuccess"] = false;
            responseMap["message"] = "Invalid email id";
          }
        });
      } else {
        responseMap["isSuccess"] = false;
        responseMap["message"] = "Account already exists with this User ID";
      }
    });

    return responseMap;
  }
}

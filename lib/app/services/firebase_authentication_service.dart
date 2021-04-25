import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_market/app/models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //SIGN IN OR NOT CHECKING
  FirebaseAuthService({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
        uid: user.uid,
        email: user.email,
        userName: user.displayName,
        imageUrl: user.photoUrl);
  }

  User _userFromFirebaseForEmailAuth(Map user) {
    if (user == null) {
      return null;
    }
    return User(
        uid: user["uid"],
        email: user["email"],
        userName: user["userName"],
        role: user["role"],
        imageUrl: null);
  }

  //CHANGE AUTH PROCESS

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  //SIGN IN WITH NON GOOGLE OR ANONYMOUS

  Future<User> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  //SIGN IN WITH GOOGLE

  Future signInWithGoogleAccount() async {
    final GoogleSignInAccount googleAccountUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleUserAuth =
        await googleAccountUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleUserAuth.idToken,
        accessToken: googleUserAuth.accessToken);
    final authResult = await _firebaseAuth.signInWithCredential(credential);
//     _dbCheck(authResult);
    dbCheck(authResult);

    return _userFromFirebase(authResult.user);
  }

  //SIGN-OUT

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  //GET CURRENT-USER

  Future<User> getCurrentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }

  Future dbCheck(AuthResult authResult) async {
    DocumentReference documentReference =
        Firestore.instance.collection('users').document(authResult.user.uid);
    var finalResult = await documentReference.get();
    return finalResult.data == null
        ? _registerData(authResult)
        : loginUser(finalResult.data['role']).then((value) {});
  }

  _registerData(AuthResult authResult) async {
    await Firestore.instance
        .collection('users')
        .document(authResult.user.uid)
        .setData({
      'username': authResult.user.displayName,
      'email': authResult.user.email,
      'usersId': authResult.user.uid,
      'isActive': false,
      'role': 0,
      'isNew': true,
    });
    return _userFromFirebase(authResult.user);
  }

  Future loginUser(value) async {
    return value;
  }

  //SIGN UP WITH EMAIL AND PASSWORD
  registerUserWithEmailAndPassword(String email, String password, String name) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((signedInUser) => {
          
              Firestore.instance
                  .collection('users')
                  .document(signedInUser.user.uid)
                  .setData({
                'username': name,
                'email': email,
                'usersId': signedInUser.user.uid,
                'isActive': false,
                'role': 0,
                'isNew': true,
              }).catchError((e) {
              })
            })
        .catchError((e) {
      if (e.toString() ==
          "FirebaseError: The email address is already in use by another account. (auth/email-already-in-use)") {
        window.alert("Account already exists");
      } else if (e.toString() ==
          "FirebaseError: The email address is badly formatted. (auth/invalid-email)") {
        window.alert("Invalid email id");
      }

    });
  }

  //SIGN IN WITH EMAIL AND PASSWORD
  Future<Map> loginUserWithEmailAndPassword(String email, String password) async{
    Map<String, dynamic> userDatas;
    var storedData;
    Map returnData;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) async {
      var userId = user.user.uid;
      await Firestore.instance
          .collection("users")
          .document(userId)
          .get()
          .then((value) async{
        userDatas = {
          "uid": user.user.uid,
          "email": user.user.email,
          "userName": value.data["userName"],
          "role": value.data["role"],
        };
        storedData = await _userFromFirebaseForEmailAuth(userDatas);
        returnData = {"data":storedData,"isError":false};
      }).catchError((error){
        returnData = {"data":error,"isError":true};
      });
    }).catchError((e) {
      print("error auth - $e");
      if (e.toString() ==
          "FirebaseError: There is no user record corresponding to this identifier. The user may have been deleted. (auth/user-not-found)") {
        returnData = {"data":"Account does not exist","isError":true};
      }else if(e.toString() == "FirebaseError: The password is invalid or the user does not have a password. (auth/wrong-password)"){
        returnData = {"data":"Incorrect Password","isError":true};
      }
      else if(e.toString() == "FirebaseError: Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later. (auth/too-many-requests)"){
        returnData = {"data":"Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.","isError":true};
      }else{
        returnData = {"data":"${e.toString()}","isError":true};
      }
      // else {
      //   window.alert("Invalid credentials");
      // }
    });
    return returnData;
  }
}

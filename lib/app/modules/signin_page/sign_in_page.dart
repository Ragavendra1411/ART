import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/modules/forgot_password/forgot_password.dart';
import 'package:share_market/app/services/providers/signIn_provider.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/gradient_buttn.dart';

import '../../../app_commons/constants.dart';
import '../../../app_commons/constants.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController login_email = TextEditingController();
  final TextEditingController login_password = TextEditingController();
  GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();
  bool isLogin = true;
  var height;
  var width;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return _buildContent(context);
  }

  Center _loadingCircle() {
    return Center(
      child: Container(
        child: Opacity(
          opacity: 0.5,
          child: Image.asset('assets/images/rotategif.gif'),
        ),
      ),
    );
  }

  _setLoader(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  _buildContent(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: height,
              width: width,
              child: Image.asset(
                'assets/images/login_bg.jpg',
                fit: BoxFit.cover,
              )),
          _centervera(context)
          // _centerLogForm(context),
        ],
      ),
    );
  }

  _centervera(BuildContext context) {
    return Center(
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: new BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: new Container(
            decoration: new BoxDecoration(color: Colors.white.withOpacity(0.2)),
            child: Container(
              // height: 250,
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                        ),
                      ),
                    ],
                  ),
                  loginForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _centerLogForm(BuildContext context) {
    return Center(
      child: Card(
        shadowColor: Colors.orange,
        margin: EdgeInsets.all(10),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            // height: 250,
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            // margin:
                            // EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
                            child: Text(
                              'Welcome',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 22),
                            ),
                          ),
                          Container(
//                                margin: EdgeInsets.all(20.0),rr
                              )
                        ],
                      ),
                    ),
                  ],
                ),
                loginForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginForm(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.orange,
        hintColor: Colors.orange,
      ),
      child: Form(
        key: _loginformKey,
        child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
          child: Container(
            padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
            child: Column(
              children: [
                AhCrmTextField(
                  context: context,
                  nextFocusNode: null,
                  currentFocusNode: null,
                  title: "UserId",
                  controller: login_email,
                  formDataMapKey: null,
                  keyboardTypeDone: false,
                  isEmailField: false,
                  isNumberKeyboard: false,
                  isMandatoryField: true,
                  formData: null,
                  maxLines: 1,
                  isPaddingNeeded: false,
                  defaultTextFieldWidth: true,
                ),
                AhCrmTextField(
                  context: context,
                  nextFocusNode: null,
                  currentFocusNode: null,
                  title: "Password",
                  controller: login_password,
                  formDataMapKey: null,
                  keyboardTypeDone: true,
                  isEmailField: false,
                  isNumberKeyboard: false,
                  isMandatoryField: true,
                  formData: null,
                  maxLines: 1,
                  isPaddingNeeded: false,
                  defaultTextFieldWidth: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: SM_ORANGE,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        )),
                    SizedBox(
                      width: 32,
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                RaisedGradientButton(
                    child: _isLoading
                        ? Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ))
                        : Text(
                            'LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold),
                          ),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.orange, Colors.yellow[600]],
                    ),
                    onPressed: () {
                      final form = _loginformKey.currentState;
                      if (form.validate()) {
                        _setLoader(true);
                        Provider.of<SignInProvider>(context, listen: false)
                            .validateAndLoginApi(login_email.text.trim(),
                                login_password.text.trim())
                            .then((value) async {
                          if (value["notError"] == "success") {
                            await Provider.of<SignInProvider>(context,
                                    listen: false)
                                .signInWithEmail(value['data']['email'],
                                    login_password.text.trim())
                                .then((value) {
                              _setLoader(false);
                              print("Auth then - ${value}");
                              if(value["isError"]){
                                toastMessage(
                                    "${value["data"]}", SM_RED, Icons.error);
                              }else{

                              }
                            }).catchError((error) {
                              _setLoader(false);
                              print("auth error - $error");
                              toastMessage(
                                  "Authentication error", SM_RED, Icons.error);
                            });
                          } else {
                            _setLoader(false);
                            toastMessage(
                                "${value["notError"]}", SM_RED, Icons.error);
                          }
                        });
                        // Provider.of<SignInProvider>(context, listen: false)
                        //     .signInWithEmail(
                        //         context, login_email.text.trim(), login_password.text.trim());
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void toastMessage(String message, Color colour, IconData icon) {
    final snackBar = SnackBar(
        width: width > 400 ? 500 : width,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              icon,
              color: SM_BACKGROUND_WHITE,
            ),
            SizedBox(
              width: 5,
            ),
            new Flexible(
                child: Text(
              message,
              softWrap: true,
              style: TextStyle(
                  color: SM_BACKGROUND_WHITE, fontWeight: FontWeight.w600),
            )),
          ],
        ),
        backgroundColor: colour,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

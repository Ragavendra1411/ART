import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/services/providers/signIn_provider.dart';
import 'package:share_market/app_commons/sm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app_commons/gradient_buttn.dart';
import 'package:share_market/app_commons/utilities.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController userId = TextEditingController();
  GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();
  var height;
  var width;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
          centerForm(context)
          // _centerLogForm(context),
        ],
      ),
    );
  }

  Widget centerForm(BuildContext context){
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
                SMTextField(
                  context: context,
                  nextFocusNode: null,
                  currentFocusNode: null,
                  title: "UserId",
                  controller: userId,
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
                SizedBox(height: 15.0),
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
                      'Send reset password email',
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
                        setState(() {
                          _isLoading = true;
                        });
                        Provider.of<SignInProvider>(context, listen: false)
                            .forgotPassword(userId.text.trim())
                            .then((value) {
                          setState(() {
                            _isLoading = false;
                          });

                          if (value["isSuccess"]) {
                            Utilities().toastMessage("Email sent successfully to reset your Password", cursorColour , Icons.done, width, context);
                            Future.delayed(Duration(seconds: 2),(){
                              Navigator.pop(context);
                            });
                          } else {

                            Utilities().toastMessage("Error in sending email", SM_RED, Icons.error, width, context);
                          }
                        }).catchError((error){
                          setState(() {
                            _isLoading = false;
                          });
                          print(error);
                          Utilities().toastMessage("Error in sending email", SM_RED, Icons.error, width, context);
                        });
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

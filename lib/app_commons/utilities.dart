import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class Utilities{
  void toastMessage(String message, Color colour, IconData icon,int width,BuildContext context) {
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
                      color: SM_BACKGROUND_WHITE,
                      fontWeight: FontWeight.w600),
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

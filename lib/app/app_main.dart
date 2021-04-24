
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/modules/home-page/home_page.dart';
import 'package:share_market/app/modules/signin_page/sign_in_page.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app/models/user.dart';

class MyApp extends StatelessWidget {
  var res;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     home: Consumer<User>(
       builder: (context, user, _) {
         if (user == null) {
           return SigninPage();
         } else {
           return HomePage(user:user);
         }
       },
     ),
    // home: HomePage(),
      title: 'Share Market',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        scaffoldBackgroundColor: SM_BACKGROUND_COLOUR,
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cursorColor: SM_BUTTON_BLUE,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/app_main.dart';
import 'package:share_market/app/services/firebase_authentication_service.dart';
import 'package:share_market/app/services/providers/signIn_provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      Provider(
        create: (ctx) => FirebaseAuthService(),
      ),
      StreamProvider(
        create: (context) =>
        context.read<FirebaseAuthService>().onAuthStateChanged,
      ),
      ChangeNotifierProvider(create: (context) => SignInProvider()),
    ],
    child: MyApp(),
  ),
);
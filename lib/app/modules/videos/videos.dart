import 'package:flutter/material.dart';
import 'package:share_market/app_commons/constants.dart';

class VideosPage extends StatefulWidget {
  final Map dataSend;

  VideosPage({@required this.dataSend});
  @override
  _VideosPageState createState() => _VideosPageState(dataSend: dataSend);
}

class _VideosPageState extends State<VideosPage> {
  final Map dataSend;

  _VideosPageState({@required this.dataSend});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: dataSend['role'] == 'admin' || dataSend['role'] == 'professional'
            ? FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
          },
          label: Text(
            ' ADD VIDEO',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: SM_ORANGE,
        )
            : null,
      backgroundColor: backgroundOrangeColour,
    );
  }
}

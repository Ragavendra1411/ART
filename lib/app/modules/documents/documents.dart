import 'package:flutter/material.dart';
import 'package:share_market/app_commons/constants.dart';

class DocumentsPage extends StatefulWidget {
  final Map dataSend;

  DocumentsPage({@required this.dataSend});
  @override
  _DocumentsPageState createState() => _DocumentsPageState(dataSend:dataSend);
}

class _DocumentsPageState extends State<DocumentsPage> {
  final Map dataSend;

  _DocumentsPageState({@required this.dataSend});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: dataSend['role'] == 'admin' || dataSend['role'] == 'professional'
          ? FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
        },
        label: Text(
          ' ADD DOCUMENT',
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

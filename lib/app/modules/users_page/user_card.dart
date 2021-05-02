import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final DocumentSnapshot cardData;
  final int pageWidth;

  UserCard({@required this.cardData,@required this.pageWidth});
  @override
  _UserCardState createState() => _UserCardState(cardData:cardData,pageWidth:pageWidth);
}

class _UserCardState extends State<UserCard> {
  final DocumentSnapshot cardData;
  final int pageWidth;

  _UserCardState({@required this.cardData,@required this.pageWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        width: pageWidth < 401 ? pageWidth : 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User name: ${cardData["userName"]}"),
            SizedBox(height: 5.0,),
            Text("User ID: ${cardData["id"]}"),
            SizedBox(height: 5.0,),
            Text("User type: ${cardData["role"]}"),
            SizedBox(height: 5.0,),
            Text("User ID: ${cardData["email"]}"),
          ],
        ),
      ),
    );
  }
}

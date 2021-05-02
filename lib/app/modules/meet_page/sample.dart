import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app_commons/constants.dart';

class SampleWidget extends StatefulWidget {
  @override
  _SampleWidgetState createState() => _SampleWidgetState();
}

class _SampleWidgetState extends State<SampleWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: meetingPageBody(),
    );
  }

  Widget meetingPageBody() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("leads_list")
            .orderBy('name')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text('No data available'));
          }

          List meetingsList;
          // snapshot.data.documents.foreach((meeting) {
          //   meetingsList += meeting;
          // });
          meetingsList = snapshot.data.documents;

          if (meetingsList.length == 0) {
            return Center(child: Text("No meeting scheduled"));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                listOfMeetings(meetingsList),
              ],
            );
          }
        });
  }

  Widget listOfMeetings(List meetings) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: meetings.length,
        itemBuilder: (BuildContext context, int index) {
          return meetingCard(meetings[index]);
        });
  }

  Widget meetingCard(data) {
    return Card(
      shadowColor: Colors.orange,
      margin: EdgeInsets.all(10),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 150,
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 200,
                  // child: Image.network(
                  //   "https://www.prometsource.com/sites/default/files/styles/blog_detail/public/2020-04/24_Working%20Remotely.png?itok=2beVPyEd",
                  //   fit: BoxFit.cover,
                  //   height: double.infinity,
                  //   width: double.infinity,
                  // )
                  color: SM_GREY,
                )),
            SizedBox(width: 30),
            Container(
                width: MediaQuery.of(context).size.width / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Title of Meeting",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "This is the description of the meeting to be held.This is the description of the meeting to be held.This is the description of the meeting to be held.This is the description of the meeting to be held",
                      style: TextStyle(color: Colors.grey[500]),
                      maxLines: 5,
                    )
                  ],
                )),
            Expanded(child: Container()),
            RaisedButton(
              padding: EdgeInsets.all(20),
              onPressed: () {},
              color: Colors.orange,
              child: Text(
                ' Join Meeting ',
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 15),
            RaisedButton(
              padding: EdgeInsets.all(20),
              onPressed: () {},
              color: Colors.red,
              child: Text(
                'Cancel Meeting',
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

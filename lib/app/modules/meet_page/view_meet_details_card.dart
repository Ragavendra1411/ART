import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_market/app/modules/meet_page/enter_minutes_of_meeting.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app_commons/utilities.dart';
import 'package:share_market/services/meetings_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMeetDetailsCard extends StatefulWidget {
  final DocumentSnapshot cardData;
  final double pageWidth;
  final String userRole;

  ViewMeetDetailsCard({@required this.cardData,@required this.pageWidth,@required this.userRole});

  @override
  _ViewMeetDetailsCardState createState() => _ViewMeetDetailsCardState(cardData:cardData,pageWidth:pageWidth,userRole:userRole);
}

class _ViewMeetDetailsCardState extends State<ViewMeetDetailsCard> {
  final DocumentSnapshot cardData;
  final double pageWidth;
  final String userRole;

  _ViewMeetDetailsCardState({@required this.cardData,@required this.pageWidth,@required this.userRole});

  showEnterMinutesOfMeetingCard(BuildContext context,DocumentSnapshot data,double width,String userRole) async{
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return EnterMinutesOfMeetingCard(cardData: data, pageWidth: width, userRole: userRole);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shadowColor: Colors.orange,
        margin: EdgeInsets.all(10),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(12),
                width: pageWidth < 401 ? pageWidth : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: (){
                              Navigator.pop(context);
                            })
                      ],
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          height: 200,
                          child: cardData["eventImageUrl"]!=null? Image.network(
                            cardData["eventImageUrl"].toString(),
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ):Image.asset("assets/images/logo.png"),
                          color: Colors.transparent,
                        )),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          cardData["title"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMMM, yyyy')
                                  .format(DateTime.parse(cardData["dateOfMeeting"])),
                              style: TextStyle(color: Colors.grey[500]),
                              maxLines: 5,
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${DateFormat('hh:mm a').format(DateTime.parse(cardData["startTime"].toDate().toString()))} - ${DateFormat('hh:mm a').format(DateTime.parse(cardData["endTime"].toDate().toString()))}",
                              //  DateFormat.().format(DateTime.fromMillisecondsSinceEpoch(data["startTime"])),
                              // DateTime.fromMillisecondsSinceEpoch(data["startTime"] * 1000).toString(),
                              style: TextStyle(color: Colors.grey[500]),
                              maxLines: 5,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            userRole == 'admin'
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: SM_RED,
                                padding: EdgeInsets.all(18.0),
                              ),
                              onPressed: () async {
                                await MeetingsServices()
                                    .cancelMeeting(cardData.documentID)
                                    .then((value) {
                                  if (value["isSuccess"]) {
                                    Utilities().toastMessage("Cancelled the meeting successfully", cursorColour, Icons.done, pageWidth, context);
                                  } else {
                                    Utilities().toastMessage("Oops! Something went wrong. Please try again.", ERROR_RED, Icons.error, pageWidth, context);
                                  }
                                }).catchError((error) {
                                  Utilities().toastMessage("Oops! Something went wrong. Please try again.", ERROR_RED, Icons.error, pageWidth, context);
                                });
                              },
                              child: Text(
                                'Cancel Meeting',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                                : Container(),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: SM_ORANGE,
                                padding: EdgeInsets.all(18.0),
                              ),
                              onPressed: () async {
                                var uri = cardData["meetingLink"];
                                if (await canLaunch(uri)) {
                                  await launch(uri);
                                } else {
                                  throw 'Could not launch $uri';
                                }
                              },
                              child: Text(
                                ' Join Meeting ',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        userRole == 'admin'
                            ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: cursorColour,
                            padding: EdgeInsets.all(18.0),
                          ),
                          onPressed: () {
                            showEnterMinutesOfMeetingCard(context,cardData,pageWidth,cardData["role"].toString());
                          },
                          child: cardData["minutesOfMeeting"] == null || cardData["minutesOfMeeting"].toString().trim() == ""? Text(
                            'Add minutes of meeting',
                            style: TextStyle(
                                color: SM_BACKGROUND_WHITE,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold),
                          ):Text(
                            'Edit minutes of meeting',
                            style: TextStyle(
                                color: SM_BACKGROUND_WHITE,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold),
                          ),
                        ):Container(),
                        cardData['minutesOfMeeting'] != null && cardData['minutesOfMeeting'].toString().trim() != "" ?Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.0,),
                            Text("Minutes Of Meeting:",style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(cardData['minutesOfMeeting'].toString().trim()),
                            SizedBox(height: 15.0,),
                          ],
                        ):Container(),
                      ],
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app_commons/utilities.dart';
import 'package:share_market/services/meetings_services.dart';

class EnterMinutesOfMeetingCard extends StatefulWidget {
  final DocumentSnapshot cardData;
  final int pageWidth;
  final String userRole;

  EnterMinutesOfMeetingCard({@required this.cardData,@required this.pageWidth,@required this.userRole});

  @override
  _EnterMinutesOfMeetingCardState createState() => _EnterMinutesOfMeetingCardState(cardData:cardData,pageWidth:pageWidth,userRole:userRole);
}

class _EnterMinutesOfMeetingCardState extends State<EnterMinutesOfMeetingCard> {
  final DocumentSnapshot cardData;
  final int pageWidth;
  final String userRole;

  _EnterMinutesOfMeetingCardState({@required this.cardData,@required this.pageWidth,@required this.userRole});
  final TextEditingController minutesOfMeetingController = TextEditingController();
  bool isSavingDetails = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(cardData["minutesOfMeeting"] != null && cardData["minutesOfMeeting"].toString().trim() != ""){
      minutesOfMeetingController.text = cardData["minutesOfMeeting"].toString();
    }
  }

  void saveMinutesOfMeeting(String meetId,bool minutesOfMeetingAlreadyExists) async{
    setState(() {
      isSavingDetails = true;
    });
    await MeetingsServices().addMinutesOfMeeting(meetId, minutesOfMeetingController.text.trim().toString()).then((value){
      setState(() {
        isSavingDetails = false;
      });
      Navigator.pop(context);
      if(value["isSuccess"]){
        Utilities().toastMessage(minutesOfMeetingAlreadyExists?"Successfully edited the minutes of meeting":"Successfully added the minutes of meeting", cursorColour, Icons.done, pageWidth, context);
      }else{
        Utilities().toastMessage("Oops! Something went wrong. Please try again.", ERROR_RED, Icons.error, pageWidth, context);
      }
    }).catchError((error){
      setState(() {
        isSavingDetails = false;
      });
      Utilities().toastMessage("$error", ERROR_RED, Icons.error, pageWidth, context);
    }).onError((error, stackTrace){
      setState(() {
        isSavingDetails = false;
      });
      Utilities().toastMessage("$error", ERROR_RED, Icons.error, pageWidth, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shadowColor: SM_ORANGE,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cardData["minutesOfMeeting"] == null || cardData["minutesOfMeeting"].toString().trim() == ""?Text(
                        'Add Minutes of Meeting',
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ):Text(
                        'Edit Minutes of Meeting',
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          icon: Icon(Icons.cancel_outlined),
                          onPressed: (){
                            Navigator.pop(context);
                          })
                    ],
                  ),
                  SizedBox(height: 10,),
                  AhCrmTextField(
                    context: context,
                    nextFocusNode: null,
                    currentFocusNode: null,
                    title: null,
                    controller: minutesOfMeetingController,
                    formDataMapKey: null,
                    keyboardTypeDone: false,
                    isEmailField: true,
                    isNumberKeyboard: false,
                    isMandatoryField: true,
                    formData: null,
                    maxLines: 10,
                    isPaddingNeeded: false,
                    defaultTextFieldWidth: false,
                  ),
                  SizedBox(height: 30,),
                  Container(
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: cursorColour,
                        padding: EdgeInsets.all(18.0),
                      ),
                      onPressed: () {
                        saveMinutesOfMeeting(cardData.documentID.trim(),cardData["minutesOfMeeting"] == null || cardData["minutesOfMeeting"].toString().trim() == ""?false:true);
                      },
                      child: isSavingDetails?Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                                SM_BACKGROUND_WHITE),
                          ),
                        ),
                      ):Text("Save Minutes of Meeting",
                        style: TextStyle(
                            color: SM_BACKGROUND_WHITE,
                            fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_market/app/modules/meet_page/enter_minutes_of_meeting.dart';
import 'package:share_market/app/modules/meet_page/view_meet_details_card.dart';
import 'package:share_market/app/modules/meet_page/view_more_text.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/services/meetings_services.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import '../../../app_commons/constants.dart';

class MeetPage extends StatefulWidget {
  final Map dataSend;

  MeetPage({@required this.dataSend});

  @override
  _MeetPageState createState() => _MeetPageState(dataSend: dataSend);
}

class _MeetPageState extends State<MeetPage> {
  final Map dataSend;

  _MeetPageState({@required this.dataSend});

  var width;
  var height;
  var imageByte;

  TimeOfDay startTime;
  TimeOfDay endTime;
  Function() callRefresh;

  js.JsObject _connector;
  html.IFrameElement _element;
  String elementName;

  set start(TimeOfDay startTime) {
    this.startTime = startTime;
  }

  set end(TimeOfDay endTime) {
    this.endTime = endTime;
  }

  Map<String, String> get getData {
    Map<String, String> data = {
      "starting_time": getTime(startTime),
      "ending_time": getTime(endTime)
    };
    return data;
  }

  String getTime(TimeOfDay timeOfDay) {
    DateTime d = DateTime.now();
    return DateTime(d.year, d.month, d.day, timeOfDay.hour, timeOfDay.minute)
        .toString();
  }

  @override
  void initState() {
    super.initState();
    elementName = UniqueKey().toString();
    callRefresh = this.refresh;
    if (startTime == null) startTime = TimeOfDay(hour: 9, minute: 0);
    if (endTime == null) endTime = TimeOfDay(hour: 17, minute: 0);
  }

  void refresh() {
    setState(() {});
  }

  showMessageDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController meetingLinkController = TextEditingController();
    final _fnMeetingDate = FocusNode();
    final format = new DateFormat("yyyy-MM-dd");
    Map<String, dynamic> formData = {};
    var imageName;
    var newImageUrl;
    bool isImageLoading = false;
    bool isSavingMeating = false;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          Future<Uri> uploadImageFile(image, {String imageName}) async {
            setState(() {
              isImageLoading = true;
            });
            fb.StorageReference storageRef =
                fb.storage().ref('eventImages/$imageName');
            fb.UploadTaskSnapshot uploadTaskSnapshot =
                await storageRef.put(image).future;
            Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
            setState(() {
              isImageLoading = false;
            });
            return imageUri;
          }

          Future<void> setImage() async {
            final completer = Completer<List<String>>();
            html.InputElement uploadInput = html.FileUploadInputElement();
            uploadInput.multiple = false;
            uploadInput.accept = 'image/*';
            uploadInput.click();
            //* onChange doesn't work on mobile safari
            uploadInput.addEventListener('change', (e) async {
              // read file content as dataURL
              final files = uploadInput.files;
              Iterable<Future<String>> resultsFutures = files.map((file) {
                final reader = html.FileReader();
                reader.readAsDataUrl(file);
                reader.onError
                    .listen((error) => completer.completeError(error));
                return reader.onLoad.first.then((_) {
                  setState(() {
                    imageByte = Base64Decoder()
                        .convert(reader.result.toString().split(",").last);
                  });
                  return reader.result as String;
                });
              });

              final results = await Future.wait(resultsFutures);
              completer.complete(results);
            });
            //* need to append on mobile safari
            html.document.body.append(uploadInput);
            final List<String> images = await completer.future;
            if (uploadInput.files.isEmpty) return;
            imageName = uploadInput.files[0].name;
            var url = await uploadImageFile(uploadInput.files[0],
                imageName: imageName);
            formData['eventImageUrl'] = url.toString();
            setState(() {
              newImageUrl = formData['eventImageUrl'];
            });
            uploadInput.remove();
          }

          _pickStartTime() async {
            TimeOfDay t =
                await showTimePicker(context: context, initialTime: startTime);
            if (t != null)
              setState(() {
                startTime = t;
              });
          }

          _pickEndTime() async {
            TimeOfDay t =
                await showTimePicker(context: context, initialTime: endTime);
            if (t != null)
              setState(() {
                endTime = t;
              });
          }

          Widget _timePicker(TimeOfDay time, bool isStart) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: SM_ORANGE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListTile(
                title: Text("${time.format(context)}"),
                trailing: Icon(Icons.access_time),
                onTap: isStart ? _pickStartTime : _pickEndTime,
              ),
            );
          }

          void toastMessage(String message, Color colour, IconData icon) {
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

          void saveMeeting() async {
            formData["title"] = titleController.text.trim();
            formData["meetingLink"] = meetingLinkController.text.trim();
            formData["isCancelled"] = false;
            if (formData["dateOfMeeting"] != null ||
                formData["dateOfMeeting"].toString().trim() == "") {
              DateTime dateTime = DateTime.parse(formData["dateOfMeeting"]);
              formData["startTime"] = new DateTime(
                  dateTime.year,
                  dateTime.month,
                  dateTime.day,
                  startTime.hour,
                  startTime.minute);
              formData["endTime"] = new DateTime(dateTime.year, dateTime.month,
                  dateTime.day, endTime.hour, endTime.minute);
              if (formData["title"] == null || formData["title"] == "") {
                toastMessage(
                    "Enter a title for the meeting", ERROR_RED, Icons.error);
              } else if (formData["meetingLink"] == null ||
                  formData["meetingLink"] == "") {
                toastMessage("Enter the meeting link", ERROR_RED, Icons.error);
              } else if (!isURL(formData["meetingLink"], requireTld: false)) {
                toastMessage(
                    "Enter a valid meeting link", ERROR_RED, Icons.error);
              } else if (formData["startTime"].toString().trim() == null ||
                  formData["startTime"].toString().trim() == "") {
                toastMessage("Enter a start time for the meeting", ERROR_RED,
                    Icons.error);
              } else if (formData["endTime"].toString().trim() == null ||
                  formData["endTime"].toString().trim() == "") {
                toastMessage(
                    "Enter a end time for the meeting", ERROR_RED, Icons.error);
              } else {
                setState(() {
                  isSavingMeating = true;
                });
                await MeetingsServices().addMeeting(formData).then((value) {
                  if (value["isSuccess"]) {
                    setState(() {
                      isSavingMeating = false;
                    });
                    Navigator.pop(context);
                    toastMessage("Added the meeting successfully", cursorColour,
                        Icons.done);
                  } else {
                    setState(() {
                      isSavingMeating = false;
                    });
                    toastMessage(
                        "Oops! Something went wrong. Please try again.",
                        ERROR_RED,
                        Icons.error);
                  }
                }).catchError((error) {
                  setState(() {
                    isSavingMeating = false;
                  });
                  toastMessage("Oops! Something went wrong. Please try again.",
                      ERROR_RED, Icons.error);
                });
              }
            } else {
              toastMessage("Enter the meeting date", ERROR_RED, Icons.error);
            }
          }

          return Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(cardBorderRadius)),
                    ),
                    width: width > 450 ? width / 3 : width,
//                height: width > 450? null:height*0.8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        newImageUrl == null
                            ? Container(
                                height: 200,
                                width: width,
                                margin: EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(cardBorderRadius)),
                                    color: Colors.orange[50],
                                    border: Border.all(color: SM_ORANGE)),
                                // button color
                                child: isImageLoading
                                    ? Center(
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    SM_ORANGE),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        child: SizedBox(
                                            width: width,
                                            height: 200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 50,
                                                  color: Colors.black54,
                                                ),
                                                Text(
                                                  "Add Image",
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                )
                                              ],
                                            )),
                                        onTap: () {
                                          setImage();
                                        },
                                      ),
                              )
                            : InkWell(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(
                                      width: width,
                                      height: 200,
                                      child: Image.memory(
                                        imageByte,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                onTap: () {
                                  setImage();
                                },
                              ),
                        AhCrmTextField(
                          context: context,
                          nextFocusNode: null,
                          currentFocusNode: null,
                          title: "Title",
                          controller: titleController,
                          formDataMapKey: null,
                          keyboardTypeDone: false,
                          isEmailField: true,
                          isNumberKeyboard: false,
                          isMandatoryField: true,
                          formData: null,
                          maxLines: 1,
                          isPaddingNeeded: false,
                          defaultTextFieldWidth: false,
                        ),
                        AhCrmTextField(
                          context: context,
                          nextFocusNode: null,
                          currentFocusNode: null,
                          title: "Meeting link",
                          controller: meetingLinkController,
                          formDataMapKey: null,
                          keyboardTypeDone: false,
                          isEmailField: true,
                          isNumberKeyboard: false,
                          isMandatoryField: true,
                          formData: null,
                          maxLines: 1,
                          isPaddingNeeded: false,
                          defaultTextFieldWidth: false,
                        ),
                        SizedBox(height: 5.0),
                        DateTimeField(
                          style: TextStyle(color: SM_BLACK),
                          focusNode: _fnMeetingDate,
                          format: format,
                          onChanged: (value) {
                            formData["dateOfMeeting"] = value.toIso8601String();
                          },
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            formData["dateOfMeeting"] = value.toIso8601String();
                          },
                          decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.black54,
                              ),
                              labelText: 'Meeting date',
                              labelStyle: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w300),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: SM_ORANGE,
                              ))),
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                initialDate: DateTime.now(),
                                lastDate: DateTime(2100));
                          },
                        ),
                        SizedBox(height: 7.0),
//                        Flexible(
//                          child: _timePicker(startTime, true),
//                        ),
                        width > 450
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        " From",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      SizedBox(height: 2.0),
                                      Container(
                                        width: width / 8,
                                        height: 50,
                                        child: _timePicker(startTime, true),
                                      ),
                                    ],
                                  ),
                                  Text(" - "),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        " To",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      SizedBox(height: 2.0),
                                      Container(
                                          width: width / 8,
                                          height: 50,
                                          child: _timePicker(endTime, false))
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    " From",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 2.0),
                                  Flexible(
                                    child: _timePicker(startTime, true),
                                  ),
                                  SizedBox(height: 7.0),
                                  Text(
                                    " To",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 2.0),
                                  Flexible(child: _timePicker(endTime, false))
                                ],
                              ),
                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16.0),
                                )),
                            SizedBox(width: 15.0),
                            Container(
                              width: 125,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: SM_ORANGE,
                                    padding: EdgeInsets.all(18.0),
                                  ),
                                  onPressed:
                                      isImageLoading ? null : saveMeeting,
                                  child: !isSavingMeating
                                      ? Text("Save Meeting",
                                          style: TextStyle(
                                              color: SM_BACKGROUND_WHITE,
                                              fontSize: 16.0))
                                      : Center(
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
                                        )),
                            ),
                          ],
                        ),
//                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: dataSend['role'] == 'admin'
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                showMessageDialog(context);
              },
              label: Text(
                ' ADD MEETING',
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
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [SizedBox(height: 30), meetingPageBody()],
          ),
        ),
      ),
      backgroundColor: backgroundOrangeColour,
    );
  }

  //***************************************LIST OF MEETINGS*********************************************************************

  Widget meetingPageBody() {
    DateTime currentTime = DateTime.now();
    return StreamBuilder(
        stream: Firestore.instance
            .collection("meetings")
            .where("endTime", isGreaterThan: currentTime)
            .where("isCancelled", isEqualTo: false)
            .orderBy('endTime')
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
            return listOfMeetings(meetingsList);
          }
        });
  }

  Widget listOfMeetings(List<DocumentSnapshot> meetings) {
    // return ListView.builder(
    //     physics: NeverScrollableScrollPhysics(),
    //     shrinkWrap: true,
    //     itemCount: meetings.length,
    //     itemBuilder: (BuildContext context, double index) {
    //       return meetingCard(meetings[index]);
    //     });
    //
    return Center(
        child: Wrap(
            spacing: 50.0,
            runSpacing: 20.0,
            children: meetings.map((e) => meetingCard(e)).toList()));
  }

  Widget meetingCard(DocumentSnapshot data) {
    return Card(
      shadowColor: SM_ORANGE,
      margin: EdgeInsets.all(10),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        // height: 150,
        height: 515,
        width: width < 401 ? width : 400,
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 200,
                  child: data["eventImageUrl"] != null
                      ? Image.network(
                          data["eventImageUrl"].toString(),
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        )
                      : Image.asset("assets/images/logo.png"),
                  color: Colors.transparent,
                )),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data["title"],
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
                          .format(DateTime.parse(data["dateOfMeeting"])),
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
                      "${DateFormat('hh:mm a').format(DateTime.parse(data["startTime"].toDate().toString()))} - ${DateFormat('hh:mm a').format(DateTime.parse(data["endTime"].toDate().toString()))}",
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
                    dataSend['role'] == 'admin'
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: SM_RED,
                              padding: EdgeInsets.all(18.0),
                            ),
                            onPressed: () async {
                              await MeetingsServices()
                                  .cancelMeeting(data.documentID)
                                  .then((value) {
                                if (value["isSuccess"]) {
                                  // setState(() {
                                  //   isSavingMeating = false;
                                  // });
                                  toastMessage(
                                      "Cancelled the meeting successfully",
                                      cursorColour,
                                      Icons.done);
                                } else {
                                  // setState(() {
                                  //   isSavingMeating = false;
                                  // });
                                  toastMessage(
                                      "Oops! Something went wrong. Please try again.",
                                      ERROR_RED,
                                      Icons.error);
                                }
                              }).catchError((error) {
                                // setState(() {
                                //   isSavingMeating = false;
                                // });
                                toastMessage(
                                    "Oops! Something went wrong. Please try again.",
                                    ERROR_RED,
                                    Icons.error);
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
                        var uri = data["meetingLink"];
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
                dataSend['role'] == 'admin'
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: cursorColour,
                          padding: EdgeInsets.all(18.0),
                        ),
                        onPressed: () {
                          showEnterMinutesOfMeetingCard(context, data, width,
                              dataSend["role"].toString());
                        },
                        child: data["minutesOfMeeting"] == null ||
                                data["minutesOfMeeting"].toString().trim() == ""
                            ? Text(
                                'Add minutes of meeting',
                                style: TextStyle(
                                    color: SM_BACKGROUND_WHITE,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Edit minutes of meeting',
                                style: TextStyle(
                                    color: SM_BACKGROUND_WHITE,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold),
                              ),
                      )
                    : Container(),
                data['minutesOfMeeting'] != null &&
                        data['minutesOfMeeting'].toString().trim() != ""
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Minutes Of Meeting:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ExpandableText(
                              data['minutesOfMeeting'].toString().trim(),
                              data,
                              width,
                              dataSend["role"].toString()),
                        ],
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showMeetingDetailsPopUp(BuildContext context, DocumentSnapshot data,
      double width, String userRole) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ViewMeetDetailsCard(
              cardData: data, pageWidth: width, userRole: userRole);
        });
  }

  showEnterMinutesOfMeetingCard(BuildContext context, DocumentSnapshot data,
      double width, String userRole) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return EnterMinutesOfMeetingCard(
              cardData: data, pageWidth: width, userRole: userRole);
        });
  }

  void toastMessage(String message, Color colour, IconData icon) {
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
                  color: SM_BACKGROUND_WHITE, fontWeight: FontWeight.w600),
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

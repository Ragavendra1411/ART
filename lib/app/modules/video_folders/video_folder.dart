import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app/modules/videos/videos.dart';
import 'package:share_market/app_commons/sm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/services/video_services.dart';

class VideoFoldersPage extends StatefulWidget {
  final Map dataSend;

  VideoFoldersPage({@required this.dataSend});
  @override
  _VideoFoldersPageState createState() =>
      _VideoFoldersPageState(dataSend: dataSend);
}

class _VideoFoldersPageState extends State<VideoFoldersPage> {

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  final Map dataSend;
  double width;
  bool isSavingFolder = false;
  TextEditingController folderTitleController = TextEditingController();
  _VideoFoldersPageState({@required this.dataSend});
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: dataSend['role'] == 'Admin' ||
              dataSend['role'] == 'Professional'
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                showMessageDialog(context, false, null);
              },
              label: Text(
                ' ADD FOLDER',
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
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [SizedBox(height: 30), meetingPageBody()],
          ),
        ),
      ),
    );
  }

  showMessageDialog(
      BuildContext context, bool isEdit, DocumentSnapshot data) async {
    folderTitleController.text = isEdit ? data["name"] : "";

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    width: width > 450 ? width / 3 : width,
                    // height: 200,
                    child: Column(
                      children: [
                        Container(
                            height: 100,
                            width: 100,
                            child: Image.asset('assets/images/folderIcon.png')),
                        SizedBox(
                          height: 20,
                        ),
                        // Text("FolderName"),
                        SMTextField(
                          context: context,
                          nextFocusNode: null,
                          currentFocusNode: null,
                          title: "Folder Name",
                          controller: folderTitleController,
                          formDataMapKey: null,
                          keyboardTypeDone: false,
                          isEmailField: false,
                          isNumberKeyboard: false,
                          isMandatoryField: true,
                          formData: null,
                          maxLines: 1,
                          isPaddingNeeded: false,
                          defaultTextFieldWidth: false,
                        ),
                        SizedBox(
                          height: 20,
                        ),
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
                                  onPressed: () async {
                                    if (folderTitleController.text.isEmpty) {
                                      toastMessage("Enter a folder name",
                                          ERROR_RED, Icons.error);
                                    } else {
                                      setState(() {
                                        isSavingFolder = true;
                                      });
                                      bool folderExists =
                                          await checkIfFolderAldreadyExists();
                                      print("FOLDER EXISTS $folderExists");
                                      if (folderExists == true) {
                                        setState(() {
                                          isSavingFolder = false;
                                        });
                                        toastMessage("Folder already exists",
                                            ERROR_RED, Icons.error);
                                      } else {
                                        Map<String, dynamic> folderDetails = {
                                          "name":
                                              folderTitleController.text.trim(),
                                          "listOfVideos": [],
                                          "createdDate": DateTime.now()
                                              .millisecondsSinceEpoch,
                                          "isDeleted": false
                                        };
                                        print("FOLDER $folderDetails");

                                        isEdit
                                            ? await VideoServices()
                                                .renameFolder(
                                                    folderTitleController.text
                                                        .trim(),
                                                    data.documentID)
                                                .then((value) {
                                                print(
                                                    "VALUE.ISSUCCESS ${value["isSuccess"]}");
                                                if (value["isSuccess"]) {
                                                  setState(() {
                                                    isSavingFolder = false;
                                                  });
                                                  Navigator.pop(context);
                                                  toastMessage(
                                                      "Renamed the folder successfully",
                                                      cursorColour,
                                                      Icons.done);
                                                } else {
                                                  setState(() {
                                                    isSavingFolder = false;
                                                  });
                                                  toastMessage(
                                                      "Oops! Something went wrong. ",
                                                      ERROR_RED,
                                                      Icons.error);
                                                }
                                              }).catchError((error) {
                                                print("ERROR IS $error");
                                                setState(() {
                                                  isSavingFolder = false;
                                                });
                                                toastMessage(
                                                    "Oops! Something went wrong. Please try again.",
                                                    ERROR_RED,
                                                    Icons.error);
                                              })
                                            : await VideoServices()
                                                .addFolder(
                                                    folderTitleController.text
                                                        .trim(),
                                                    folderDetails)
                                                .then((value) {
                                                print(
                                                    "VALUE.ISSUCCESS ${value["isSuccess"]}");
                                                if (value["isSuccess"]) {
                                                  setState(() {
                                                    isSavingFolder = false;
                                                  });
                                                  Navigator.pop(context);
                                                  toastMessage(
                                                      "Added the folder successfully",
                                                      cursorColour,
                                                      Icons.done);
                                                } else {
                                                  setState(() {
                                                    isSavingFolder = false;
                                                  });
                                                  toastMessage(
                                                      "Oops! Something went wrong. ",
                                                      ERROR_RED,
                                                      Icons.error);
                                                }
                                              }).catchError((error) {
                                                print("ERROR IS $error");
                                                setState(() {
                                                  isSavingFolder = false;
                                                });
                                                toastMessage(
                                                    "Oops! Something went wrong. Please try again.",
                                                    ERROR_RED,
                                                    Icons.error);
                                              });
                                      }
                                    }
                                  },
                                  child: !isSavingFolder
                                      ? Text(isEdit ? "Rename" : "Save Folder",
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  showDeleteDialog(BuildContext context, DocumentSnapshot data) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    width: width > 450 ? width / 3 : width,
                    // height: 200,
                    child: Column(
                      children: [
                        Container(
                            height: 100,
                            width: 100,
                            child: Image.asset('assets/images/folderIcon.png')),
                        Text(data["name"]),
                        SizedBox(
                          height: 20,
                        ),
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
                                    primary: Colors.red,
                                    padding: EdgeInsets.all(18.0),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isSavingFolder = true;
                                    });

                                    await VideoServices()
                                        .deleteFolder(data.documentID)
                                        .then((value) {
                                      print(
                                          "VALUE.ISSUCCESS ${value["isSuccess"]}");
                                      if (value["isSuccess"]) {
                                        setState(() {
                                          isSavingFolder = false;
                                        });
                                        Navigator.pop(context);
                                        toastMessage(
                                            "Deleted the folder successfully",
                                            cursorColour,
                                            Icons.done);
                                      } else {
                                        setState(() {
                                          isSavingFolder = false;
                                        });
                                        toastMessage(
                                            "Oops! Something went wrong. ",
                                            ERROR_RED,
                                            Icons.error);
                                      }
                                    }).catchError((error) {
                                      print("ERROR IS $error");
                                      setState(() {
                                        isSavingFolder = false;
                                      });
                                      toastMessage(
                                          "Oops! Something went wrong. Please try again.",
                                          ERROR_RED,
                                          Icons.error);
                                    });
                                  },
                                  child: !isSavingFolder
                                      ? Text("Delete Folder",
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
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

  Future<bool> checkIfFolderAldreadyExists() async {
    bool val;
    await VideoServices()
        .checkIfFolderExists(folderTitleController.text.trim())
        .then((value) {
      print("VALUE INSIDE FUNCTION $value");
      val = value;
    });
    return val;
    // return true;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget meetingPageBody() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("videoFolders")
            .where("isDeleted", isEqualTo: false)
            .orderBy('createdDate')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading'));
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text('No data available'));
          }

          List foldersList;
          // snapshot.data.documents.foreach((meeting) {
          //   meetingsList += meeting;
          // });
          foldersList = snapshot.data.documents;

          if (foldersList.length == 0) {
            return Center(child: Text("No folders added yet"));
          } else {
            return listOfFolders(foldersList);
          }
        });
  }

  Widget listOfFolders(List<DocumentSnapshot> meetings) {
    return width > 400
        ? Wrap(
            spacing: 20.0,
            runSpacing: 20.0,
            children: meetings.map((e) => folderCard(e)).toList())
        : Center(
            child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: meetings.map((e) => folderCard(e)).toList()));
  }

  Widget folderCard(DocumentSnapshot data) {
    return GestureDetector(
      onSecondaryTap:
          dataSend['role'] == 'Admin' || dataSend['role'] == 'Professional'
              ? () {
                  print("Right clcik");
                  showRightPressDialog(context, data);
                }
              : null,
      onTap: width < 400
          ? () {
              print("FOLDER OPENED");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideosPage(
                          dataSend: dataSend,
                          folderData: data,
                        )),
              );
            }
          : null,
      onDoubleTap: width < 400
          ? null
          : () {
              print("FOLDER OPENED");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideosPage(
                          dataSend: dataSend,
                          folderData: data,
                        )),
              );
            },
      child: Container(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 70,
                height: 70,
                child: Image.asset('assets/images/folderIcon.png')),
            SizedBox(height: 10),
            Text(
              data["name"],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  showRightPressDialog(BuildContext context, DocumentSnapshot data) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  width: width > 400 ? 300 : width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            showMessageDialog(context, true, data);
                          },
                          child: Text("Rename folder")),
                      Divider(),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            showDeleteDialog(context, data);
                          },
                          child: Text("Delete folder",
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

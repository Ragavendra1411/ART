import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:share_market/services/document_services.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class DocumentsPage extends StatefulWidget {
  final Map dataSend;
  final DocumentSnapshot folderData;

  DocumentsPage({@required this.dataSend, @required this.folderData});
  @override
  _DocumentsPageState createState() =>
      _DocumentsPageState(dataSend: dataSend, folderData: folderData);
}

class _DocumentsPageState extends State<DocumentsPage> {
  final Map dataSend;
  final DocumentSnapshot folderData;
  bool isVideoLoading = false;
  bool isSavingVideo = false;
  bool isSavingFolder = false;

  String documentUrl;
  var imageByte;
  var videoName;

  TextEditingController titleController = TextEditingController();
  var width;
  _DocumentsPageState({@required this.dataSend, @required this.folderData});
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(folderData["name"]),
        backgroundColor: backgroundOrangeColour,
      ),
      floatingActionButton: dataSend['role'] == 'Admin' ||
              dataSend['role'] == 'Professional'
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                showMessageDialog(context);
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
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [SizedBox(height: 30), meetingPageBody()],
          ),
        ),
      ),
    );
  }

  showMessageDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            Future<Uri> uploadImageFile(image, {String imageName}) async {
              setState(() {
                isVideoLoading = true;
              });
              fb.StorageReference storageRef = fb
                  .storage()
                  .ref('documents/${folderData["name"]}/$imageName');
              fb.UploadTaskSnapshot uploadTaskSnapshot =
                  await storageRef.put(image).future;
              Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
              setState(() {
                isVideoLoading = false;
              });
              return imageUri;
            }

            Future<void> setImage() async {
              final completer = Completer<List<String>>();
              html.InputElement uploadInput = html.FileUploadInputElement();
              uploadInput.multiple = false;
              uploadInput.accept = 'application/pdf';
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
              videoName = uploadInput.files[0].name;
              var url = await uploadImageFile(uploadInput.files[0],
                  imageName: videoName);
              // formData['eventImageUrl'] = url.toString();
              setState(() {
                documentUrl = url.toString();
              });
              uploadInput.remove();
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
                        documentUrl == null
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
                                child: isVideoLoading
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
                                                  Icons.file_copy,
                                                  size: 50,
                                                  color: Colors.black54,
                                                ),
                                                Text(
                                                  "Add Document",
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
                            : Container(
                                height: 200,
                                width: width,
                                margin: EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(cardBorderRadius)),
                                    color: Colors.orange[50],
                                    border: Border.all(color: SM_ORANGE)),
                                // button color
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Document upload completed")
                                    ],
                                  ),
                                )),
                        SizedBox(
                          height: 20,
                        ),
                        // Text("FolderName"),
                        AhCrmTextField(
                          context: context,
                          nextFocusNode: null,
                          currentFocusNode: null,
                          title: "Document title",
                          controller: titleController,
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
                              width: 150,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: SM_ORANGE,
                                    padding: EdgeInsets.all(18.0),
                                  ),
                                  onPressed: isVideoLoading
                                      ? null
                                      : () {
                                          if (documentUrl == null) {
                                            toastMessage("Add a document",
                                                SM_RED, Icons.error);
                                          } else if (titleController
                                              .text.isEmpty) {
                                            toastMessage("Add a title", SM_RED,
                                                Icons.error);
                                          } else {
                                            setState(() {
                                              isSavingVideo = true;
                                            });
                                            Map<String, dynamic> videoData = {
                                              "title":
                                                  titleController.text.trim(),
                                              "url": documentUrl,
                                              "createdDate": DateTime.now()
                                                  .millisecondsSinceEpoch
                                            };
                                            DocumentServices()
                                                .addDocument(
                                                    folderData.documentID,
                                                    videoData)
                                                .then((value) {
                                              print(
                                                  "VALUE.ISSUCCESS ${value["isSuccess"]}");
                                              if (value["isSuccess"]) {
                                                setState(() {
                                                  isSavingVideo = false;
                                                });
                                                Navigator.pop(context);
                                                toastMessage(
                                                    "Added the document successfully",
                                                    cursorColour,
                                                    Icons.done);
                                              } else {
                                                setState(() {
                                                  isSavingVideo = false;
                                                });
                                                toastMessage(
                                                    "Oops! Something went wrong. ",
                                                    ERROR_RED,
                                                    Icons.error);
                                              }
                                            }).catchError((error) {
                                              print("ERROR IS $error");
                                              setState(() {
                                                isSavingVideo = false;
                                              });
                                              toastMessage(
                                                  "Oops! Something went wrong. Please try again.",
                                                  ERROR_RED,
                                                  Icons.error);
                                            });
                                          }
                                        },
                                  child: isSavingVideo
                                      ? Center(
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
                                        )
                                      : Text("Save Document",
                                          style: TextStyle(
                                              color: SM_BACKGROUND_WHITE,
                                              fontSize: 16.0))),
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

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget meetingPageBody() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("documents")
            .where("folderId", isEqualTo: folderData.documentID).where("isDeleted",isEqualTo: false)
            .orderBy("createdDate")
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
            return Center(child: Text("No documents added yet"));
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
      onTap: () async {
        //  Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => DocumentView(url: data["url"],)),
        //   );
        var uri = data["url"];
        if (await canLaunch(uri)) {
          await launch(uri);
        } else {
          throw 'Could not launch $uri';
        }
      },
      child: Container(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 70,
                height: 70,
                child: Image.asset('images/documentIcon.png')),
            SizedBox(height: 10),
            Text(
              data["title"],
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
                            // showMessageDialog(context, true, data);
                            showEditDialog(context, data);
                          },
                          child: Text("Rename document")),
                      Divider(),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            showDeleteDialog(context, data);
                          },
                          child: Text("Delete document",
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ),
          );
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
                            child: Image.asset('assets/images/documentIcon.png')),
                        Text(data["title"]),
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
                              width: 150,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    padding: EdgeInsets.all(18.0),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isSavingFolder = true;
                                    });

                                    await DocumentServices()
                                        .deleteDocument(data.documentID,folderData.documentID)
                                        .then((value) {
                                      print(
                                          "VALUE.ISSUCCESS ${value["isSuccess"]}");
                                      if (value["isSuccess"]) {
                                        setState(() {
                                          isSavingFolder = false;
                                        });
                                        Navigator.pop(context);
                                        toastMessage(
                                            "Deleted the document successfully",
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
                                      ? Text("Delete Document",
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

  Future<bool> checkIfDocumentExists() async {
    bool val;
    await DocumentServices()
        .checkIfDocumentExists(titleController.text.trim())
        .then((value) {
      print("VALUE INSIDE FUNCTION $value");
      val = value;
    });
    return val;
    // return true;
  }

    showEditDialog(BuildContext context, DocumentSnapshot data) async {
    titleController.text = data["title"];
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
                            child: Image.asset('assets/images/documentIcon.png')),
                        SizedBox(
                          height: 20,
                        ),
                        // Text("FolderName"),
                        AhCrmTextField(
                          context: context,
                          nextFocusNode: null,
                          currentFocusNode: null,
                          title: "Video Name",
                          controller: titleController,
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
                                    if (titleController.text.isEmpty) {
                                      toastMessage("Enter a document name",
                                          ERROR_RED, Icons.error);
                                    } else {
                                      setState(() {
                                        isSavingFolder = true;
                                      });
                                      bool folderExists =
                                          await checkIfDocumentExists();
                                      print("FOLDER EXISTS $folderExists");
                                      if (folderExists == true) {
                                        setState(() {
                                          isSavingFolder = false;
                                        });
                                        toastMessage("Document already exists",
                                            ERROR_RED, Icons.error);
                                      } else {
                                        await DocumentServices()
                                            .renameDocument(
                                                titleController.text.trim(),
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
                                                "Renamed the document successfully",
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
                                      ? Text("Rename",
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
}

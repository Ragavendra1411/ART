import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/material.dart';
import 'package:share_market/app/modules/forums/expandable_desc.dart';
import 'package:share_market/app/modules/forums/view_forum.dart';
import 'package:share_market/app/modules/meet_page/view_more_text.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/services/forum_services.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

class ForumsMainPage extends StatefulWidget {
  final Map dataSend;

  ForumsMainPage({@required this.dataSend});

  @override
  _ForumsMainPageState createState() =>
      _ForumsMainPageState(dataSend: dataSend);
}

class _ForumsMainPageState extends State<ForumsMainPage> {
  final Map dataSend;

  _ForumsMainPageState({@required this.dataSend});

  var width;
  var height;
  var imageByte;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                showMessageDialog(context, false, null);
              },
              label: Text(
                ' ADD FORUM',
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
            children: [SizedBox(height: 30), forumPageBody()],
          ),
        ),
      ),
      backgroundColor: backgroundOrangeColour,
    );
  }

  forumPageBody() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("forums")
            .where("isDeleted", isEqualTo: false)
            .orderBy('createdAt',descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading'));
          }
          if (snapshot.hasError) {
            print("ERROR IS ${snapshot.error}");
            return Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text('No data available'));
          }

          List forumsList;
          forumsList = snapshot.data.documents;

          if (forumsList.length == 0) {
            return Center(child: Text("No Forums found"));
          } else {
            return listOfForums(forumsList);
          }
        });
  }

  Widget listOfForums(List<DocumentSnapshot> meetings) {
    return Center(
        child: Wrap(
            spacing: 50.0,
            runSpacing: 20.0,
            children: meetings.map((e) => forumCard(e)).toList()));
  }

  Widget forumCard(DocumentSnapshot data) {
    return InkWell(
      child: Card(
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
          height: 480,
          width: width < 401 ? width : 400,
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    height: 200,
                    child: data["forumImageUrl"] != null
                        ? Image.network(
                      data["forumImageUrl"].toString(),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dataSend['role'] == 'admin'
                          ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: SM_RED,
                          padding: EdgeInsets.all(18.0),
                        ),
                        onPressed: () async {
                          await ForumServices()
                              .deleteForums(data.documentID)
                              .then((value) {
                            if (value["isSuccess"]) {
                              // setState(() {
                              //   isSavingMeating = false;y
                              // });
                              toastMessage("Deleted the forum successfully",
                                  cursorColour, Icons.done);
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text(
                              ' Delete Forum ',
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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
                          showMessageDialog(context, true, data);
                          // var uri = data["meetingLink"];
                          // if (await canLaunch(uri)) {
                          //   await launch(uri);
                          // } else {
                          //   throw 'Could not launch $uri';
                          // }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            Text(
                              ' Edit Forum ',
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  data['description'] != null &&
                      data['description'].toString().trim() != ""
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Description:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ExpandableTextForum(
                          data['description'].toString().trim(),
                          data,
                          width,
                          dataSend["role"].toString()),
                    ],
                  )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Text('Click here to view the article',style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue
                    ),),
                    onTap: () async {
                      var uri = data["forumLink"];
                      if (await canLaunch(uri)) {
                        await launch(uri);
                      } else {
                        throw 'Could not launch $uri';
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewForum(data: data, dataSend: dataSend)),
        );
      },
    );
  }

  showMessageDialog(
      BuildContext context, bool edit, DocumentSnapshot dataEdit) async {
    Map<String, dynamic> formData = {};
    var imageName;
    var newImageUrl;
    bool imageStatus = false;
    bool isImageLoading = false;
    bool isSavingMeating = false;
    final TextEditingController titleController = TextEditingController();
    final TextEditingController urlLinkController = TextEditingController();
    final TextEditingController forumDescController = TextEditingController();
    if (edit) {
      titleController.text = dataEdit['title'];
      urlLinkController.text = dataEdit['forumLink'];
      forumDescController.text = dataEdit['description'];
      formData['forumImageUrl'] = dataEdit['forumImageUrl'];
      imageStatus =
          dataEdit['forumImageUrl'] != null && dataEdit['forumImageUrl'] != '';
    }

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
                fb.storage().ref('forumImages/$imageName');
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
            formData['forumImageUrl'] = url.toString();
            setState(() {
              newImageUrl = formData['forumImageUrl'];
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

          void _setState(bool status) {
            setState(() {
              isSavingMeating = status;
            });
          }

          void saveMeeting() async {
            if (titleController.text.trim().length == 0 ||
                urlLinkController.text.trim().length == 0 ||
                forumDescController.text.trim().length == 0) {
              toastMessage("Enter all the fields.", ERROR_RED, Icons.error);
            } else if (!isURL(urlLinkController.text.trim(),
                requireTld: false)) {
              toastMessage("Enter a valid forum link", ERROR_RED, Icons.error);
            } else {
              formData["title"] = titleController.text.trim();
              formData["forumLink"] = urlLinkController.text.trim();
              formData['description'] = forumDescController.text.trim();
              formData["isDeleted"] = false;
              _setState(true);
              var docId = edit ? dataEdit.documentID : '';
              await ForumServices()
                  .addEditForums(formData, docId, edit)
                  .then((value) {
                if (value["isSuccess"]) {
                  setState(() {
                    isSavingMeating = false;
                  });
                  Navigator.pop(context);
                  toastMessage(
                      "${edit ? 'Updated' : 'Added'} the forum successfully",
                      cursorColour,
                      Icons.done);
                } else {
                  _setState(false);
                  toastMessage("Oops! Something went wrong. Please try again.",
                      ERROR_RED, Icons.error);
                }
              }).catchError((error) {
                _setState(false);
                toastMessage("Oops! Something went wrong. Please try again.",
                    ERROR_RED, Icons.error);
              });
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
                        !edit
                            ? newImageUrl == null
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
                                                    AlwaysStoppedAnimation<
                                                        Color>(SM_ORANGE),
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
                                                          color:
                                                              Colors.black54),
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
                                  )
                            : newImageUrl == null
                                ? !imageStatus
                                    ? Container(
                                        height: 200,
                                        width: width,
                                        margin: EdgeInsets.only(bottom: 10.0),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    cardBorderRadius)),
                                            color: Colors.orange[50],
                                            border:
                                                Border.all(color: SM_ORANGE)),
                                        // button color
                                        child: isImageLoading
                                            ? Center(
                                                child: SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(SM_ORANGE),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                child: SizedBox(
                                                    width: width,
                                                    height: 200,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                              color: Colors
                                                                  .black54),
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
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: SizedBox(
                                              width: width,
                                              height: 200,
                                              child: Image.network(
                                                formData['forumImageUrl'],
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        onTap: () {
                                          setImage();
                                        },
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
                          title: "Forum Title",
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
                          title: "Forum link",
                          controller: urlLinkController,
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
                          title: "Forum Descriptions",
                          controller: forumDescController,
                          formDataMapKey: null,
                          keyboardTypeDone: false,
                          isEmailField: true,
                          isNumberKeyboard: false,
                          isMandatoryField: true,
                          formData: null,
                          maxLines: 10,
                          isPaddingNeeded: true,
                          defaultTextFieldWidth: false,
                        ),
                        SizedBox(height: 5.0),
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
                                      ? Text(
                                          "${edit ? 'Update' : 'Save'} Forum",
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

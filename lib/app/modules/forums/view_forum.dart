import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

import '../../../app_commons/sm_text_field.dart';
import '../../../app_commons/constants.dart';
import '../../../app_commons/utilities.dart';
import '../../../services/forum_services.dart';
import 'expandable_desc.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:universal_html/prefer_universal/html.dart' as html;

class ViewForum extends StatefulWidget {
  final DocumentSnapshot data;
  final Map dataSend;

  ViewForum({@required this.data, @required this.dataSend});

  @override
  _ViewForumState createState() =>
      _ViewForumState(data: data, dataSend: dataSend);
}

class _ViewForumState extends State<ViewForum> {
  final DocumentSnapshot data;
  final Map dataSend;
  var imageByte;
  bool showQuestionTextBox = false;
  bool showLoader = false;
  bool deleteSuccess = false;
  _ViewForumState({@required this.data, @required this.dataSend});

  var width;
  final TextEditingController questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionController.addListener(() {setState(() {});});
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
                                        color: backgroundOrangeColour,
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
                                                      color: black54,
                                                    ),
                                                    Text(
                                                      "Add Image",
                                                      style: TextStyle(
                                                          color:
                                                              black54),
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
                                            color: backgroundOrangeColour,
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
                                                          color: black54,
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

                        SMTextField(
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
                        SMTextField(
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
                        SMTextField(
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
                                      color: black54, fontSize: 16.0),
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

  showCommentCard(BuildContext context, DocumentSnapshot questionData) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final TextEditingController replyController = TextEditingController();
          bool showReplyLoader = false;

          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Container(
                        width: width > 401 ? 400 : width,
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(cardBorderRadius)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Q: ${questionData["question"]}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 350,
                                  child: SMTextField(
                                    context: context,
                                    nextFocusNode: null,
                                    currentFocusNode: null,
                                    title: "Add a reply",
                                    controller: replyController,
                                    formDataMapKey: null,
                                    keyboardTypeDone: false,
                                    isEmailField: true,
                                    isNumberKeyboard: false,
                                    isMandatoryField: true,
                                    formData: null,
                                    maxLines: 3,
                                    isPaddingNeeded: true,
                                    defaultTextFieldWidth: false,
                                  ),
                                ),
                                showReplyLoader
                                    ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  SM_ORANGE),
                                        ),
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: () {
                                          Map<String, dynamic> replyData = {
                                            "reply": replyController.text,
                                            "createdAt": DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            "updatedAt": DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            "userId": dataSend["userUid"],
                                            "userName": dataSend["userName"],
                                          };
                                          setState(() {
                                            showReplyLoader = true;
                                          });
                                          ForumServices()
                                              .addReplyFunction(
                                                  data.documentID.toString(),
                                                  questionData.documentID
                                                      .toString(),
                                                  replyData)
                                              .then((value) {
                                            if (!value["isError"]) {
                                              replyController.clear();
                                              setState(() {
                                                showReplyLoader = false;
                                              });
                                            } else {
                                              setState(() {
                                                showReplyLoader = false;
                                              });
                                              Utilities().toastMessage(
                                                  "Oops! Something went wrong. Please try again later.",
                                                  ERROR_RED,
                                                  Icons.error,
                                                  width,
                                                  context);
                                            }
                                          }).catchError((error) {
                                            setState(() {
                                              showReplyLoader = false;
                                            });
                                            print("error");
                                            Utilities().toastMessage(
                                                "Oops! Something went wrong. Please try again later.",
                                                ERROR_RED,
                                                Icons.error,
                                                width,
                                                context);
                                          });
                                        })
                              ],
                            ),
                            SizedBox(height: 10),
                            StreamBuilder(
                                stream: ForumServices().replyStream(
                                    data.documentID.toString(),
                                    questionData.documentID.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var repliesList = snapshot.data.documents;
                                    return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: repliesList.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              index == 0?SizedBox(
                                                height: 5,
                                              ):Container(),
                                              index == 0?Text(
                                                "Replies",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ):Container(),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text:
                                                              "${repliesList[index]["userName"]}: ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,color: Colors.black),
                                                        ),
                                                        TextSpan(
                                                          text: repliesList[
                                                              index]["reply"],
                                                          style: TextStyle(
                                                            color: Colors.black
                                                          )
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                            ],
                                          );
                                        });
                                  } else if (snapshot.hasData) {
                                    return Text("Error in loading comments");
                                  } else {
                                    return SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                SM_ORANGE),
                                      ),
                                    );
                                  }
                                }),
                            SizedBox(height: 30),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: SM_ORANGE,
                                  padding: EdgeInsets.all(18.0),
                                ),
                                child: Text("CLOSE",
                                    style: TextStyle(
                                        color: SM_WHITE,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        )),
                  ),
                ),
              ),
            );
          });
        });
  }

  confirmDelete(BuildContext context,DocumentSnapshot data) async{
    bool isDeleting = false;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, StateSetter setState){
              return AlertDialog(
                title: Text(
                  "Deleting a forum",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                content: Text(
                  "Are you sure you want to delete this forum?",
                  style: TextStyle(
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                elevation: 5.0,
                actions: <Widget>[
                  new TextButton(
                      child: new Text(
                        "Cancel",
                        style: TextStyle(
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(context);
                      }),
                  new ElevatedButton(
                      child: isDeleting? Center(
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<
                                Color>(SM_WHITE),
                          ),
                        ),
                      ):new Text(
                        "Delete",
                        style: TextStyle(
                          color: SM_WHITE,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: () async{
                        setState((){
                          isDeleting = true;
                        });
                        await ForumServices()
                            .deleteForums(data.documentID)
                            .then((value) {
                          setState((){
                            isDeleting = false;
                          });
                          if (value["isSuccess"]) {
                            deleteSuccess = true;
                            Navigator.pop(context);
                            Utilities().toastMessage(
                                "Deleted the forum successfully",
                                cursorColour,
                                Icons.done,
                                width,
                                context);
                            Future.delayed(Duration(seconds: 5),(){
                              Navigator.of(context,rootNavigator: true).pop();
                            });
                          } else {
                            Utilities().toastMessage(
                                "Oops! Something went wrong. Please try again.",
                                ERROR_RED,
                                Icons.error,
                                width,
                                context);
                          }
                        }).catchError((error) {
                          setState((){
                            isDeleting = false;
                          });
                          Utilities().toastMessage(
                              "Oops! Something went wrong. Please try again.",
                              ERROR_RED,
                              Icons.error,
                              width,
                              context);
                        });
                      }),
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundOrangeColour,
      body:StreamBuilder(
        stream: ForumServices().forumStream(data.documentID.toString()),
    builder: (context, snapshot) {
          if(snapshot.hasData){
            var forumData = snapshot.data;
            return  Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        // height: 150,
//              height: 480,
                        width: width < 401 ? width : 400,
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  height: 200,
                                  child: forumData["forumImageUrl"] != null
                                      ? Image.network(
                                    forumData["forumImageUrl"].toString(),
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  )
                                      : Image.asset("assets/images/logo.png"),
                                  color: Colors.transparent,
                                )),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                dataSend['role'] == 'Admin'
                                    ? IconButton(
                                  icon: Icon(Icons.delete,color:SM_GREY,),
                                  tooltip: "Delete forum",
                                  onPressed: () async{
                                    await confirmDelete(context,forumData);
                                    if(deleteSuccess){
                                      Navigator.of(context,rootNavigator: true).pop();
                                    }
                                  },

                                )
                                    : Container(),
                                SizedBox(width: 10),
                                dataSend["role"] == "Admin" || dataSend["role"] == "Professional"?IconButton(
                                  icon: Icon(Icons.edit,color: SM_GREY),
                                  tooltip: "Edit forum",
                                  onPressed: () async {
                                    showMessageDialog(context, true, forumData);
                                  },
                                ):Container(),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      forumData["title"],
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                forumData['description'] != null &&
                                    forumData['description'].toString().trim() != ""
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
                                    // ExpandableTextForum(
                                    //     forumData['description'].toString().trim(),
                                    //     forumData,
                                    //     width,
                                    //     dataSend["role"].toString()),

                                    forumData['description'] != null &&
                                        forumData['description'] != ''
                                        ? InkWell(
                                      onTap: (){
                                        showMeetingDetailsPopUp(
                                            context,
                                            forumData,
                                            width,
                                            dataSend["role"].toString());
                                      },
                                      child: Text(
                                        forumData['description'].toString().trim(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                        : Container()
                                  ],
                                )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  child: Text(
                                    'Click here to view the article',
                                    style: TextStyle(fontSize: 14, color: SM_BLUE),
                                  ),
                                  onTap: () async {
                                    var uri = forumData["forumLink"];
                                    if (await canLaunch(uri)) {
                                      await launch(uri);
                                    } else {
                                      throw 'Could not launch $uri';
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                showQuestionTextBox
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: width>401?320:width - 50,
                                      child: SMTextField(
                                        context: context,
                                        nextFocusNode: null,
                                        currentFocusNode: null,
                                        title: "Ask a question",
                                        controller: questionController,
                                        formDataMapKey: null,
                                        keyboardTypeDone: false,
                                        isEmailField: true,
                                        isNumberKeyboard: false,
                                        isMandatoryField: true,
                                        formData: null,
                                        maxLines: 3,
                                        isPaddingNeeded: true,
                                        defaultTextFieldWidth: false,
                                      ),
                                    ),
                                    showLoader
                                        ? SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            SM_ORANGE),
                                      ),
                                    )
                                        : IconButton(
                                        icon: questionController.text.isEmpty? Icon(Icons.cancel,color: SM_GREY,):Icon(Icons.send),
                                        onPressed: () {
                                          if(questionController.text.isEmpty){
                                            setState(() {
                                              showQuestionTextBox = false;
                                            });
                                          }else{
                                            Map<String, dynamic> questionData = {
                                              "question": questionController.text,
                                              "createdAt": DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              "updatedAt": DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              "replyCount": 0,
                                              "userId": dataSend["userUid"],
                                              "userName": dataSend["userName"],
                                            };
                                            setState(() {
                                              showLoader = true;
                                            });
                                            ForumServices()
                                                .askQuestionFunction(
                                                data.documentID.toString(),
                                                questionData)
                                                .then((value) {
                                              if (!value["isError"]) {
                                                questionController.clear();
                                                setState(() {
                                                  showLoader = false;
                                                  showQuestionTextBox = false;
                                                });
                                              } else {
                                                setState(() {
                                                  showLoader = false;
                                                });
                                                Utilities().toastMessage(
                                                    "Oops! Something went wrong. Please try again later.",
                                                    ERROR_RED,
                                                    Icons.error,
                                                    width,
                                                    context);
                                              }
                                            }).catchError((error) {
                                              setState(() {
                                                showLoader = false;
                                              });
                                              print("error");
                                              Utilities().toastMessage(
                                                  "Oops! Something went wrong. Please try again later.",
                                                  ERROR_RED,
                                                  Icons.error,
                                                  width,
                                                  context);
                                            });
                                          }
                                        })
                                  ],
                                )
                                    : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          showQuestionTextBox = true;
                                        });
                                      },
                                      child: Text("Ask a question",style: TextStyle(color: SM_GREY),),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                StreamBuilder(
                                    stream: ForumServices()
                                        .questionsStream(data.documentID.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var questionsList = snapshot.data.documents;
                                        return ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: questionsList.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Q",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                text:
                                                                "${questionsList[index]["userName"]}: ",
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                    fontWeight:
                                                                    FontWeight.bold),
                                                              ),
                                                              TextSpan(
                                                                text: questionsList[index]
                                                                ["question"],style: TextStyle(
                                                                color: Colors.black
                                                              )
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          children: [
                                                            InkWell(
                                                              onTap: questionsList[index]["replyCount"]==0?null:() {
                                                                showCommentCard(context,
                                                                    questionsList[index]);
                                                              },
                                                              child: Text("${questionsList[index]["replyCount"]} ${questionsList[index]["replyCount"]!=1?'replies':'reply'}",style: TextStyle(color: SM_GREY),),
                                                            ),
                                                            SizedBox(width: 10.0,),
                                                            InkWell(
                                                              onTap: () {
                                                                showCommentCard(context,
                                                                    questionsList[index]);
                                                              },
                                                              child: Text(
                                                                'Reply',
                                                                style: TextStyle(
                                                                  color: SM_GREY,
                                                                  decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              );
                                            });
                                      } else if (snapshot.hasData) {
                                        return Text("Error in loading comments");
                                      } else {
                                        return SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                            AlwaysStoppedAnimation<Color>(SM_ORANGE),
                                          ),
                                        );
                                      }
                                    }),
                                SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }else {
            return SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(
                    SM_ORANGE),
              ),
            );
          }
    }
      )
    );
  }

  showMeetingDetailsPopUp(BuildContext context,DocumentSnapshot data,double width,String userRole) async{
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return _descDetail(width,data);
        }
    );
  }

  _descDetail(width,data){
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
                width: width < 401 ? width : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Description'),
                        Expanded(child: Container()),
                        IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: (){
                              Navigator.pop(context);
                            })
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(data['description'])
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}

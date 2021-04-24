import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app/modules/users_page/user_card.dart';
import 'package:share_market/app/services/providers/user_provider.dart';
import 'package:share_market/app_commons/ahcrm_text_field.dart';
import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app_commons/utilities.dart';

class UsersPage extends StatefulWidget {
  final Map dataSend;

  UsersPage({@required this.dataSend});
  @override
  _UsersPageState createState() => _UsersPageState(dataSend:dataSend);
}

class _UsersPageState extends State<UsersPage> {
  final Map dataSend;

  _UsersPageState({@required this.dataSend});

  var width;

  showMessageDialog(BuildContext context) async{
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController userIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isSavingUser = false;
    Map<String, dynamic> formData = {};
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
      return StatefulBuilder(builder: (context, StateSetter setState){

        void saveUser(){
          formData["userName"] = nameController.text.trim();
          formData["email"] = emailController.text.trim();
          formData["id"] = userIdController.text.trim();
          formData["password"] = passwordController.text.trim();
          formData["role"] = "user";
          print(nameController.text);
          if(formData["userName"] == null || formData["userName"] == ""){
            Utilities().toastMessage("Please add the User's Name", ERROR_RED, Icons.error, width, context);
          }else if(formData["email"] == null || formData["email"] == ""){
            Utilities().toastMessage("Please add the User's Email ID", ERROR_RED, Icons.error, width, context);
          }else if(formData["id"] == null || formData["id"] == ""){
            Utilities().toastMessage("Please add the User ID", ERROR_RED, Icons.error, width, context);
          }else if(formData["password"] == null || formData["password"] == ""){
            Utilities().toastMessage("Please add the User's password", ERROR_RED, Icons.error, width, context);
          }else{
            setState((){
              isSavingUser = true;
            });
            UserProviderServices().addUser(formData).then((value) {
              if (value["isSuccess"]) {
                setState(() {
                  isSavingUser = false;
                });
                Navigator.pop(context);
                Utilities().toastMessage("Added the user successfully", cursorColour, Icons.done, width, context);
              } else {
                setState(() {
                  isSavingUser = false;
                });
                if(value["message"]!=null || value["message"].toString().trim()!=""){
                  Utilities().toastMessage(value["message"].toString(), ERROR_RED, Icons.error, width, context);
                }else{
                  Utilities().toastMessage("Oops! Something went wrong. Please try again.", ERROR_RED, Icons.error, width, context);
                }
              }
            }).catchError((error) {
              setState(() {
                isSavingUser = false;
              });
              print(error);
              Utilities().toastMessage("Oops! Something went wrong. Please try again.", ERROR_RED, Icons.error, width, context);
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
                  child: Column(
                    children: [
                      AhCrmTextField(
                        context: context,
                        nextFocusNode: null,
                        currentFocusNode: null,
                        title: "User Name",
                        controller: nameController,
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
                        title: "User Email",
                        controller: emailController,
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
                        title: "User ID",
                        controller: userIdController,
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
                        title: "Password",
                        controller: passwordController,
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
                                isSavingUser ? null : saveUser,
                                child: !isSavingUser
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: dataSend['role'] == 'admin'
          ? FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          showMessageDialog(context);
        },
        label: Text(
          ' ADD USER',
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
      body: meetingPageBody(),
    );
  }

  Widget meetingPageBody() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .where("role",isEqualTo: "user")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Loading'));
          }
          if (snapshot.hasError) {
            print("Error - ${snapshot.error.toString()}");
            return Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text('No data available'));
          }

          List usersList;
          usersList = snapshot.data.documents;

          if (usersList.length == 0) {
            return Center(child: Text("No meeting scheduled"));
          } else {
            return listOfMeetings(usersList);
          }
        });
  }

  Widget listOfMeetings(List<DocumentSnapshot> users) {
    return Center(
        child: Wrap(
            spacing: 50.0,
            runSpacing: 20.0,
            children: users.map((e) => UserCard(cardData: e,pageWidth: width,)).toList()));
  }
}

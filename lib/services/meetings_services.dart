import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingsServices {
  CollectionReference userRef = Firestore.instance.collection("meetings");
  Map responseMap = {};
  var error;
  Future addMeeting(Map data) async {
    await userRef.add(data).then((value) {
      responseMap["isSuccess"] = true;
    }).onError((error, stackTrace) {
      responseMap["isSuccess"] = false;
      print("Error - $error");
    }).catchError((error) {
      responseMap["isSuccess"] = false;
      print("Error - $error");
    });
    return responseMap;
  }

  Future cancelMeeting(String meetId) async {
    Map response = {};
    await userRef
        .document(meetId)
        .updateData({"isCancelled": true}).then((value) {
      response["isSuccess"] = true;
    }).onError((error, stackTrace) {
      response["isSuccess"] = false;
      print("Error - $error");
    }).catchError((error) {
      response["isSuccess"] = false;
      print("Error - $error");
    });
    return response;
  }

  Future addMinutesOfMeeting(String meetId,String minutesOfMeeting) async {
    Map response = {};
    await userRef
        .document(meetId)
        .updateData({"minutesOfMeeting": minutesOfMeeting}).then((value) {
      response["isSuccess"] = true;
    }).onError((error, stackTrace) {
      response["isSuccess"] = false;
      print("Error - $error");
    }).catchError((error) {
      response["isSuccess"] = false;
      print("Error - $error");
    });
    return response;
  }
}

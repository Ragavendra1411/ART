
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumServices {
  CollectionReference userRef = Firestore.instance.collection("forums");
  Map responseMap = {};
  var error;

  Future addEditForums(Map data,String documentId,bool edit) async {
    if(edit){
      await userRef.document(documentId).updateData(data).then((value) {
        responseMap["isSuccess"] = true;
      }).onError((error, stackTrace) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      }).catchError((error) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      });
    }
    else{
      data['createdAt'] = DateTime.now();
      await userRef.add(data).then((value) {
        responseMap["isSuccess"] = true;
      }).onError((error, stackTrace) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      }).catchError((error) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      });
    }
    return responseMap;
  }

  Future deleteForums(String forumId) async {
    Map response = {};
    await userRef
        .document(forumId)
        .updateData({"isDeleted": true}).then((value) {
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
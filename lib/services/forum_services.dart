import 'package:cloud_firestore/cloud_firestore.dart';

class ForumServices {
  CollectionReference userRef = Firestore.instance.collection("forums");
  Map responseMap = {};
  var error;

  Future addEditForums(Map data, String documentId, bool edit) async {
    if (edit) {
      await userRef.document(documentId).updateData(data).then((value) {
        responseMap["isSuccess"] = true;
      }).onError((error, stackTrace) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      }).catchError((error) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      });
    } else {
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

  Future askQuestionFunction(
      String id, Map<String, dynamic> questionData) async {
    Map response = {};
    await userRef
        .document(id)
        .collection("questions")
        .add(questionData)
        .then((value) {
      print("In then - ${value.toString()}");
      response = {"isError": false, "data": value};
    }).catchError((error) {
      response = {"isError": true, "data": error};
      print("Error - $error");
    });
    return response;
  }

  Future addReplyFunction(String documentId, String questionId,
      Map<String, dynamic> replyData) async {
    Map response = {};
    await userRef
        .document(documentId)
        .collection("questions")
        .document(questionId)
        .collection("replies")
        .add(replyData)
        .then((value) async{
      await userRef
          .document(documentId)
          .collection("questions")
          .document(questionId).updateData({"replyCount":FieldValue.increment(1)}).then((replyIncrementValue){
        print("In then - ${value.toString()}");
        response = {"isError": false, "data": value,"message":"Successfully incremented the reply count"};
      }).catchError((error){
        response = {"isError": true, "data": error,"message":"Error in incrementing reply count"};
      });
    }).catchError((error) {
      response = {"isError": true, "data": error};
      print("Error - $error");
    });
    return response;
  }

  Stream<dynamic> questionsStream(String id) {
    return userRef
        .document(id)
        .collection("questions")
        .orderBy("updatedAt", descending: true)
        .snapshots();
  }

  Stream<dynamic> replyStream(String forumId, String questionId) {
    return userRef
        .document(forumId)
        .collection("questions")
        .document(questionId)
        .collection("replies")
        .orderBy("updatedAt", descending: true)
        .snapshots();
  }
}

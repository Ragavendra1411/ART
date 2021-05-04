import 'package:cloud_firestore/cloud_firestore.dart';

class VideoServices {
  CollectionReference folderRef = Firestore.instance.collection("videoFolders");
  CollectionReference videoRef = Firestore.instance.collection("videos");

  Future<bool> checkIfFolderExists(String folderName) async {
    bool val;
    await folderRef
        .where("name", isEqualTo: folderName)
        .getDocuments()
        .then((value) {
      if (value.documents.length != 0) {
        val = true;
      } else {
        val = false;
      }
    });


    return val;
  }

   Future<bool> checkIfVideoExists(String folderName) async {
    bool val;
    await videoRef
        .where("name", isEqualTo: folderName)
        .getDocuments()
        .then((value) {
      if (value.documents.length != 0) {
        val = true;
      } else {
        val = false;
      }
    });


    return val;
  }

  Future<Map> addFolder(String folderName, Map data) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await folderRef.add(data).then((value) {
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

  Future<Map> renameFolder(String folderName, String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await folderRef
        .document(folderId)
        .updateData({"name": folderName}).then((value) {
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

  Future<Map> deleteFolder(String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await folderRef
        .document(folderId)
        .updateData({"isDeleted": true}).then((value) {
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


  Future<Map> renameVideo(String folderName, String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await videoRef
        .document(folderId)
        .updateData({"title": folderName}).then((value) {
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

  Future<Map> deleteVideo(String docId, String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await videoRef
        .document(docId)
        .updateData({"isDeleted": true}).then((value) {
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfVideos": FieldValue.arrayRemove([docId])
      }).then((value) {
        responseMap["isSuccess"] = true;
      }).onError((error, stackTrace) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      }).catchError((error) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      });
    });
    return responseMap;
  }

  Future<Map> addVideo(String folderId, Map data) async {
    Map responseMap = {};
    var videoId;
    // responseMap["isSuccess"] = true;
    //
    Map<String, dynamic> videoData = {
      "title": data["title"],
      "url": data["url"],
      "folderId": folderId,
      "createdDate": data["createdDate"],
       "isDeleted":false
    };
    await videoRef.add(videoData).then((value) {
      videoId = value.documentID;
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfVideos": FieldValue.arrayUnion([videoId])
      }).then((value) {
        responseMap["isSuccess"] = true;
      }).onError((error, stackTrace) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      }).catchError((error) {
        responseMap["isSuccess"] = false;
        print("Error - $error");
      });
    });

    return responseMap;
  }
}

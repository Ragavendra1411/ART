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
    print("VALUE INSIDE SERVICE $val");

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

  Future<Map> addVideo(String folderId, Map data) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    //
    Map<String, dynamic> videoData = {
      "title": data["title"],
      "url": data["url"],
      "folderId": folderId
    };
    await videoRef.add(videoData).then((value) {
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfVideos": FieldValue.arrayUnion([data])
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

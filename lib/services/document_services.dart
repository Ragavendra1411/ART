import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentServices {
  CollectionReference folderRef = Firestore.instance.collection("documentFolders");
  CollectionReference documentRef = Firestore.instance.collection("documents");


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

   Future<Map> addDocument(String folderId, Map data) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    //
    Map<String, dynamic> videoData = {
      "title": data["title"],
      "url": data["url"],
      "folderId": folderId
    };
    await documentRef.add(videoData).then((value) {
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfDocuments": FieldValue.arrayUnion([data])
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

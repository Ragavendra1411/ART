import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentServices {
  CollectionReference folderRef =
      Firestore.instance.collection("documentFolders");
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


    return val;
  }

  Future<bool> checkIfDocumentExists(String folderName) async {
    bool val;
    await documentRef
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

  Future<Map> addDocument(String folderId, Map data) async {
    Map responseMap = {};
    var documentId;
    // responseMap["isSuccess"] = true;
    //
    Map<String, dynamic> videoData = {
      "title": data["title"],
      "url": data["url"],
      "folderId": folderId,
      "createdDate": data["createdDate"],
      "isDeleted": false
    };
    await documentRef.add(videoData).then((value) {
      documentId = value.documentID;
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfDocuments": FieldValue.arrayUnion([documentId])
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

  Future<Map> renameDocument(String folderName, String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await documentRef
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

  Future<Map> deleteDocument(String docId, String folderId) async {
    Map responseMap = {};
    // responseMap["isSuccess"] = true;
    await documentRef
        .document(docId)
        .updateData({"isDeleted": true}).then((value) {
      responseMap["isSuccess"] = true;
    }).then((value) async {
      await folderRef.document(folderId).updateData({
        "listOfDocuments": FieldValue.arrayRemove([docId])
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

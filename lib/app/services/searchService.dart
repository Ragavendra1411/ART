import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByName(
      String searchField, String userId, String category, int roleType) {
    if (roleType == 3) {
      if (category == "name") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchNameKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            // .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "companyName") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchCompanyNameKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            // .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "email") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchEmailKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            // .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "leadValidationData") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchLeadStageKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            // .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "pipelineStagesData") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchPipelineStageKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            // .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      }
    } else {
      if (category == "name") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchNameKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "companyName") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchCompanyNameKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "email") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchEmailKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "leadValidationData") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchLeadStageKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      } else if (category == "pipelineStagesData") {
        return Firestore.instance
            .collection("leads_list")
            .where('searchPipelineStageKey',
                isEqualTo: searchField.substring(0, 1).toUpperCase())
            .where("createdUserId", arrayContains: userId)
            .orderBy("name")
            .getDocuments();
      }
    }
  }
}

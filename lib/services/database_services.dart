import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseServices {
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  final _propertyDataRef =
      FirebaseFirestore.instance.collection("PROPERTY DATA");
  final _userProfiles = FirebaseStorage.instance.ref("PROFILES");
  final _propertyFiles = FirebaseStorage.instance.ref("PROPERTY FILES");

  Future<Map<String, dynamic>> signUpUser(Map<String, dynamic> userData) async {
    Map<String, dynamic> result = {};
    await _auth
        .createUserWithEmailAndPassword(
            email: userData['email'], password: userData['password'])
        .then((value) async {
      var userId = value.user!.uid;
      userData['id'] = userId;
      await _userProfiles
          .child(userId)
          .putFile(userData['profile_photo'])
          .then((p0) async {
        await p0.ref.getDownloadURL().then((value) async {
          userData['profile_photo'] = value;
          userData.remove('password');
          await _usersRef.doc(userId).set(userData).then((value) {
            result = {'msg': "done", "data": userData};
          }).catchError((e) {
            result = {'msg': e.code};
          });
        }).catchError((e) {
          result = {'msg': e.code};
        });
      }).catchError((e) {
        result = {'msg': e.code};
      });
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> signInUser(Map<String, dynamic> userData) async {
    Map<String, dynamic> result = {};
    await _auth
        .signInWithEmailAndPassword(
            email: userData['email'], password: userData['password'])
        .then((value) async {
      await _usersRef.doc(value.user!.uid).get().then((value) {
        result = {'msg': "done", "data": value.data()};
      }).catchError((e) {
        result = {'msg': e.code};
      });
    }).catchError((e) {
      result = {'msg': e.code};
    });
    return result;
  }

  Future<Map<String, dynamic>> uploadProperty(
      Map<String, dynamic> propertyData) async {
    Map<String, dynamic> result = {};
    String propertyId = _propertyDataRef.doc().id;
    propertyData['id'] = propertyId;
    List<String> imageUrls = [];
    for (var i = 0; i < propertyData['images'].length; i++) {
      String imgId = _propertyDataRef.doc().id;
      await _propertyFiles
          .child(propertyId)
          .child("IMAGES")
          .child(imgId)
          .putFile(propertyData['images'][i])
          .then((p0) async {
        String url = await p0.ref.getDownloadURL();
        imageUrls.add(url);
      });
    }
    propertyData['images'] = imageUrls;
    for (var i = 0; i < propertyData['images_3D'].length; i++) {
      String imgId = _propertyDataRef.doc().id;
      await _propertyFiles
          .child(propertyId)
          .child("IMAGES 3D")
          .child(imgId)
          .putFile(propertyData['images_3D'][i]['file'])
          .then((p0) async {
        String url = await p0.ref.getDownloadURL();
        propertyData['images_3D'][i]['file'] = url;
      });
    }

    int time = DateTime.now().millisecondsSinceEpoch;
    propertyData['uploadedAt'] = time;
    //print(propertyData);
    await _propertyDataRef.doc(propertyId).set(propertyData).then((value) {
      result = {'msg': "done", "data": ""};
    }).catchError((e) {
      result = {'msg': e.toString(), "data": ""};
    });
    return result;
  }

  Future<Map<String, dynamic>> updatePropertyInfo(
      String propId, String newStatus) async {
    Map<String, dynamic> result = {};
    await _propertyDataRef
        .doc(propId)
        .update({'active_status': newStatus}).then((value) {
      result = {'msg': 'done', "data": []};
    }).catchError((e) {
      result = {'msg': e.code, "data": []};
    });
    return result;
  }

  Future<Map<String, dynamic>> updatePropertyApprovalStatus(
      String propId, String newStatus) async {
    Map<String, dynamic> result = {};
    await _propertyDataRef
        .doc(propId)
        .update({'approval_status': newStatus}).then((value) {
      result = {'msg': 'done', "data": []};
    }).catchError((e) {
      result = {'msg': e.code, "data": []};
    });
    return result;
  }

  Future<Map<String, dynamic>> retriveProperty(String uid) async {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> docs = [];
    Query _query = _propertyDataRef;
    if (uid.trim().isNotEmpty) {
      print("uid");
      _query = _query.where('ownerId', isEqualTo: uid);
    } else {
      print("no uid");
    }
    await _query.get().then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((doc) {
          docs.add(doc.data() as Map<String, dynamic>);
        });
        result = {'msg': "done", "data": docs};
      } else {
        result = {'msg': "done", "data": []};
      }
      if (value.docs.isEmpty && value.metadata.isFromCache) {
        result = {'msg': "No internet connectivity", "data": []};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": []};
    });
    return result;
  }

  Future<Map<String, dynamic>> getSingleUser(String uid) async {
    Map<String, dynamic> result = {};
    await _usersRef.doc(uid).get().then((value) {
      if (value.exists) {
        result = result = {'msg': "done", "data": value.data()};
      } else {
        result = result = {'msg': "done", "data": null};
      }
    }).catchError((e) {
      result = {'msg': e.code, "data": null};
    });
    return result;
  }
}

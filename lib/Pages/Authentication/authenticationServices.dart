// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl/intl.dart';
import 'package:meditation/Utils/authUtils.dart';
import '../../Utils/appointmentStatus.dart';
import '../../Utils/status.dart';
import '../../main.dart';

DateTime currentDate = DateTime.now();
Timestamp timeStamp = Timestamp.fromDate(currentDate);
String date = '';
String expiryDate = '';
dynamic currentUserDetails;
dynamic allUserDetails;
late Map<String, dynamic> screenData = <String, dynamic>{};

final storage = GetStorage();

// Facebook fields
bool isFacebookLogin = false;
Map<String, dynamic>? _userData;
AccessToken? _accessToken;
bool _checking = true;
String prettyPrint(Map json) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

class Authentication {
  static Future<void> saveFCMToken() async {
    // save firebase token if it doesn't exist
    if (AuthUtils.getfcmToken() == '') {
      String? token = await FirebaseMessaging.instance.getToken();
      storage.write("fcmToken", token);
      logger.d("fcmToken saved: " + token!);
    }
  }

  // FB login
  static Future<void> facebookLoginCheck() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    _checking = false;

    if (accessToken != null) {
      logger.d("is Logged:::: ${prettyPrint(accessToken.toJson())}");
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _accessToken = accessToken;
      _userData = userData;
    } else {
      logger.d('User is currently signed out!');
      Get.offNamed("/login");
    }
    // else {
    //   signInWithFacebook();
    // }
  }

  static Future<User?> signInWithFacebook() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    final LoginResult loginResult = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    try {
      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await auth.signInWithCredential(facebookAuthCredential);
      user = userCredential.user;
      logger.d("facebookUser = " + user.toString());
      if (user != null) {
        storage.write('isFacebookLogin', true);
        if (userCredential.additionalUserInfo!.isNewUser == true) {
          await Authentication.addUser(user);
          Get.offNamed("/signUpForm");
        } else {
          // screenData["facebookUserDetails"] = user;
          Get.offNamed("/home");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // handle the error here
      } else if (e.code == 'invalid-credential') {
        // handle the error here
      }
    } catch (e) {
      // handle the error here
    }
    return user;
  }

  static Future<void> facebookLogin() async {
    final LoginResult result = await FacebookAuth.instance
        .login(); // by default we request the email and the public profile

    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      logger.d(_accessToken!.toJson());
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _userData = userData;
    } else {
      logger.d(result.status);
      logger.d(result.message);
      _checking = false;
    }
  }

  static Future<User?> facebookLogOut() async {
    await signOut();
    return null;
  }

  // Google Login
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
        logger.d("googleuser = " + user.toString());
        if (user != null) {
          if (userCredential.additionalUserInfo!.isNewUser == true) {
            await Authentication.addUser(user);
            Get.offNamed("/signUpForm");
          } else {
            await Authentication.addLastLogin();
            Get.offNamed("/home");
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

  static Future<void> signOut() async {
    isFacebookLogin = await AuthUtils.getIsFacebookLogin() ?? false;
    if (isFacebookLogin == true) {
      await FirebaseAuth.instance.signOut();
      logger.d('google signed out.');
      await FacebookAuth.instance.logOut();
      logger.d('facebook logout');
      _accessToken = null;
      _userData = null;
      await storage.erase();
      Get.offAllNamed('/login');
    } else {
      await FirebaseAuth.instance.signOut();
      logger.d('google signed out.');
      await storage.erase();
      Get.offAllNamed('/login');
    }
  }

  static Future<dynamic> getCurrentUserDetails(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        currentUserDetails = documentSnapshot.data();
        logger.d('getCurrentUserDetails');
      }
    });
    return currentUserDetails;
  }

  static Future<dynamic> getUserDetailsWithId(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        currentUserDetails = documentSnapshot.data();
        logger.d('getUserDetailsWithId');
      }
    });
    return currentUserDetails;
  }

  static Future<dynamic> getFriendDetails(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        currentUserDetails = documentSnapshot.data();
        logger.d('getFriendDetails');
      }
    });
    return currentUserDetails;
  }

  static Future<dynamic> getAllUserDetails(User user) async {
    allUserDetails = FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .get();
    return allUserDetails;
  }

  static Future<void> addUser(User user, {bool? isPhoneLogin}) async {
    dynamic userExists;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // save firebase token if it doesn't exist
    saveFCMToken();

    // check if user Exists
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userExists = documentSnapshot.exists;
      }
    });
    // Call the user's CollectionReference to add a new user
    return userExists == true
        ? users
            .doc(user.uid)
            .get()
            .then((value) => logger.d("user exists"))
            .catchError(
                (error) => logger.d("Failed to get user exists: $error"))
        : users
            .doc(user.uid)
            .set({
              'displayName': user.displayName,
              'uid': user.uid,
              'email': user.email,
              'photoURL': user.photoURL,
              'packageDetails': {
                'packagePurchased': false,
              },
              'signUpFormDetails': {},
              'fcmToken': AuthUtils.getfcmToken(),
              'isConsumer': true,
              'isPhoneLogin': isPhoneLogin ?? false,
              'lastLoginDate':
                  user.metadata.lastSignInTime.toString().split(' ').first,
              'isUserOnline': true,
              'currentAppScreen': '',
              'chatDetails': {},
              'lastMsgTime': timeStamp,
            })
            .then((value) => logger.d("User Set"))
            .catchError((error) => logger.d("Failed to add user: $error"));
  }

  static Future<void> updateUser(User user,
      {bool isPhoneLogin = false,
      String? name,
      String? email,
      bool isUserOnline = false,
      String? currentAppScreen}) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users
        .doc(user.uid)
        .update({
          'displayName': name,
          'uid': user.uid,
          'email': email,
          'photoURL': user.photoURL,
          'packageDetails': {
            'packagePurchased': false,
          },
          // 'signUpFormDetails': {},
          'fcmToken': AuthUtils.getfcmToken(),
          'isConsumer': true,
          'isPhoneLogin': isPhoneLogin,
          'isUserOnline': isUserOnline,
          'currentAppScreen': currentAppScreen,
        })
        .then((value) => logger.d("update User"))
        .catchError((error) => logger.d("Failed to update user: $error"));
  }

  static Future<void> addAppointmentCollection(
    bool isPhoneLogin,
    bool isIndivisual,
    String? docType,
    User user,
    int day,
    String time,
    String timeSlot,
    String date,
    String status, {
    String? displayName,
    String? uid,
    String? url,
  }) async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection(docType!);
    return appointments
        .doc('appointments')
        .update(
          {
            'data': FieldValue.arrayUnion([
              {
                'uid': isIndivisual == true ? user.uid : uid,
                'displayName': isIndivisual == true
                    ? isPhoneLogin == true
                        ? AuthUtils.getDisplayName()
                        : user.displayName
                    : displayName,
                'day': day,
                'time': time,
                'timeSlot': timeSlot,
                'date': date,
                'status': status,
                'statusCode': AppointmentStatus.ID[status],
                'url': isPhoneLogin == true
                    ? AuthUtils.getPhotoURL()
                    : isIndivisual == true
                        ? user.photoURL
                        : url,
                'appointmentTitle': '',
              }
            ])
          },
        )
        .then((value) => logger.d("addAppointmentCollection Added"))
        .catchError((error) =>
            logger.d("Failed to add addAppointmentCollection: $error"));
  }

  static Future<void> addCallAppointmentCollection(
    bool isPhoneLogin,
    bool isIndivisual,
    String? docType,
    User user,
    String date,
    String status, {
    String? displayName,
    String? uid,
    String? url,
  }) async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection(docType!);
    return appointments
        .doc('appointments')
        .update(
          {
            'data': FieldValue.arrayUnion([
              {
                'uid': isIndivisual == true ? user.uid : uid,
                'displayName': isIndivisual == true
                    ? isPhoneLogin == true
                        ? AuthUtils.getDisplayName()
                        : user.displayName
                    : displayName,
                'day': 0,
                'time': '',
                'timeSlot': '',
                'date': date,
                'status': status,
                'statusCode': AppointmentStatus.ID[status],
                'url': isPhoneLogin == true
                    ? AuthUtils.getPhotoURL()
                    : isIndivisual == true
                        ? user.photoURL
                        : url,
                'appointmentTitle': 'Call Appointment',
              }
            ])
          },
        )
        .then((value) => logger.d("addCallAppointmentCollection Added"))
        .catchError((error) =>
            logger.d("Failed to add addCallAppointmentCollection: $error"));
  }

  static Future<void> removeAppointment(
      bool isPhoneLogin,
      bool isIndivisual,
      String? displayName,
      String uid,
      String? url,
      String? docType,
      User user,
      int day,
      String time,
      String timeSlot,
      String date,
      status) async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection(docType!);
    return appointments
        .doc('appointments')
        .update(
          {
            'data': FieldValue.arrayRemove([
              {
                'uid': uid,
                'displayName': displayName,
                'day': day,
                'time': time,
                'timeSlot': timeSlot,
                'date': date,
                'status': status,
                'statusCode': AppointmentStatus.ID[status],
                'url': url,
                'appointmentTitle': '',
              }
            ])
          },
        )
        .then((value) => logger.d("removed appointment"))
        .catchError(
            (error) => logger.d("Failed to removed appointment: $error"));
  }

  static void calculateExpiryDate(int expiryDateDays) {
    // expiry date calculate
    DateTime currentDate = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    currentDate = currentDate.add(Duration(days: expiryDateDays));
    expiryDate = formatter.format(currentDate);
    logger.d(expiryDate);
  }

  static String getCurrentDate() {
    // expiry date calculate
    DateTime currentDate = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    expiryDate = formatter.format(currentDate);
    return expiryDate;
  }

  static Future<void> addLastLogin() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    date = formatter.format(currentDate);
    // Call the user's CollectionReference to add a new user
    return users
        .doc(user!.uid)
        .update(
          {
            'lastLoginDate': date,
          },
        )
        .then((value) => logger.d("lastLoginDate Added"))
        .catchError((error) => logger.d("Failed to add lastLoginDate: $error"));
  }

  static Future<void> addPackageDetails(
      bool packagePurchased,
      String packageType,
      int packageAmount,
      int expiryDateDays,
      int totalMsgs,
      int totalAppointments,
      bool isPackagePayment,
      String imageUrl) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;
    calculateExpiryDate(expiryDateDays);
    // Call the user's CollectionReference to add a new user
    return users
        .doc(user!.uid)
        .update(
          {
            'packageDetails': {
              'packagePurchased': packagePurchased,
              'packageType': packageType,
              'packageAmount': packageAmount,
              'expiryDateDays': expiryDateDays,
              'expiryDate': expiryDate,
              'totalMsgs': totalMsgs,
              'totalAppointments': totalAppointments,
              'isPackagePayment': isPackagePayment,
              'imageUrl': imageUrl,
            },
          },
        )
        .then((value) => logger.d("packageDetails Added"))
        .catchError(
            (error) => logger.d("Failed to add packageDetails: $error"));
  }

  static Future<void> addPackageToCollection(
    bool isIndivisual,
    String? docType,
    User user,
    String date,
    String time,
    bool packagePurchased,
    bool isPhoneLogin,
    String packageType,
    int packageAmount,
    int expiryDateDays,
    int totalMsgs,
    int totalAppointments,
    bool isPackagePayment,
    String? imageUrl,
    String status, {
    String? displayName,
    String? uid,
  }) async {
    CollectionReference packages =
        FirebaseFirestore.instance.collection(docType!);
    return packages
        .doc('packages')
        .update(
          {
            'data': FieldValue.arrayUnion([
              {
                'uid': isIndivisual == true ? user.uid : uid,
                'displayName': isPhoneLogin == true
                    ? AuthUtils.getDisplayName()
                    : isIndivisual == true
                        ? user.displayName
                        : displayName,
                'date': date,
                'time': time,
                'packagePurchased': packagePurchased,
                'packageType': packageType,
                'packageAmount': packageAmount,
                'expiryDateDays': expiryDateDays,
                'expiryDate': expiryDate,
                'totalMsgs': totalMsgs,
                'totalAppointments': totalAppointments,
                'isPackagePayment': isPackagePayment,
                'imageUrl': imageUrl,
                'status': status,
                'statusCode': Status.ID[status],
              }
            ])
          },
        )
        .then((value) => logger.d("addPackageToCollection Added"))
        .catchError(
            (error) => logger.d("Failed to add PackageToCollection: $error"));
  }

  static Future<void> removePackageToCollection(
    bool isIndivisual,
    String? docType,
    String uid,
    String displayName,
    User user,
    String date,
    String time,
    bool packagePurchased,
    bool isPhoneLogin,
    String packageType,
    int packageAmount,
    String expiryDate,
    int expiryDateDays,
    int totalMsgs,
    int totalAppointments,
    bool isPackagePayment,
    String? imageUrl,
    String status,
  ) async {
    CollectionReference packages =
        FirebaseFirestore.instance.collection(docType!);
    return packages
        .doc('packages')
        .update(
          {
            'data': FieldValue.arrayRemove([
              {
                'uid': uid,
                'displayName': isPhoneLogin == true
                    ? AuthUtils.getDisplayName()
                    : isIndivisual == true
                        ? user.displayName
                        : displayName,
                'date': date,
                'time': time,
                'packagePurchased': packagePurchased,
                'packageType': packageType,
                'packageAmount': packageAmount,
                'expiryDateDays': expiryDateDays,
                'expiryDate': expiryDate,
                'totalMsgs': totalMsgs,
                'totalAppointments': totalAppointments,
                'isPackagePayment': isPackagePayment,
                'imageUrl': imageUrl,
                'status': status,
                'statusCode': Status.ID[status],
              }
            ])
          },
        )
        .then((value) => logger.d("removPackageToCollection Added"))
        .catchError(
            (error) => logger.d("Failed to remov PackageToCollection: $error"));
  }

  static Future<void> updateUserDetails(
      bool updateSingleValue, String fieldName1, dynamic value, String userUid,
      {String? fieldName2,
      bool updateChatDetails = false,
      String? fieldName3}) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return updateSingleValue == false
        ? updateChatDetails == false
            ? users
                .doc(userUid)
                .update(
                  {'$fieldName1.$fieldName2': value},
                )
                .then((value) => logger.d("$fieldName1.$fieldName2 updated"))
                .catchError((error) => logger
                    .d("Failed to update $fieldName1.$fieldName2: $error"))
            : users
                .doc(userUid)
                .update(
                  {'$fieldName1.$fieldName2.$fieldName3': value},
                )
                .then((value) => logger.d(
                    "$fieldName1.$fieldName2.$fieldName3 updated ChatDetails"))
                .catchError((error) => logger.d(
                    "Failed to update ChatDetails $fieldName1.$fieldName2.$fieldName3: $error"))
        : users
            .doc(userUid)
            .update(
              {fieldName1: value},
            )
            .then((value) => logger.d("$fieldName1 updated"))
            .catchError(
                (error) => logger.d("Failed to update $fieldName1: $error"));
  }

  static Future<void> updatePackageCounter(
      bool updateTotalMsgs, int counter, String userUid) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return updateTotalMsgs == true
        ? users
            .doc(userUid)
            .update(
              {'packageDetails.totalMsgs': counter},
            )
            .then((value) => logger.d("packageDetails totalMsgs updated"))
            .catchError((error) =>
                logger.d("Failed to update totalMsgs packageDetails: $error"))
        : users
            .doc(userUid)
            .update(
              {'packageDetails.totalAppointments': counter},
            )
            .then(
                (value) => logger.d("packageDetails totalAppointments updated"))
            .catchError((error) => logger.d(
                "Failed to update totalAppointments packageDetails: $error"));
  }

  static Future<void> addSignUpFormDetails(
      String firstName,
      String lastName,
      String nickName,
      String dob,
      String pob,
      String motherName,
      String gender,
      String phonoNo) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;
    return users
        .doc(user!.uid)
        .update(
          {
            'signUpFormDetails': {
              'firstName': firstName,
              'lastName': lastName,
              'nickName': nickName,
              'dateOfBirth': dob,
              'placeOfBirth': pob,
              'motherName': motherName,
              'gender': gender,
              'phoneNo': phonoNo
            },
          },
        )
        .then((value) => logger.d("signUpFormDetails Added"))
        .catchError(
            (error) => logger.d("Failed to add signUpFormDetails: $error"));
  }

  static Future<void> updateConstantsData(
    String fieldName1,
    String? fieldName2,
    dynamic value,
  ) {
    CollectionReference constants =
        FirebaseFirestore.instance.collection('constants');
    return constants
        .doc('data')
        .update(
          {'$fieldName1.$fieldName2': value},
        )
        .then((value) =>
            logger.d("$fieldName1.$fieldName2 constants data updated"))
        .catchError((error) => logger.d(
            "Failed to update constants data $fieldName1.$fieldName2: $error"));
  }
}

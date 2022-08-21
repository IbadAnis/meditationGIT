// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meditation/Pages/Playlist/mediaPlayer.dart';
import 'package:meditation/Utils/authUtils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../Utils/photoItem.dart';
import '../../main.dart';
import '../Authentication/authenticationServices.dart';
import '../Chat/chatMsg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../Notification/notificationsServices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String error_msg = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode btnFocus = FocusNode();

  final storage = GetStorage();
  var isloading = "false";

  PhotoItem? profileItem;
  dynamic profileImage;
  dynamic argumentData = Get.arguments;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  // chats & notification fields
  int notificationCounter = 0;

  // Firebase
  final currentUser = FirebaseAuth.instance.currentUser!;
  dynamic getCurrentUserDetailsResponse;

  // user details
  bool isPackagePurchased = false;
  bool isPackagePayment = false;
  bool isConsumer = true;
  bool isPhoneLogin = false;
  List getRecentAppointments = [];
  DateTime currentDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String lastLoginDate = '';
  String date = '';
  int totalMsgs = 0;
  int totalAppointments = 0;
  String packageType = 'bronze';
  List<dynamic> packagesData = [];
  List<dynamic> constantsData = [];

  // notification fields
  String fcmToken = '';
  // AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   '1',
  //   'meditation',
  //   description: 'this is meditation channel',
  //   importance: Importance.max,
  //   showBadge: true,
  //   playSound: true,
  // );
  String serverKey = '';

  var scaffoldKey = GlobalKey<ScaffoldState>();

  // music data fields
  String musicUrl = '';
  dynamic title;
  dynamic description;
  dynamic photo;
  dynamic playlistData;
  dynamic currentMusicData;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // get music current data
    currentMusicData = AuthUtils.getCurrentMusicData();
    if (currentMusicData != null) {
      setState(() {
        musicUrl = currentMusicData['musicUrl'];
        title = currentMusicData['title'];
        description = currentMusicData['description'];
        photo = currentMusicData['photo'];
        playlistData = currentMusicData['playlistData'];
      });
    }

    // get constant data
    await FirebaseFirestore.instance
        .collection('constants')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          constantsData.add(doc.data());
          serverKey = constantsData[0]['data']['serverKey'];
        });
      }
      storage.write('friendUid', constantsData[0]['data']['friendUid']);
      storage.write('serverKey', constantsData[0]['data']['serverKey']);
      storage.write('adminFcmToken', constantsData[0]['data']['adminFcmToken']);
      logger.d("adminFcmToken: " + constantsData[0]['data']['adminFcmToken']);
    });

    // get current user details
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser);
    if (getCurrentUserDetailsResponse != null) {
      await storage.write('loggedIn', true);
      setState(() {
        isPhoneLogin = getCurrentUserDetailsResponse['isPhoneLogin'];
        isConsumer = getCurrentUserDetailsResponse['isConsumer'];
        profileImage = getCurrentUserDetailsResponse['photoURL'];
        lastLoginDate = getCurrentUserDetailsResponse['lastLoginDate'];
      });
      // update constants data if current user is non consumer
      if (isConsumer == false) {
        await Authentication.updateConstantsData(
            'data', 'adminFcmToken', getCurrentUserDetailsResponse['fcmToken']);
        await Authentication.updateConstantsData(
            'data', 'friendUid', getCurrentUserDetailsResponse['uid']);
      }

      if (getCurrentUserDetailsResponse['packageDetails']['packagePurchased'] !=
              null ||
          getCurrentUserDetailsResponse['appointments'] != null) {
        setState(() {
          isPackagePurchased = getCurrentUserDetailsResponse['packageDetails']
              ['packagePurchased'];
        });
      }
      if (getCurrentUserDetailsResponse['packageDetails']['isPackagePayment'] !=
          null) {
        setState(() {
          isPackagePayment = getCurrentUserDetailsResponse['packageDetails']
              ['isPackagePayment'];
        });
      }
      storage.write(
          'isPhoneLogin', getCurrentUserDetailsResponse['isPhoneLogin']);
      storage.write(
          'displayName', getCurrentUserDetailsResponse['displayName']);
      storage.write('photoURL', getCurrentUserDetailsResponse['photoURL']);
      storage.write('isPackagePurchased',
          getCurrentUserDetailsResponse['packageDetails']['packagePurchased']);
      storage.write(
          'isPackagePayment',
          getCurrentUserDetailsResponse['packageDetails']['isPackagePayment'] ??
              false);
      storage.write('isConsumer', getCurrentUserDetailsResponse['isConsumer']);

      if (isConsumer == true) {
        // get current user recent appointments
        await FirebaseFirestore.instance
            .collection('approved')
            .doc('appointments')
            .get()
            .then((DocumentSnapshot ds) {
          if (ds.exists) {
            dynamic getApprovedAppointmentsTemp = ds.data();
            for (var i = 0;
                i < getApprovedAppointmentsTemp['data'].length;
                i++) {
              if (getApprovedAppointmentsTemp['data'][i]['uid'] ==
                  currentUser.uid) {
                setState(() {
                  getRecentAppointments
                      .add(getApprovedAppointmentsTemp['data'][i]);
                });
              }
            }
          }
        });

        if (isPackagePurchased == true) {
          // get user's package data
          packageType =
              getCurrentUserDetailsResponse['packageDetails']['packageType'];
          await FirebaseFirestore.instance
              .collection('packages')
              .where('packageType', isEqualTo: packageType)
              .get()
              .then((QuerySnapshot querySnapshot) {
            for (var doc in querySnapshot.docs) {
              setState(() {
                packagesData.add(doc.data());
              });
            }
            logger.d(packagesData);
          });
          // reset package total messages and appointments
          date = formatter.format(currentDate);
          if (date != lastLoginDate) {
            await Authentication.updateUserDetails(false, 'packageDetails',
                packagesData.first['totalMsgs'], currentUser.uid,
                fieldName2: 'totalMsgs');
          }
          // check package expiry date
          if (isPackagePayment == true && isPackagePurchased == true) {
            if (getCurrentUserDetailsResponse['packageDetails']['expiryDate'] ==
                date) {
              await Authentication.updateUserDetails(
                  false, 'packageDetails', false, currentUser.uid,
                  fieldName2: 'isPackagePayment');
              await Authentication.updateUserDetails(
                  false, 'packageDetails', false, currentUser.uid,
                  fieldName2: 'packagePurchased');
              onAlert(context, 'Alert', 'Your package is expired!',
                  AlertType.warning,
                  isNavigation: true,
                  screenName: '/home',
                  btnText: 'Okay',
                  argData: screenData);
            }
          }
        }
      } else {
        // get current user recent appointments
        await FirebaseFirestore.instance
            .collection('approved')
            .doc('appointments')
            .get()
            .then((DocumentSnapshot ds) {
          if (ds.exists) {
            dynamic getApprovedAppointmentsTemp = ds.data();
            for (var i = 0;
                i < getApprovedAppointmentsTemp['data'].length;
                i++) {
              setState(() {
                getRecentAppointments
                    .add(getApprovedAppointmentsTemp['data'][i]);
              });
            }
          }
        });
      }

      // add timeSlot
      // if (argumentData != null && argumentData['routeName'] == '/bankDetails' ||
      //     argumentData != null &&
      //         argumentData['routeName'] == '/subcriptionPlans') {
      //   //
      // } else {
      //   await BookingServices.addTimeSlotDoc();
      // }

      // set fcm token
      if (AuthUtils.getfcmToken() != null) {
        setState(() {
          fcmToken = AuthUtils.getfcmToken()!;
        });
        logger.d('fcmToken ' + fcmToken);
        // update FCM
        await Authentication.updateUserDetails(
          true,
          'fcmToken',
          fcmToken,
          currentUser.uid,
        );
      } else {
        String? token = await FirebaseMessaging.instance.getToken();
        setState(() {
          fcmToken = token!;
        });
        storage.write("fcmToken", fcmToken);
        logger.d("fcmToken: " + fcmToken);
      }

      // update user online status
      await Authentication.updateUserDetails(
        true,
        'isUserOnline',
        true,
        currentUser.uid,
      );
    } else {
      await Authentication.signOut();
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // void listenFCM() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel.id,
  //             channel.name,
  //             icon: 'launch_background',
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  void sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=' + serverKey,
        },
        body: jsonEncode(
          <String, dynamic>{
            'token': fcmToken,
            'notification': <String, dynamic>{
              'body':
                  'Your package has been approved, now you can chat and book appointment!',
              'title': 'Package Approved!!!'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": fcmToken,
          },
        ),
      );
    } catch (e) {
      logger.d("error push notification");
    }
    logger.d(fcmToken);
  }

  _launchURL() async {
    final Uri _url = Uri.parse('https://youtube.com/c/AstrologerLatifGhauri');
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return getCurrentUserDetailsResponse == null
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: appPrimaryColor,
              ),
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              AuthUtils.getIsMusicPlaying() == true ? null : Get.back();
              return false;
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          colors: [appSecondaryColor, appSecondaryColor2])),
                  child: Scaffold(
                      key: scaffoldKey,
                      drawer: drawer(context, isPackagePurchased, isConsumer),
                      backgroundColor: Colors.transparent,
                      // Notifications Icon
                      // bottomNavigationBar: BottomBarScreen(),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      scaffoldKey.currentState!.openDrawer();
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.menu,
                                        color: whiteColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  profileAvatar(
                                      width: _width,
                                      name: isPhoneLogin == false
                                          ? currentUser.displayName!
                                          : getCurrentUserDetailsResponse[
                                              'displayName'],
                                      textColor: whiteTextColor,
                                      profileImage: profileImage),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed('/notifications');
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Container(
                                              child: Icon(
                                                Icons
                                                    .notifications_none_outlined,
                                                color: whiteColor,
                                                size: 30,
                                              ),
                                            ),
                                            notificationCounter == 0
                                                ? Container()
                                                : Positioned(
                                                    left: 15,
                                                    top: 5,
                                                    child: Container(
                                                      // padding: EdgeInsets.only(right: 20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 18,
                                                        minHeight: 18,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '$notificationCounter',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: _height * 0.08,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    // direction: Axis.horizontal,
                                    // runSpacing: 10,
                                    // spacing: 10,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _launchURL();
                                        },
                                        child: smallCardButton(
                                            color: lightGreenish,
                                            height: _height * 0.15,
                                            width: _width * 0.25,
                                            imageAsset:
                                                "assets/images/youtube.png",
                                            isPurchasedPackage: true,
                                            icon: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 42.0,
                                            )),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          if (isPackagePurchased == false &&
                                              isConsumer == true) {
                                            onAlert(
                                              context,
                                              'Alert',
                                              'Please buy any subscription plan to access this feature.',
                                              AlertType.warning,
                                              isNavigation: false,
                                              btnText: 'Okay',
                                            );
                                          } else {
                                            Get.toNamed("/appointments");
                                          }
                                        },
                                        child: mediumBox(
                                            textColor: appSecondaryColor,
                                            height: _height * 0.15,
                                            width: _width * 0.58,
                                            labelText: "Upcoming Appointment: ",
                                            text: getRecentAppointments
                                                    .isNotEmpty
                                                ? getRecentAppointments
                                                        .last['time'] +
                                                    ' ' +
                                                    getRecentAppointments
                                                        .last['date']
                                                : 'No approved appointments.',
                                            icon: Icon(
                                              isConsumer == false
                                                  ? Icons.av_timer_rounded
                                                  : isPackagePurchased == true
                                                      ? Icons.av_timer_rounded
                                                      : Icons
                                                          .lock_outline_rounded,
                                              size: 32.0,
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed("/categories");

                                      // NotificationsServices.sendNotification(
                                      //     serverKey, fcmToken,
                                      //     body:
                                      //         'Your package has been approved, now you can chat and book appointment!',
                                      //     title: 'Package Approved!',
                                      //     status: 'Approved',
                                      //     type: 'package',
                                      //     uid: currentUser.uid,
                                      //     displayName: 'ibbi');
                                    },
                                    child: bigBox(
                                        height: _height * 0.3,
                                        width: _width,
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        labelText: "Guided Meditations",
                                        text: "Active Trips",
                                        imageURL: "assets/images/bgImage2.jpg"),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (isPackagePurchased == false &&
                                              isConsumer == true) {
                                            onAlert(
                                              context,
                                              'Alert',
                                              'Please buy any subscription plan to access this feature.',
                                              AlertType.warning,
                                              isNavigation: false,
                                              btnText: 'Okay',
                                            );
                                          } else {
                                            isConsumer == false
                                                ? Get.toNamed("/chat")
                                                : Get.to(() => ChatMsgScreen(
                                                    friendUid: AuthUtils
                                                        .getFriendUid(),
                                                    friendName: AuthUtils
                                                        .getFriendName()));
                                          }
                                        },
                                        child: smallBox(
                                            boxColor: appSecondaryColor,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42,
                                            labelText:
                                                "Send a message to Sir Lateef Ghauri",
                                            text: "Active Trips",
                                            icon: Icon(
                                              isConsumer == false
                                                  ? Icons.chat_bubble_rounded
                                                  : isPackagePurchased == true
                                                      ? Icons
                                                          .chat_bubble_rounded
                                                      : Icons
                                                          .lock_outline_rounded,
                                              size: 32.0,
                                            )),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          if (isPackagePurchased == false &&
                                              isConsumer == true) {
                                            onAlert(
                                              context,
                                              'Alert',
                                              'Please buy any subscription plan to access this feature.',
                                              AlertType.warning,
                                              isNavigation: false,
                                              btnText: 'Okay',
                                            );
                                          } else {
                                            Get.toNamed("/booking");
                                          }
                                        },
                                        child: smallBox(
                                            boxColor: sandColor,
                                            textColor: appSecondaryColor,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42,
                                            labelText: isConsumer == false
                                                ? "Add Time Slots"
                                                : "Book Appointment",
                                            text: "Active Trips",
                                            icon: Icon(
                                              isPackagePurchased == true
                                                  ? Icons.bookmarks_rounded
                                                  : Icons.lock_outline_rounded,
                                              size: 32.0,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // space for not cutting items if media player is showing
                              AuthUtils.getIsMusicPlaying() == true
                                  ? SizedBox(
                                      height: _height * 0.2,
                                    )
                                  : Container(),
                            ],
                          ).paddingOnly(left: 20, right: 20),
                        ),
                      )),
                ),
                MediaPlayer(),
              ],
            ),
          );
  }
}

// ignore_for_file: file_names, prefer_const_constructors

import 'dart:convert';
import 'dart:ui';
import 'package:meditation/Pages/Playlist/mediaPlayer.dart';
import 'package:meditation/Utils/authUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../main.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  FocusNode btnFocus = FocusNode();
  final btnKey = GlobalKey();

  int getNotificationResponseCount = 0;

  // List
  List pendingPackages = [];
  List verifiedPackages = [];
  List apporvedPackages = [];
  List rejectedPackages = [];
  List notificationsList = [];
  dynamic getUserData;

  // Firebase
  dynamic getCurrentUserDetailsResponse;
  bool isPackagePurchased = false;
  bool isConsumer = true;
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isPhoneLogin = false;
  bool checkStatus = false;

  final ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();
    if (isConsumer == false) {
      await getAllUsersNotifications('verified');
      await getAllUsersNotifications('pending');
      await getAllUsersNotifications('approved');
      await getAllUsersNotifications('rejected');
    } else {
      await getCurrentUserNotifications('verified');
      await getCurrentUserNotifications('pending');
      await getCurrentUserNotifications('approved');
      await getCurrentUserNotifications('rejected');
    }
  }

  // get All Users notifications
  getAllUsersNotifications(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('notifications')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          getUserData = documentSnapshot.data();
        });
        // logger.d(getUserData.toString());
      }
    });
    if (getUserData != null || getUserData['data'].length != 0) {
      for (int i = 0; i < getUserData['data'].length; i++) {
        if (docType == 'verified') {
          setState(() {
            verifiedPackages.add(getUserData['data'][i]);
          });
        } else if (docType == 'pending') {
          setState(() {
            pendingPackages.add(getUserData['data'][i]);
          });
        } else if (docType == 'approved') {
          setState(() {
            apporvedPackages.add(getUserData['data'][i]);
          });
        } else if (docType == 'rejected') {
          setState(() {
            rejectedPackages.add(getUserData['data'][i]);
          });
        }
      }
      setState(() {
        notificationsList = verifiedPackages +
            apporvedPackages +
            rejectedPackages +
            pendingPackages;
        notificationsList = notificationsList.reversed.toList();
      });
    }
    logger.d('getAllUsersPackages');
  }

  // get current user notifications
  getCurrentUserNotifications(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('notifications')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          getUserData = documentSnapshot.data();
        });
        // logger.d(getUserData.toString());
      }
    });
    if (getUserData != null || getUserData['data'].length != 0) {
      for (int i = 0; i < getUserData['data'].length; i++) {
        if (getUserData['data'][i]['uid'] == currentUser!.uid &&
            docType == 'verified') {
          setState(() {
            verifiedPackages.add(getUserData['data'][i]);
          });
        } else if (getUserData['data'][i]['uid'] == currentUser!.uid &&
            docType == 'pending') {
          setState(() {
            pendingPackages.add(getUserData['data'][i]);
          });
        } else if (getUserData['data'][i]['uid'] == currentUser!.uid &&
            docType == 'approved') {
          setState(() {
            // hide current user its own chat notifications and add other notifications
            if (getUserData['data'][i]['type'] != 'chat') {}
          });
        } else if (getUserData['data'][i]['uid'] == currentUser!.uid &&
            docType == 'rejected') {
          setState(() {
            rejectedPackages.add(getUserData['data'][i]);
          });
        }
      }
      setState(() {
        notificationsList = pendingPackages +
            verifiedPackages +
            apporvedPackages +
            rejectedPackages;
      });
    }
    logger.d('getCurrentUserPackages');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        AuthUtils.getIsMusicPlaying() == true
            ? Get.toNamed('/home')
            : Get.back();
        return false;
      },
      child: Scaffold(
          key: scaffoldKey,
          drawer: drawer(context, isPackagePurchased, isConsumer),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: appbarCustom(
                      globalKey: scaffoldKey,
                      textColor: blackTextColor,
                      isShadow: false,
                      labelText: "Notifications",
                      bgColor: lightBlue,
                      screenName: '/home',
                      isMusicPlaying: AuthUtils.getIsMusicPlaying())
                  .paddingOnly(top: 25.0)),
          body: SafeArea(
            child: notificationsList.isEmpty
                ? noMsgText('No notifications.')
                : Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                              child: ListView.separated(
                            controller: _controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: notificationsList.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () {},
                                child: notificationBox(
                                    width: _width,
                                    height: _height * 0.15,
                                    labelText: notificationsList[i]
                                        ['displayName'],
                                    lastMsg: notificationsList[i]['body'],
                                    time: notificationsList[i]['day'] +
                                        ', ' +
                                        notificationsList[i]['time']),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: lightGrey,
                              );
                            },
                          )),
                        ],
                      ).paddingOnly(left: 20.0, right: 20.0),
                      MediaPlayer(),
                    ],
                  ),
          )),
    );
  }
}

// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_7.dart';
import 'package:get/get.dart';
import 'package:meditation/Pages/Authentication/authenticationServices.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../Utils/authUtils.dart';
import '../../main.dart';
import '../Notification/notificationsServices.dart';

class ChatMsgScreen extends StatefulWidget {
  final friendUid;
  final friendName;
  final photoUrl;
  const ChatMsgScreen({
    Key? key,
    this.friendUid,
    this.friendName,
    this.photoUrl,
  }) : super(key: key);

  @override
  ChatMsgScreenState createState() =>
      ChatMsgScreenState(friendUid, friendName, photoUrl);
}

class ChatMsgScreenState extends State<ChatMsgScreen> {
  // screen fields
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();
  bool error = false;
  String errorText = "";
  FocusNode btnFocus = FocusNode();
  bool isloading = false;

  // firebase fields
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  dynamic friendUid;
  dynamic friendName;
  dynamic friendDetails;
  dynamic photoUrl;
  bool isConsumer = false;
  dynamic totalMsgs;
  int currentMsgCount = 0;
  int currentUnreadMsgCount = 0;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser!;
  dynamic chatDocId;

  // screen details
  ChatMsgScreenState(this.friendUid, this.friendName, this.photoUrl);
  dynamic argumentData = Get.arguments;

  // controllers
  final TextEditingController _textController = new TextEditingController();
  final _controller = ScrollController();
  TextEditingController chatController = TextEditingController();

  // user details
  bool isPackagePurchased = false;
  bool isPhoneLogin = false;
  dynamic getCurrentUserDetailsResponse;
  dynamic getFriendUserDetailsResponse;
  bool isFriendInChat = false;
  String displayName = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // get current user details
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser);
    setState(() {
      isConsumer = AuthUtils.getIsConsumer();
      isPhoneLogin = AuthUtils.getIsPhoneLogin();
    });
    // get displayname
    if (isPhoneLogin == true) {
      displayName = getCurrentUserDetailsResponse['displayName'];
    } else {
      displayName = currentUser.displayName!;
    }
    // get unread msg counter
    if (getCurrentUserDetailsResponse['chatDetails'] != null) {
      setState(() {
        currentUnreadMsgCount = getCurrentUserDetailsResponse['chatDetails']
            ['unreadMsgBy'][friendUid];
      });
    }
    // get totalmsgs for consumer
    if (isConsumer == true) {
      if (getCurrentUserDetailsResponse['packageDetails']['packagePurchased'] !=
              null ||
          getCurrentUserDetailsResponse['appointments'] != null) {
        setState(() {
          totalMsgs =
              getCurrentUserDetailsResponse['packageDetails']['totalMsgs'];
        });
      }
      setState(() {
        isPackagePurchased = AuthUtils.getPackagePurchased();
        currentMsgCount = totalMsgs;
      });
    }

    // read all msgs
    await Authentication.updateUserDetails(false, 'chatDetails', 0, friendUid,
        fieldName2: 'unreadMsgBy',
        updateChatDetails: true,
        fieldName3: currentUserId);

    // check if users chat docs exist
    checkUser();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    // update user current screen status
    await Authentication.updateUserDetails(
      true,
      'currentAppScreen',
      '',
      currentUser.uid,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void checkConsumer() async {
    if (isConsumer == false) {
    } else {
      if (friendUid == null) {
        setState(() {
          friendUid = AuthUtils.getFriendUid();
          friendName = AuthUtils.getFriendName();
        });
      }
    }
  }

  void checkUser() async {
    await chats
        .where('users', isEqualTo: {friendUid: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });

              logger.d(chatDocId);
            } else {
              await chats.add({
                'users': {currentUserId: null, friendUid: null}
              }).then((value) => {
                    setState(() {
                      chatDocId = value.id;
                    })
                  });
            }
          },
        )
        .catchError((error) {});
  }

  void sendMessage(String msg) {
    if (msg == '') return;
    chats.doc(chatDocId).collection('messages').add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentUserId,
      'msg': msg
    }).then((value) async {
      _textController.text = '';
    });
  }

  bool isSender(String friend) {
    return friend == currentUserId;
  }

  Alignment getAlignment(friend) {
    if (friend == currentUserId) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  void sendChatNotifications() async {
    dynamic userDetails = await Authentication.getUserDetailsWithId(friendUid);
    await NotificationsServices.sendNotification(
        AuthUtils.getServerKey(), userDetails['fcmToken'],
        displayName: displayName,
        body: displayName + ' sent you the message!',
        title: 'You got message!',
        status: 'approved',
        type: 'chat',
        uid: currentUserId);
    await NotificationsServices.addNotificationToCollection(
        displayName + ' sent you the message!',
        'You got message!',
        DateTime.now().toString(),
        time,
        displayName,
        currentUserId,
        'approved',
        'chat');
  }

  Future<void> checkFriendIsOnline() async {
    // check if friend user is in chat.
    getFriendUserDetailsResponse =
        await Authentication.getUserDetailsWithId(friendUid);
    if (getFriendUserDetailsResponse != null) {
      if (getFriendUserDetailsResponse['currentAppScreen'] ==
          'chatMsg$friendUid') {
        setState(() {
          isFriendInChat = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = Get.width;
    final _height = Get.height;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: chats
            .doc(chatDocId)
            .collection('messages')
            .orderBy('createdOn', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }

          // comment out if screen goes black
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: appPrimaryColor,
              ),
            );
          }

          if (snapshot.hasData) {
            var data;
            return Scaffold(
              drawer: drawer(context, isPackagePurchased, isConsumer),
              key: scaffoldKey,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: AppBar(
                  centerTitle: true,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.dark,
                    // systemNavigationBarColor: Colors.black, // navigation bar color
                    statusBarColor: whiteColor, // status bar color
                  ),
                  elevation: 0.0,
                  title: profileAvatar(
                      width: _width,
                      name: friendName,
                      textColor: blackTextColor,
                      profileImage: photoUrl,
                      fontSize: 16),
                  leading: BackButton(
                    color: blackTextColor,
                    onPressed: () async {
                      Get.back();
                    },
                  ),
                  backgroundColor: lightBlue,
                  actions: <Widget>[
                    IconButton(
                      color: blackTextColor,
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        scaffoldKey!.currentState!.openDrawer();
                      },
                    ),
                  ],
                ).paddingOnly(top: 25.0),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        reverse: true,
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            data = document.data()!;
                            logger.d(currentUserId == data['uid']);
                            logger.d(data['msg']);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChatBubble(
                                clipper: ChatBubbleClipper7(
                                  // nipSze: 0,
                                  radius: 15,
                                  type: currentUserId == data['uid']
                                      ? BubbleType.sendBubble
                                      : BubbleType.receiverBubble,
                                ),
                                alignment: getAlignment(data['uid'].toString()),
                                margin: EdgeInsets.only(top: 20),
                                backGroundColor:
                                    // isSender(data['uid'].toString())
                                    currentUserId == data['uid']
                                        ? appPrimaryColor
                                        : lightBlue,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.73,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _width * 0.7,
                                            constraints: const BoxConstraints(
                                              maxWidth: 500,
                                            ),
                                            child: Text(data['msg'],
                                                style: TextStyle(
                                                    color: currentUserId ==
                                                            data['uid']
                                                        ? Colors.white
                                                        : Colors.black),
                                                maxLines: 100,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            data['createdOn'] == null
                                                ? DateTime.now().toString()
                                                : data['createdOn']
                                                    .toDate()
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    currentUserId == data['uid']
                                                        ? Colors.white
                                                        : Colors.black),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ).paddingOnly(left: 20.0, right: 20.0, bottom: 10.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: CustomInputDecoration(
                                errorTextSize: 14.0,
                                inputBorder: InputBorder.none,
                                filled: true,
                                hint: "Type something....",
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (isConsumer == true) {
                                      if (totalMsgs != 0) {
                                        setState(() {
                                          totalMsgs -= 1;
                                        });
                                        // await Authentication.updatePackageCounter(
                                        //     true, totalMsgs, currentUserId);
                                        await Authentication.updateUserDetails(
                                            false,
                                            'packageDetails',
                                            totalMsgs,
                                            currentUser.uid,
                                            fieldName2: 'totalMsgs');
                                        sendMessage(_textController.text);
                                        // update unread msg counter
                                        await Authentication.updateUserDetails(
                                            false,
                                            'chatDetails',
                                            currentUnreadMsgCount + 1,
                                            currentUserId,
                                            fieldName2: 'unreadMsgBy',
                                            updateChatDetails: true,
                                            fieldName3: friendUid);
                                        await checkFriendIsOnline();
                                        if (isFriendInChat != true) {
                                          sendChatNotifications();
                                        }
                                      } else {
                                        onAlert(
                                          context,
                                          'Alert',
                                          'You have reached your daily message limit.',
                                          AlertType.warning,
                                          isNavigation: false,
                                          btnText: 'Okay',
                                        );
                                      }
                                    } else {
                                      sendMessage(_textController.text);
                                      // update unread msg counter
                                      await Authentication.updateUserDetails(
                                          false,
                                          'chatDetails',
                                          currentUnreadMsgCount + 1,
                                          currentUserId,
                                          fieldName2: 'unreadMsgBy',
                                          updateChatDetails: true,
                                          fieldName3: friendUid);
                                      await checkFriendIsOnline();
                                      if (isFriendInChat != true) {
                                        sendChatNotifications();
                                      }
                                    }
                                  },
                                  icon: isConsumer == true
                                      ? totalMsgs != 0
                                          ? Icon(Icons.send_outlined)
                                          : Icon(Icons.lock_outline_rounded)
                                      : Icon(Icons.send_outlined),
                                )),
                          ),
                        )
                      ],
                    ).paddingOnly(left: 20.0, right: 20.0, bottom: 10.0)
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

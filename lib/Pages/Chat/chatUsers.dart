// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation/Pages/Chat/chatMsg.dart';
import 'package:meditation/Utils/authUtils.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../main.dart';
import '../Authentication/authenticationServices.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();
  bool error = false;
  FocusNode focusController = FocusNode();
  FocusNode groupFocusController = FocusNode();
  bool isloading = false;

  // search query fields
  List<dynamic> searchQueryData = [];
  List<dynamic> dummyListData = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController groupController = TextEditingController();

  bool isQuerySearched = true;

  late Map<String, dynamic> screenData = <String, dynamic>{};

  // Firebase
  final currentUser = FirebaseAuth.instance.currentUser!;
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  dynamic getCurrentUserDetailsResponse;

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  ScrollController _controller = new ScrollController();

  // user details
  bool isPackagePurchased = false;
  bool isConsumer = true;
  bool isUserOnline = false;
  String currentAppScreen = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();

    // get current user details
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser);
    if (getCurrentUserDetailsResponse != null) {
      setState(() {
        isUserOnline = getCurrentUserDetailsResponse['isUserOnline'];
        currentAppScreen = getCurrentUserDetailsResponse['currentAppScreen'];
      });
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

  void filterSearchResults(String searchedItem) {
    if (searchedItem.isNotEmpty) {
      setState(() {
        dummyListData.clear();
        dummyListData = searchQueryData
            .where(
                (data) => data["displayName"].toString().contains(searchedItem))
            .toList();
        if (dummyListData.isEmpty) {
          isQuerySearched = false;
        } else {
          isQuerySearched = true;
        }
      });
      logger.d("");
    } else {
      setState(() {});
    }
  }

  void callChatDetailScreen(BuildContext context, String name, String uid,
      bool isConsumer, int totalMsgs, dynamic photoUrl) async {
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) =>
    //             ChatMsgScreen(friendUid: uid, friendName: name)));

    // update user current screen status
    await Authentication.updateUserDetails(
      true,
      'currentAppScreen',
      'chatMsg$uid',
      currentUser.uid,
    );

    Get.to(() => ChatMsgScreen(
          friendUid: uid,
          friendName: name,
          photoUrl: photoUrl,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              // .where('uid', isNotEqualTo: currentUserUid)
              // .orderBy('uid', descending: false)
              .orderBy('lastMsgTime', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: noMsgText("Something went wrong"),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: appPrimaryColor,
              ));
            }

            if (snapshot.hasData) {
              return Scaffold(
                drawer: drawer(context, isPackagePurchased, isConsumer),
                key: scaffoldKey,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: appbarCustom(
                            globalKey: scaffoldKey,
                            isShadow: false,
                            labelText: "Chat",
                            bgColor: lightBlue)
                        .paddingOnly(top: 25.0)),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          dynamic data = document.data()!;
                          return data['uid'] == currentUserUid
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    callChatDetailScreen(
                                      context,
                                      data['displayName'],
                                      data['uid'],
                                      data['isConsumer'],
                                      data['packageDetails']['totalMsgs'] ?? 0,
                                      data['photoURL'],
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      chatLoadBox(
                                          isUserOnline:
                                              data["isUserOnline"] ?? false,
                                          isPackagePurchased:
                                              data["packageDetails"]
                                                  ['packagePurchased'],
                                          width: _width,
                                          isProfileImage: true,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          labelText: data["displayName"],
                                          lastMsg: data["email"],
                                          time: data["lastMsgTime"]
                                              .toDate()
                                              .toString()
                                              .split(' ')[0],
                                          profileImageUrl: data["photoURL"] ??
                                              "https://cdn-icons-png.flaticon.com/512/21/21104.png",
                                          unreadMsgCount: data['chatDetails']
                                                      ['unreadMsgBy'] ==
                                                  null
                                              ? 0
                                              : data['chatDetails']
                                                          ['unreadMsgBy']
                                                      [currentUserUid] ??
                                                  0),
                                      Divider(
                                        color: lightGrey,
                                      )
                                    ],
                                  ),
                                );
                        },
                      ).toList(),
                    ).paddingOnly(left: 20.0, right: 20.0),
                  ),
                ),
              );
            }
            return Container();
          }),
    );
  }
}

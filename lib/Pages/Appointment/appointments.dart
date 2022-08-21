// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditation/Pages/Chat/chatMsg.dart';
import 'package:meditation/Pages/Playlist/mediaPlayer.dart';
import 'package:meditation/Utils/authUtils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../Utils/status.dart';
import '../../main.dart';
import '../Authentication/authenticationServices.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../Booking/bookingServices.dart';
import '../Notification/notificationsServices.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  AppointmentsScreenState createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  // screen data
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  late Map<String, dynamic> screenData = <String, dynamic>{};

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // controllers
  final ScrollController _controller = ScrollController();

  // user details
  bool isPackagePurchased = false;
  bool isConsumer = true;
  User? currentUser = FirebaseAuth.instance.currentUser;
  dynamic currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isPhoneLogin = false;

  // List
  List pendingAppointments = [];
  List verifiedAppointments = [];
  List apporvedAppointments = [];
  dynamic indexList = [];
  dynamic getUserData;
  List getUsersName = [];

  //
  dynamic displayName;
  dynamic date;
  dynamic day;
  dynamic status;
  dynamic statusCode;
  dynamic uid;
  dynamic url;
  dynamic time;
  dynamic timeSlot;

  // image fields
  late Image image = Image.network('');
  final imagePicker = ImagePicker();
  dynamic fileExtension;
  dynamic fileName;
  String base64Image = "";
  List<int> imageBytes = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isConsumer = AuthUtils.getIsConsumer();
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isPhoneLogin = AuthUtils.getIsPhoneLogin();
    if (isConsumer == false) {
      await getAllUsersAppointment('verified');
      await getAllUsersAppointment('pending');
      await getAllUsersAppointment('approved');
    } else {
      await getCurrentUserAppointment('verified');
      await getCurrentUserAppointment('pending');
      await getCurrentUserAppointment('approved');
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

  Future getDocs() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      logger.d(a.id);
    }
  }

  // get current user appointments
  getCurrentUserAppointment(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('appointments')
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
        if (getUserData['data'][i]['uid'] == currentUserId &&
            docType == 'verified') {
          setState(() {
            verifiedAppointments.add(getUserData['data'][i]);
          });
        } else if (getUserData['data'][i]['uid'] == currentUserId &&
            docType == 'pending') {
          setState(() {
            pendingAppointments.add(getUserData['data'][i]);
          });
        } else if (getUserData['data'][i]['uid'] == currentUserId &&
            docType == 'approved') {
          setState(() {
            apporvedAppointments.add(getUserData['data'][i]);
          });
        }
      }
    }
    logger.d(docType);
  }

  // get All Users Appointment
  getAllUsersAppointment(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('appointments')
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
            verifiedAppointments.add(getUserData['data'][i]);
          });
        } else if (docType == 'pending') {
          setState(() {
            pendingAppointments.add(getUserData['data'][i]);
          });
        } else if (docType == 'approved') {
          setState(() {
            apporvedAppointments.add(getUserData['data'][i]);
          });
        }
      }
    }
    logger.d(docType);
  }

  void paymentReceived(
      isIndivisual,
      displayName,
      uid,
      url,
      String docType,
      User user,
      int day,
      String time,
      String timeSlot,
      String date,
      status) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removeAppointment(
        isPhoneLogin,
        isIndivisual,
        displayName,
        uid,
        url,
        docType,
        user,
        day,
        time,
        timeSlot,
        date,
        status);
    await Authentication.addAppointmentCollection(isPhoneLogin, isIndivisual,
        'approved', user, day, time, timeSlot, date, 'Approved',
        displayName: displayName, uid: uid, url: url);
    // send notifications to consumer
    dynamic userDetails = await Authentication.getUserDetailsWithId(uid);
    await NotificationsServices.sendNotification(
        AuthUtils.getServerKey(), userDetails['fcmToken'],
        displayName: userDetails['displayName'],
        body: 'Your appointment has been approved!',
        title: 'Appointment Approved!',
        status: 'Approved',
        type: 'appointment',
        uid: uid);
    await NotificationsServices.addNotificationToCollection(
        'Your appointment has been approved!',
        'Appointment Approved!',
        date,
        time,
        displayName,
        uid,
        status,
        'appointment');

    verifiedAppointments.clear();
    apporvedAppointments.clear();
    await getAllUsersAppointment('verified');
    await getAllUsersAppointment('approved');
    setState(() {
      isLoading = false;
    });
  }

  void paymentNotReceived(
      bool isIndivisual,
      String? displayName,
      String uid,
      String? url,
      String docType,
      User user,
      int day,
      String time,
      String timeSlot,
      String date,
      status) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removeAppointment(
        isPhoneLogin,
        isIndivisual,
        displayName,
        uid,
        url,
        docType,
        user,
        day,
        time,
        timeSlot,
        date,
        status);
    await Authentication.addAppointmentCollection(isPhoneLogin, isIndivisual,
        'pending', user, day, time, timeSlot, date, 'Rejected',
        displayName: displayName, uid: uid, url: url);
    // add appointment counter and timeslot again if rejected
    await Authentication.updateUserDetails(false, 'packageDetails', 1, uid,
        fieldName2: 'totalAppointments');
    //  add timeSlot
    await BookingServices.addRejectedTimeSlotDoc(day, time);
    // send notifications to consumer
    dynamic userDetails = await Authentication.getUserDetailsWithId(uid);
    NotificationsServices.sendNotification(
        AuthUtils.getServerKey(), userDetails['fcmToken'],
        body: 'Your appointment has been rejected!',
        title: 'Appointment Rejected!',
        status: 'Rejected',
        type: 'appointment',
        uid: uid);
    NotificationsServices.addNotificationToCollection(
        'Your appointment has been rejected!',
        'Appointment Rejected!',
        date,
        time,
        displayName,
        uid,
        status,
        'appointment');

    verifiedAppointments.clear();
    pendingAppointments.clear();
    await getAllUsersAppointment('verified');
    await getAllUsersAppointment('pending');
    setState(() {
      isLoading = false;
    });
  }

  void sendPaymentSS(
      isIndivisual,
      displayName,
      uid,
      url,
      String docType,
      User user,
      int day,
      String time,
      String timeSlot,
      String date,
      status) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removeAppointment(
        isPhoneLogin,
        isIndivisual,
        displayName,
        uid,
        url,
        docType,
        user,
        day,
        time,
        timeSlot,
        date,
        status);
    await Authentication.addAppointmentCollection(isPhoneLogin, isIndivisual,
        'verified', user, day, time, timeSlot, date, 'Pending',
        displayName: displayName, uid: uid, url: url);

    verifiedAppointments.clear();
    pendingAppointments.clear();
    await getAllUsersAppointment('verified');
    await getAllUsersAppointment('pending');
    setState(() {
      isLoading = false;
    });
  }

  void selectFile() async {
    setState(() {
      isLoading = false;
    });
    // FilePickerResult? result = await FilePicker.platform.pickFiles();
    final result = await imagePicker.pickImage(source: ImageSource.gallery);
    // var filePath = result!.files.single.path;
    var filePath = result!.path;

    if (result != null) {
      File file = File(filePath);
      await imageToBase64(file);
      setState(() {
        // isImage = true;
        fileName = file.path.split("cache/").last;
        fileExtension = file.path.split(".").last;
        // image = Image.file(file);
      });
      uploadReceipt();
    }
    setState(() {
      isLoading = true;
    });
  }

  Future imageToBase64(File file) async {
    imageBytes = await file.readAsBytes();
    setState(() {
      base64Image = base64Encode(imageBytes);
    });
  }

  void getCamImage() async {
    setState(() {
      isLoading = false;
    });
    final camImage = await imagePicker.pickImage(source: ImageSource.camera);
    File file = File(camImage!.path);
    imageToBase64(file);
    if (file != null) {
      setState(() {
        // isImage = true;
        fileName = file.path.split("cache/").last;
        fileExtension = file.path.split(".").last;
        // image = Image.file(file);
      });
      // Get.back();
      uploadReceipt();
    } else {
      setState(() {
        // isImage = false;
      });
    }
    setState(() {
      isLoading = true;
    });
  }

  void uploadReceipt() async {
    String imageResponse = await BookingServices.uploadImage(
      fileName,
      fileExtension,
      base64Image,
    );
    if (imageResponse != '') {
      setState(() {
        isLoading = false;
        error = "Image uploaded";
      });
      if (isConsumer == true) {
        sendPaymentSS(true, displayName, uid, url, 'pending', currentUser!, day,
            time, timeSlot, date, status);
      }
      screenData['routeName'] = Get.currentRoute;
      onAlert(context, 'Alert', 'Your image is uploaded', AlertType.success,
          isNavigation: true,
          screenName: '/home',
          btnText: 'Okay',
          argData: screenData);
    }
  }

  showAppointments(List appointments) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return appointments.isEmpty
        ? noMsgText('No appointments.')
        : Column(
            children: [
              Expanded(
                  child: ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: appointments.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   displayName = appointments[i]['displayName'];
                      //   day = appointments[i]['day'];
                      //   date = appointments[i]['date'];
                      //   status = appointments[i]['status'];
                      //   statusCode = appointments[i]['statusCode'];
                      //   time = appointments[i]['time'];
                      //   timeSlot = appointments[i]['timeSlot'];
                      //   uid = appointments[i]['uid'];
                      //   url = appointments[i]['url'];
                      // });
                      // if (appointments[i]['statusCode'] == 0) {
                      //   imageUploadBottomSheet(
                      //       context, _width, _height, getCamImage, selectFile);
                      // }
                    },
                    child: appointmentBox(
                        width: _width,
                        height: _height,
                        getUserData: getUserData,
                        isProfileImage: true,
                        isConsumer: isConsumer,
                        index: i,
                        // height:
                        //     MediaQuery.of(context).size.height * 0.2,
                        uid: appointments[i]['uid'],
                        name: appointments[i]['displayName'],
                        postType: 'Astrologist',
                        time: appointments[i]['time'],
                        timeSlot: appointments[i]['timeSlot'],
                        date: appointments[i]['date'],
                        status: appointments[i]['status'],
                        statusCode: appointments[i]['statusCode'],
                        imageUrl: appointments[i]['url'],
                        day: appointments[i]['day'],
                        appointmentTitle: appointments[i]['appointmentTitle'],
                        profileImageUrl: '',
                        paymentReceived: paymentReceived,
                        paymentNotReceived: paymentNotReceived,
                        isIndivisual: false),
                  );
                },
              )),
              // Divider(
              //   color: lightGrey,
              // ),
            ],
          ).paddingOnly(left: 20.0, right: 20.0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
            body: Scaffold(
          key: scaffoldKey,
          drawer: drawer(context, isPackagePurchased, isConsumer),
          body: Stack(
            children: [
              NestedScrollView(
                physics: NeverScrollableScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    new SliverAppBar(
                      foregroundColor: appPrimaryColor,
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarIconBrightness: Brightness.dark,
                      ),
                      bottom: TabBar(
                        labelColor: lightBlue,
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor: lightBlue,
                        automaticIndicatorColorAdjustment: true,
                        indicatorColor: appPrimaryColor,
                        tabs: <Widget>[
                          Tab(
                            child: Text("Rejected",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                )),
                          ),
                          Tab(
                            child: Text("Pending",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                )),
                          ),
                          Tab(
                            child: Text("Approved",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                )),
                          ),
                        ],
                      ),
                      elevation: 0.0,
                      title: Text("Appointment",
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.black,
                          )),
                      leading: BackButton(
                        color: Colors.black,
                        onPressed: () async {
                          Get.toNamed('/home');
                        },
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ],
                      centerTitle: true,
                      backgroundColor: Colors.white,
                    )
                  ];
                },
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: TabBarView(children: <Widget>[
                    // pending tab content
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : pendingAppointments.isEmpty
                            ? noMsgText('No pending appointments.')
                            : showAppointments(pendingAppointments),
                    // verified  content tab
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : verifiedAppointments.isEmpty
                            ? noMsgText('No verified appointments.')
                            : showAppointments(verifiedAppointments),
                    // Approved  content tab
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : apporvedAppointments.isEmpty
                            ? noMsgText('No approved appointments.')
                            : showAppointments(apporvedAppointments),
                  ]),
                ),
              ),
              MediaPlayer()
            ],
          ),
        )));
  }
}

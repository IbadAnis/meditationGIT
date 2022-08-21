// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meditation/Pages/Booking/bookingServices.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../Utils/authUtils.dart';
import '../../Utils/bottomBar.dart';
import '../../Utils/photoItem.dart';
import '../../main.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Authentication/authenticationServices.dart';
import '../Notification/notificationsServices.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  BankDetailsScreenState createState() => BankDetailsScreenState();
}

class BankDetailsScreenState extends State<BankDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String checkVersion = "";

  final storage = GetStorage();

  dynamic argumentData = Get.arguments;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  // chats & notification fields
  int notificationCounter = 0;

  // firebase
  firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref('/receipts');
  FirebaseAuth auth = FirebaseAuth.instance;
  User? googleUserDetails;
  User? currentUser = FirebaseAuth.instance.currentUser;

  // user details
  bool isPackagePurchased = false;
  bool isConsumer = true;
  bool isPhoneLogin = false;

  // image fields
  late Image image = Image.network('');
  final imagePicker = ImagePicker();
  dynamic fileExtension;
  dynamic fileName;
  String base64Image = "";
  List<int> imageBytes = [];
  String imageResponse = '';

  // booking details
  String selectedSlotTime = "";
  String selectedSlot = '';
  int currentDay = 0;
  String selectedDate = '';
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime currentDate = DateTime.now();

  // subscription details
  String packageType = '';
  String packageTime = '';
  String packageDate = '';
  int packageAmount = 0;
  int expiryDateDays = 0;
  int totalMsgs = 0;
  int totalAppointments = 0;

  bool isLoading = false;
  String error = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    isConsumer = AuthUtils.getIsConsumer();
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isPhoneLogin = AuthUtils.getIsPhoneLogin() ?? false;
    logger.d('screenData: ' + argumentData.toString());
    setState(() {
      googleUserDetails = auth.currentUser;
    });
    // if (argumentData != null && argumentData['routeName'] == '/booking') {
    //   setState(() {
    //     currentDay = argumentData["currentDay"];
    //     selectedSlotTime = argumentData["selectedSlotTime"];
    //     selectedDate = argumentData["selectedDate"];
    //     selectedSlot = argumentData["selectedSlot"];
    //   });
    // } else
    if (argumentData != null &&
        argumentData['routeName'] == '/subcriptionPlans') {
      setState(() {
        packageType = argumentData["packageType"];
        packageAmount = argumentData["packageAmount"];
        expiryDateDays = argumentData["expiryDateDays"];
        totalMsgs = argumentData["totalMsgs"];
        totalAppointments = argumentData["totalAppointments"];
        packageTime = argumentData["dateTime"].toString().split(' ').last;
        packageDate = argumentData["dateTime"].toString().split(' ').first;
      });
    }

    // get total msgs and appointments
    // if (packageType == 'bronze') {
    //   setState(() {
    //     totalMsgs = 2;
    //     totalAppointments = 2;
    //   });
    // } else if (packageType == 'silver') {
    //   setState(() {
    //     totalMsgs = 5;
    //     totalAppointments = 3;
    //   });
    // } else if (packageType == 'gold') {
    //   setState(() {
    //     totalMsgs = 10;
    //     totalAppointments = 5;
    //   });
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void selectFile() async {
    setState(() {
      isLoading = true;
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
  }

  Future imageToBase64(File file) async {
    imageBytes = await file.readAsBytes();
    setState(() {
      base64Image = base64Encode(imageBytes);
    });
  }

  void uploadReceipt() async {
    imageResponse = await BookingServices.uploadImage(
      fileName,
      fileExtension,
      base64Image,
    );
    if (imageResponse.isNotEmpty &&
        argumentData["routeName"] == '/subcriptionPlans') {
      if (packageType == 'Individual') {
        await Authentication.addCallAppointmentCollection(
            isPhoneLogin,
            true,
            'approved',
            currentUser!,
            formatter.format(currentDate),
            'Approved');
      }
      await Authentication.addPackageDetails(false, packageType, packageAmount,
          expiryDateDays, totalMsgs, totalAppointments, true, imageResponse);
      await Authentication.addPackageToCollection(
          true,
          'verified',
          googleUserDetails!,
          packageDate,
          packageTime,
          true,
          isPhoneLogin,
          packageType,
          packageAmount,
          expiryDateDays,
          totalMsgs,
          totalAppointments,
          true,
          imageResponse,
          'PaymentVerify');
    }
    screenData['routeName'] = Get.currentRoute;
    setState(() {
      isLoading = false;
      error = "Image uploaded";
    });
    // send notifications to non consumer
    if (isConsumer == true) {
      dynamic userDetails =
          await Authentication.getUserDetailsWithId(googleUserDetails!.uid);
      await NotificationsServices.sendNotification(
          AuthUtils.getServerKey(), AuthUtils.getAdminFcmToken(),
          displayName: userDetails['displayName'],
          body: userDetails['displayName'] + ' ' + 'has purchased a package.',
          title: 'Package Purchased',
          status: 'verified',
          type: 'package',
          uid: AuthUtils.getFriendUid());
      await NotificationsServices.addNotificationToCollection(
          userDetails['displayName'] + ' ' + 'has purchased a package.',
          'Package Purchased',
          formatter.format(currentDate),
          time,
          isPhoneLogin == true
              ? AuthUtils.getDisplayName()
              : googleUserDetails!.displayName,
          googleUserDetails!.uid,
          'verified',
          'package');
    }
    onAlert(context, 'Alert', 'Your image is uploaded', AlertType.success,
        isNavigation: true,
        screenName: '/home',
        btnText: 'Okay',
        argData: screenData);
  }

  void getCamImage() async {
    setState(() {
      isLoading = true;
    });
    final camImage = await imagePicker.pickImage(source: ImageSource.camera);
    File file = File(camImage!.path);
    await imageToBase64(file);
    if (file != null) {
      setState(() {
        // isImage = true;
        fileName = file.path.split("cache/").last;
        fileExtension = file.path.split(".").last;
        // image = Image.file(file);
      });
      // Get.back();
      uploadReceipt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: drawer(context, isPackagePurchased, isConsumer),
        key: scaffoldKey,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: appbarCustom(
                    globalKey: scaffoldKey,
                    isShadow: false,
                    labelText: "Payment",
                    bgColor: lightBlue)
                .paddingOnly(top: 25.0)),
        backgroundColor: Colors.white,
        // bottomNavigationBar: BottomBarScreen(),
        body: isLoading == true
            ? Center(
                child: CircularProgressIndicator(
                  color: appPrimaryColor,
                ),
              )
            : SafeArea(
                child: Center(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      headingText(
                          title: "Bank Account Details",
                          size: 24.0,
                          color: appPrimaryColor),
                      SizedBox(
                        height: 20,
                      ),
                      paragraphText(
                          title: "Account Title: Lateef ghauri",
                          size: 14.0,
                          color: lightGrey),
                      SizedBox(
                        height: 20,
                      ),
                      paragraphText(
                          title: "Account No: 50120081005924037 ",
                          size: 14.0,
                          color: lightGrey),
                      SizedBox(
                        height: 20,
                      ),
                      paragraphText(
                          title: "Bank: Bank al Habib limited",
                          size: 14.0,
                          color: lightGrey),
                      SizedBox(
                        height: 50,
                      ),
                      headingText(
                          title: "Easy Paisa Account",
                          size: 24.0,
                          color: appPrimaryColor),
                      SizedBox(
                        height: 20,
                      ),
                      paragraphText(
                          title: "92 332 3776978",
                          size: 14.0,
                          color: lightGrey),
                      const SizedBox(
                        height: 100,
                      ),
                      Container(
                        height: _height * 0.070,
                        width: _width,
                        child: ElevatedButton(
                          style: elevatedButtonSecondStyle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'PAY LATER',
                                // textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                              SizedBox(
                                width: _width * 0.01,
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: whiteColor,
                                size: 32.0,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await Authentication.addPackageToCollection(
                                true,
                                'pending',
                                googleUserDetails!,
                                packageDate,
                                packageTime,
                                false,
                                isPhoneLogin,
                                packageType,
                                packageAmount,
                                expiryDateDays,
                                totalMsgs,
                                totalAppointments,
                                false,
                                imageResponse,
                                'PaymentPending');
                            // Get.offAllNamed("/home", arguments: screenData);
                            onAlert(
                                context,
                                'Alert',
                                'Please check your subscription pending status.',
                                AlertType.warning,
                                isNavigation: true,
                                btnText: 'Okay',
                                argData: screenData,
                                screenName: '/home');
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: _height * 0.070,
                        width: _width,
                        child: ElevatedButton(
                          style: elevatedButtonSecondStyle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'UPLOAD Screenshot',
                                // textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                              SizedBox(
                                width: _width * 0.01,
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: whiteColor,
                                size: 32.0,
                              ),
                            ],
                          ),
                          onPressed: () {
                            imageUploadBottomSheet(context, _width, _height,
                                getCamImage, selectFile);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      paragraphText(
                          title: 'Submit your screenshot of payment',
                          size: 14.0,
                          color: lightGrey),
                    ],
                  ).paddingOnly(left: 20, right: 20),
                ),
              ));
  }
}

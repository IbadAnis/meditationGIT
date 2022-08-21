// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, unused_field, prefer_final_fields, sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditation/Pages/Authentication/authenticationServices.dart';
import 'package:meditation/Pages/Playlist/mediaPlayer.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import 'package:meditation/Utils/authUtils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../main.dart';
import '../Booking/bookingServices.dart';
import '../Notification/notificationsServices.dart';

class SubcriptionPlansScreen extends StatefulWidget {
  const SubcriptionPlansScreen({Key? key}) : super(key: key);

  @override
  SubcriptionPlansScreenState createState() => SubcriptionPlansScreenState();
}

class SubcriptionPlansScreenState extends State<SubcriptionPlansScreen> {
  String error = "";

  dynamic scaffoldKey = GlobalKey<ScaffoldState>();
  late Map<String, dynamic> loginData = <String, dynamic>{};
  final storage = GetStorage();
  bool isLoading = false;

  final PageController controller = PageController();
  int pageNumber = 0;

  // controllers
  final ScrollController _controller = ScrollController();

  // Firebase
  dynamic getCurrentUserDetailsResponse;
  bool isPackagePurchased = false;
  bool isConsumer = true;
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isPhoneLogin = false;
  bool checkStatus = false;

  // Data list
  List<dynamic> packagesData = [];
  Map<String, dynamic> screenData = <String, dynamic>{};

  // List
  List pendingPackages = [];
  List verifiedPackages = [];
  List apporvedPackages = [];
  List rejectedPackages = [];
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
  dynamic totalMsgs;
  dynamic totalAppointments;
  dynamic packageType;
  dynamic packagePurchased;
  dynamic packageAmount;
  dynamic isPackagePayment;
  dynamic imageUrl;
  dynamic expiryDateDays;
  dynamic docTypeName;

  // image fields
  late Image image = Image.network('');
  final imagePicker = ImagePicker();
  dynamic fileExtension;
  dynamic fileName;
  String base64Image = "";
  List<int> imageBytes = [];

  // screen data
  dynamic argumentData = Get.arguments;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (argumentData != null) {
      isCheckStatus(argumentData['isCheckStatus']);
    }

    isConsumer = AuthUtils.getIsConsumer();
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isPhoneLogin = AuthUtils.getIsPhoneLogin();
    setState(() {
      isLoading = true;
    });
    if (isConsumer == false) {
      await getAllUsersPackages('verified');
      await getAllUsersPackages('pending');
      await getAllUsersPackages('approved');
      await getAllUsersPackages('rejected');
    } else {
      await getCurrentUserPackages('verified');
      await getCurrentUserPackages('pending');
      await getCurrentUserPackages('approved');
      await getCurrentUserPackages('rejected');
    }
    // get current user details
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser!);
    logger.d("get CurrentUserDetailsResponse:" +
        getCurrentUserDetailsResponse.toString());
    // get all packages
    await FirebaseFirestore.instance
        .collection('packages')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          packagesData.add(doc.data());
        });
      }
      logger.d(packagesData);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // get current user packages
  getCurrentUserPackages(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('packages')
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
            apporvedPackages.add(getUserData['data'][i]);
          });
        } else if (getUserData['data'][i]['uid'] == currentUser!.uid &&
            docType == 'rejected') {
          setState(() {
            rejectedPackages.add(getUserData['data'][i]);
          });
        }
      }
    }
    logger.d(docType);
  }

  // get All Users Packages
  getAllUsersPackages(String docType) async {
    await FirebaseFirestore.instance
        .collection(docType)
        .doc('packages')
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
    String time,
    String date,
    String status,
    int statusCode,
    String packageType,
    int totalAppointments,
    int packageAmount,
    String expiryDate,
    int expiryDateDays,
    int totalMsgs,
    bool isPackagePayment,
    bool packagePurchased,
  ) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removePackageToCollection(
        false,
        docType,
        uid,
        displayName,
        user,
        date,
        time,
        packagePurchased,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDate,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        isPackagePayment,
        url,
        status);
    await Authentication.addPackageToCollection(
        false,
        'approved',
        user,
        date,
        time,
        true,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        true,
        url,
        'Approved',
        displayName: displayName,
        uid: uid);

    await Authentication.updateUserDetails(false, 'packageDetails', true, uid,
        fieldName2: 'packagePurchased');
    // send notifications to consumer
    dynamic userDetails = await Authentication.getUserDetailsWithId(uid);
    await NotificationsServices.sendNotification(
        AuthUtils.getServerKey(), userDetails['fcmToken'],
        displayName: userDetails['displayName'],
        body:
            'Your package has been approved, now you can chat and book appointment!',
        title: 'Package Approved!',
        status: 'Approved',
        type: 'package',
        uid: uid);
    await NotificationsServices.addNotificationToCollection(
        'Your package has been approved, now you can chat and book appointment!',
        'Package Approved!',
        date,
        time,
        displayName,
        uid,
        status,
        'package');

    verifiedPackages.clear();
    apporvedPackages.clear();
    await getAllUsersPackages('verified');
    await getAllUsersPackages('approved');
    setState(() {
      isLoading = false;
    });
  }

  void paymentNotReceived(
    isIndivisual,
    displayName,
    uid,
    url,
    String docType,
    User user,
    String time,
    String date,
    String status,
    int statusCode,
    String packageType,
    int totalAppointments,
    int packageAmount,
    String expiryDate,
    int expiryDateDays,
    int totalMsgs,
    bool isPackagePayment,
    bool packagePurchased,
  ) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removePackageToCollection(
        false,
        docType,
        uid,
        displayName!,
        user,
        date,
        time,
        packagePurchased,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDate,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        isPackagePayment,
        url,
        status);
    await Authentication.addPackageToCollection(
        false,
        'rejected',
        user,
        date,
        time,
        true,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        true,
        url,
        'Rejected',
        displayName: displayName,
        uid: uid);
    // add notifications
    dynamic userDetails = await Authentication.getUserDetailsWithId(uid);
    await NotificationsServices.sendNotification(
        AuthUtils.getServerKey(), userDetails['fcmToken'],
        body: 'Your package has been rejected!',
        title: 'Package Rejected!',
        status: 'Rejected',
        type: 'package',
        uid: uid);
    await NotificationsServices.addNotificationToCollection(
        'Your package has been rejected!',
        'Package Rejected!',
        date,
        time,
        displayName,
        uid,
        status,
        'package');

    verifiedPackages.clear();
    pendingPackages.clear();
    await getAllUsersPackages('verified');
    await getAllUsersPackages('pending');
    setState(() {
      isLoading = false;
    });
  }

  void sendPaymentSS(
    imageResponse,
    isIndivisual,
    displayName,
    uid,
    imageUrl,
    String docType,
    User user,
    String time,
    String date,
    String status,
    int statusCode,
    String packageType,
    int totalAppointments,
    int packageAmount,
    String expiryDate,
    int expiryDateDays,
    int totalMsgs,
    bool isPackagePayment,
    bool packagePurchased,
  ) async {
    setState(() {
      isLoading = true;
    });
    await Authentication.removePackageToCollection(
        false,
        docType,
        uid,
        displayName!,
        user,
        date,
        time,
        packagePurchased,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDate,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        isPackagePayment,
        imageUrl,
        status);
    await Authentication.addPackageToCollection(
        true,
        'verified',
        user,
        date,
        time,
        true,
        isPhoneLogin,
        packageType,
        packageAmount,
        expiryDateDays,
        totalMsgs,
        totalAppointments,
        true,
        imageResponse,
        'PaymentVerify',
        displayName: displayName,
        uid: uid);

    verifiedPackages.clear();
    pendingPackages.clear();
    await getAllUsersPackages('verified');
    await getAllUsersPackages('pending');
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

  Future imageToBase64(File file) async {
    imageBytes = await file.readAsBytes();
    setState(() {
      base64Image = base64Encode(imageBytes);
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
        sendPaymentSS(
          imageResponse,
          true,
          displayName,
          uid,
          imageUrl,
          docTypeName,
          currentUser!,
          time,
          date,
          status,
          statusCode,
          packageType,
          totalAppointments,
          packageAmount,
          expiryDate,
          expiryDateDays,
          totalMsgs,
          isPackagePayment,
          packagePurchased,
        );
      }
      screenData['routeName'] = Get.currentRoute;
      onAlert(context, 'Alert', 'Your image is uploaded', AlertType.success,
          isNavigation: true,
          screenName: '/home',
          btnText: 'Okay',
          argData: screenData);
    }
  }

  showPackages(List packages) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return packages.isEmpty
        ? noMsgText('No packages.')
        : Column(
            children: [
              Expanded(
                  child: ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: packages.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        uid = packages[i]['uid'];
                        displayName = packages[i]['displayName'];
                        time = packages[i]['time'];
                        date = packages[i]['date'];
                        status = packages[i]['status'];
                        statusCode = packages[i]['statusCode'];
                        imageUrl = packages[i]['imageUrl'];
                        isPackagePayment = packages[i]['isPackagePayment'];
                        packagePurchased = packages[i]['packagePurchased'];
                        totalMsgs = packages[i]['totalMsgs'];
                        totalAppointments = packages[i]['totalAppointments'];
                        packageAmount = packages[i]['packageAmount'];
                        packageType = packages[i]['packageType'];
                        expiryDateDays = packages[i]['expiryDateDays'];
                        expiryDate = packages[i]['expiryDate'];
                        if (statusCode == 0) {
                          docTypeName = 'pending';
                        } else if (statusCode == 3) {
                          docTypeName = 'rejected';
                        }
                      });

                      if (packages[i]['statusCode'] == 0 ||
                          packages[i]['statusCode'] == 3 &&
                              isConsumer == true) {
                        imageUploadBottomSheet(
                            context, _width, _height, getCamImage, selectFile);
                      } else
                      // if (packages[i]['statusCode'] == 2 ||
                      //     packages[i]['statusCode'] == 3 &&
                      //         isConsumer == false)
                      {
                        bottomSheetView(
                            context, _width, _height, packages[i]['imageUrl']);
                      }
                    },
                    child: packagesBox(
                        width: _width,
                        height: _height,
                        getUserData: getUserData,
                        isProfileImage: true,
                        isConsumer: isConsumer,
                        index: i,
                        // height:
                        //     MediaQuery.of(context).size.height * 0.2,
                        uid: packages[i]['uid'],
                        name: packages[i]['displayName'],
                        postType: 'Astrologist',
                        time: packages[i]['time'],
                        date: packages[i]['date'],
                        status: packages[i]['status'],
                        statusCode: packages[i]['statusCode'],
                        imageUrl: packages[i]['imageUrl'],
                        isPackagePayment: packages[i]['isPackagePayment'],
                        packagePurchased: packages[i]['packagePurchased'],
                        totalMsgs: packages[i]['totalMsgs'],
                        totalAppointments: packages[i]['totalAppointments'],
                        packageAmount: packages[i]['packageAmount'],
                        packageType: packages[i]['packageType'],
                        expiryDateDays: packages[i]['expiryDateDays'],
                        expiryDate: packages[i]['expiryDate'],
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

  showTabs() {
    return DefaultTabController(
        initialIndex: 0,
        length: 4,
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
                        tabs: const <Widget>[
                          Tab(
                            child: Text("Pending",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                )),
                          ),
                          Tab(
                            child: Text("Payment Verification",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.0,
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
                          Tab(
                            child: Text("Rejected",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                )),
                          ),
                        ],
                      ),
                      elevation: 0.0,
                      title: Text("Packages",
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.black,
                          )),
                      leading: BackButton(
                        color: Colors.black,
                        onPressed: () async {
                          Get.toNamed('/home');
                          // if (isConsumer == false) {
                          //   Get.toNamed('/home');
                          // } else {
                          //   setState(() {
                          //     checkStatus = false;

                          //   });
                          // }
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
                        : pendingPackages.isEmpty
                            ? noMsgText('No pending Packages.')
                            : showPackages(pendingPackages),
                    // verified  content tab
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : verifiedPackages.isEmpty
                            ? noMsgText('No verified Packages.')
                            : showPackages(verifiedPackages),
                    // Approved  content tab
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : apporvedPackages.isEmpty
                            ? noMsgText('No approved Packages.')
                            : showPackages(apporvedPackages),
                    // Rejected  content tab
                    isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appPrimaryColor,
                            ),
                          )
                        : rejectedPackages.isEmpty
                            ? noMsgText('No rejected Packages.')
                            : showPackages(rejectedPackages),
                  ]),
                ),
              ),
              MediaPlayer()
            ],
          ),
        )));
  }

  isCheckStatus(bool value) {
    setState(() {
      checkStatus = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return isConsumer == false
        ? showTabs()
        : checkStatus == true && isConsumer == true
            ? showTabs()
            : Scaffold(
                backgroundColor: appPrimaryColor,
                key: scaffoldKey,
                drawer: drawer(context, isPackagePurchased, isConsumer),
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: appbarCustom(
                            globalKey: scaffoldKey,
                            isShadow: false,
                            labelText: "Subscription Plans",
                            bgColor: appPrimaryColor,
                            textColor: whiteTextColor)
                        .paddingOnly(top: 25.0)),
                body: packagesData.isEmpty == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: whiteColor,
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          return PageView.builder(
                            itemCount: packagesData.length,
                            onPageChanged: (value) {
                              setState(() {
                                pageNumber = value;
                              });
                            },
                            controller: controller,
                            itemBuilder: (BuildContext context, int index) {
                              return subcriptionPlanCard(
                                  isPhoneLogin: isPhoneLogin,
                                  user: currentUser,
                                  screenData: screenData,
                                  height: _height * 0.7,
                                  width: _width * 0.8,
                                  packageType: packagesData[index]
                                      ['packageType'],
                                  packageAmount: packagesData[index]
                                      ['packageAmount'],
                                  packageTotalAppointments: packagesData[index]
                                      ['totalAppointments'],
                                  packageTotalMsgs: packagesData[index]
                                      ['totalMsgs'],
                                  services: packagesData[index]['services'],
                                  imageURL: "assets/images/sub$index.png",
                                  expiryDateDays: packagesData[index]
                                      ['expiryDateDays'],
                                  packagePurchased:
                                      getCurrentUserDetailsResponse[
                                          'packageDetails']['packagePurchased'],
                                  packagePayment: getCurrentUserDetailsResponse[
                                      'packageDetails']['isPackagePayment'],
                                  packageExpiryDate:
                                      getCurrentUserDetailsResponse[
                                              'packageDetails']['expiryDate'] ??
                                          '',
                                  alertTitle: 'Already Subscribed!',
                                  alertMsg: 'You can renew after ',
                                  isNavigation: false,
                                  context: context,
                                  alertBtnText: 'Okay',
                                  isCheckStatus: isCheckStatus);
                            },
                          );
                        },
                      ),
              );
  }
}

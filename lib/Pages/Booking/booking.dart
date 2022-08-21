// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meditation/Pages/Booking/bookingServices.dart';
import 'package:meditation/Pages/Notification/notificationsServices.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/appColors.dart';
import '../../Utils/authUtils.dart';
import '../../Utils/bottomBar.dart';
import '../../Utils/photoItem.dart';
import '../../main.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../Authentication/authenticationServices.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode btnFocus = FocusNode();

  var error_msg = "";
  var billingRate = "";
  var milesDistance = "";
  var estimatedTime = "";
  var pickupStart = "";
  var pickupStartDate = "";
  var pickupDestination = "";
  var pickupDestinationDate = "";
  var status = "";
  PhotoItem? profileItem;
  late Image profileImage = Image.network('');

  final storage = GetStorage();
  dynamic argumentData = Get.arguments;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  // booking field
  bool isPhoneLogin = false;
  bool isBtnSelected = false;
  int slotNumber = 0;
  String selectedSlot = "";
  String selectedSlotTime = "";
  String selectedDate = '';
  dynamic allTimeSlots;
  dynamic allTimeSlotsTemp;
  int selectedDay = 0;
  final DateRangePickerController dateController = DateRangePickerController();
  final ScrollController _controller = ScrollController();
  TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);
  int slotCounter = 1;

  // Firebase
  FirebaseAuth auth = FirebaseAuth.instance;
  User? googleUserDetails;
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isPackagePurchased = false;
  bool isConsumer = true;
  dynamic getCurrentUserDetailsResponse;
  dynamic totalAppointments;

  // get current date with format
  final currentDate = DateTime.now();
  String dateTimeFormat = '';
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat timeFormatter = DateFormat('yyyy-MM-dd hh:mm');
  DateTime getDateTime = DateTime.now();

  List<TextEditingController> controllersListLeft = [];
  List<TextEditingController> controllersListRight = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isConsumer = AuthUtils.getIsConsumer();
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isPhoneLogin = AuthUtils.getIsPhoneLogin() ?? false;
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser!);
    if (getCurrentUserDetailsResponse['packageDetails']['packagePurchased'] !=
            null ||
        getCurrentUserDetailsResponse['appointments'] != null) {
      setState(() {
        totalAppointments = getCurrentUserDetailsResponse['packageDetails']
            ['totalAppointments'];
      });
    }
    await getAllTimeSlotData();
    setState(() {
      googleUserDetails = auth.currentUser;
    });
    logger.d("Current booking day: " + DateTime.now().day.toString());
  }

  Future<void> getAllTimeSlotData({bool isDelete = false}) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('timeslot');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    allTimeSlots = querySnapshot.docs.map((doc) => doc.data()).toList();

    // sort time slots
    await sortTimeslots();

    setState(() {
      selectedDate = dateFormatter.format(currentDate);
      if (isDelete == false) {
        selectedDay = DateTime.now().day - 1;
      }
      selectedSlot = 'timeSlot0';
      if (allTimeSlots[selectedDay]['timeSlots'].length != 0) {
        selectedSlotTime = allTimeSlots[selectedDay]['timeSlots'][0]
            .toString()
            .split("/")
            .last;
      }
    });
    // initialize text controllers (only for non consumer)
    if (isConsumer == false && isDelete == false) {
      for (var i = 0; i < allTimeSlots[selectedDay]['timeSlots'].length; i++) {
        controllersListLeft.addAll([TextEditingController()]);
        controllersListRight.addAll([TextEditingController()]);
      }
    }
    logger.d('getAllTimeSlotData');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> _onSelectionChanged(
      DateRangePickerSelectionChangedArgs args) async {
    // ignore: todo
    // TODO: implement your code here
    setState(() {
      selectedDay = args.value.day - 1;
    });
    setState(() {
      if (allTimeSlots[selectedDay]['timeSlots'].length != 0) {
        selectedDate = args.value.toString().split(' ')[0];
        selectedSlot = 'timeSlot0';
        selectedSlotTime = allTimeSlots[selectedDay]['timeSlots'][0];
      }
    });

    logger.d("current date selected: " + args.value.toString());
    // update list UI
    if (isConsumer == false) {
      controllersListLeft.removeRange(0, controllersListLeft.length);
      controllersListRight.removeRange(0, controllersListRight.length);
      for (var i = 0; i < allTimeSlots[selectedDay]['timeSlots'].length; i++) {
        controllersListLeft.addAll([TextEditingController()]);
        controllersListRight.addAll([TextEditingController()]);
      }
    }
  }

  Future<void> sortTimeslots() async {
    for (var i = 0; i < allTimeSlots.length; i++) {
      if (allTimeSlots[i]['timeSlots'].length != 0) {
        List tempSortedList = allTimeSlots[i]['timeSlots'];
        tempSortedList.sort((a, b) {
          return a.compareTo(b);
        });
      }
    }
  }

  Future<void> sortTimeslotsForAddingSlots() async {
    for (var i = 0; i < allTimeSlots.length; i++) {
      if (allTimeSlots[i]['timeSlots'].length != 0) {
        List tempSortedList = allTimeSlots[i]['timeSlots'];
        tempSortedList.sort((a, b) {
          return a.compareTo(b);
        });
      }
    }
  }

  Widget addTimeSlotsUI() {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.cyan, //color you want at header
        buttonTheme: ButtonTheme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            secondary: Colors
                .cyan, // Color you want for action buttons (CANCEL and OK)
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          allTimeSlots[selectedDay]['timeSlots'].length == 0
              ? noMsgText('No slots.')
              : Theme(
                  data: ThemeData(
                    primarySwatch: Colors.blue,
                    timePickerTheme: TimePickerThemeData(
                      dayPeriodTextColor: appPrimaryColor,
                      dayPeriodColor: lightBlue, //Background of AM/PM.
                      dialHandColor: appPrimaryColor,
                      dialTextColor: appPrimaryColor,
                      hourMinuteTextColor: appPrimaryColor,
                      hourMinuteColor: lightBlue,
                    ),
                  ),
                  child: Builder(builder: (BuildContext context) {
                    final _width = MediaQuery.of(context).size.width;
                    final _height = MediaQuery.of(context).size.height;
                    return ListView.separated(
                      controller: _controller,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          allTimeSlots[selectedDay]['timeSlots'].length != 0
                              ? allTimeSlots[selectedDay]['timeSlots'].length
                              : 0,
                      itemBuilder: (context, i) {
                        slotCounter = i + 1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                headingText(
                                    title: 'Slot $slotCounter',
                                    size: 14.0,
                                    color: lightGrey),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // leftSide Buttons
                                Container(
                                  width: _width * 0.3,
                                  child: TextFormField(
                                      enabled: true,
                                      controller: controllersListLeft.isNotEmpty
                                          ? controllersListLeft[i]
                                          : null,
                                      // focusNode: lastNameFocus,
                                      // validator: (value) =>
                                      //     value!.isEmpty ? "error" : null,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onTap: () async {
                                        final TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          helpText: "",
                                          initialTime:
                                              TimeOfDay(hour: 1, minute: 00),
                                          initialEntryMode:
                                              TimePickerEntryMode.dial,
                                          errorInvalidText: 'Invalid time',
                                        );
                                        if (newTime != null) {
                                          setState(() {
                                            _time = newTime;
                                            getDateTime = DateTime(
                                                currentDate.year,
                                                currentDate.month,
                                                currentDate.day,
                                                _time.hour,
                                                _time.minute);
                                            dateTimeFormat = timeFormatter
                                                .format(getDateTime);
                                            controllersListLeft[i].text =
                                                dateTimeFormat.split(' ')[1] +
                                                    ' ' +
                                                    _time.period.name
                                                        .toUpperCase();
                                            // allTimeSlots[selectedDay]['timeSlots']
                                            //         [i] =
                                            //     _time.hour.toString() +
                                            //         ':' +
                                            //         _time.minute.toString() +
                                            //         ' ' +
                                            //         _time.period.name.toUpperCase() +
                                            //         ' to ';
                                            // logger.d(allTimeSlots[selectedDay]
                                            //     ['timeSlots'][i]);
                                          });
                                        }
                                      },
                                      onChanged: (value) async {},
                                      showCursor: true,
                                      readOnly: true,
                                      obscureText: false,
                                      decoration: CustomInputDecoration(
                                        errorTextSize: 14.0,
                                        inputBorder: InputBorder.none,
                                        filled: true,
                                        hintStyle: TextStyle(
                                            color: errorColor,
                                            fontStyle: FontStyle.italic),
                                        hint: allTimeSlots[selectedDay]
                                                    ['timeSlots'][i]
                                                .toString()
                                                .isNotEmpty
                                            ? allTimeSlots[selectedDay]
                                                    ['timeSlots'][i]
                                                .toString()
                                                .split('to')[0]
                                            : 'Enter Time',
                                      )),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                paragraphText(
                                    title: "to", size: 20.0, color: lightGrey),
                                SizedBox(
                                  width: 10,
                                ),
                                // rightSide buttons
                                Container(
                                  width: _width * 0.3,
                                  child: TextFormField(
                                      enabled: true,
                                      controller:
                                          controllersListRight.isNotEmpty
                                              ? controllersListRight[i]
                                              : null,
                                      // focusNode: lastNameFocus,
                                      // validator: (value) => value!.isEmpty
                                      //     ? "Time can not be empty"
                                      //     : null,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onTap: () async {
                                        final TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          helpText: "",
                                          initialTime:
                                              TimeOfDay(hour: 1, minute: 00),
                                          initialEntryMode:
                                              TimePickerEntryMode.dial,
                                        );
                                        if (newTime != null) {
                                          setState(() {
                                            _time = newTime;
                                            getDateTime = DateTime(
                                                currentDate.year,
                                                currentDate.month,
                                                currentDate.day,
                                                _time.hour,
                                                _time.minute);
                                            dateTimeFormat = timeFormatter
                                                .format(getDateTime);
                                            controllersListRight[i].text =
                                                dateTimeFormat.split(' ')[1] +
                                                    ' ' +
                                                    _time.period.name
                                                        .toUpperCase();
                                            // add time to that selected slot
                                            // allTimeSlots[selectedDay]['timeSlots']
                                            //         [i] =
                                            //     controllersListLeft[i].text +
                                            //         ' to ' +
                                            //         _time.hour.toString() +
                                            //         ':' +
                                            //         _time.minute.toString() +
                                            //         ' ' +
                                            //         _time.period.name.toUpperCase();
                                            // logger.d(controllersListLeft[i].text +
                                            //     ' to ' +
                                            //     _time.hour.toString() +
                                            //     ':' +
                                            //     _time.minute.toString() +
                                            //     ' ' +
                                            //     _time.period.name.toUpperCase());
                                          });
                                        }
                                      },
                                      onChanged: (value) async {},
                                      showCursor: true,
                                      readOnly: true,
                                      onFieldSubmitted: (term) {
                                        // _fieldFocusChange(
                                        //     context, lastNameFocus, nickNameFocus);
                                      },
                                      obscureText: false,
                                      decoration: CustomInputDecoration(
                                        errorTextSize: 14.0,
                                        inputBorder: InputBorder.none,
                                        filled: true,
                                        hintStyle: TextStyle(
                                            color: errorColor,
                                            fontStyle: FontStyle.italic),
                                        hint: allTimeSlots[selectedDay]
                                                    ['timeSlots'][i]
                                                .toString()
                                                .isNotEmpty
                                            ? allTimeSlots[selectedDay]
                                                    ['timeSlots'][i]
                                                .toString()
                                                .split('to')[1]
                                            : 'Enter Time',
                                      )),
                                ),
                                IconButton(
                                  color: errorColor,
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () async {
                                    if (allTimeSlots[selectedDay]['timeSlots']
                                            [i] !=
                                        '') {
                                      await BookingServices
                                          .deleteSelectedTimeSlot(
                                              selectedDay + 1,
                                              allTimeSlots[selectedDay]
                                                      ['timeSlots'][i]
                                                  .toString());
                                      controllersListRight.removeAt(i);
                                      controllersListLeft.removeAt(i);
                                      logger.d('slot removed');
                                      await getAllTimeSlotData(isDelete: true);
                                    } else {
                                      controllersListLeft.removeAt(i);
                                      controllersListRight.removeAt(i);
                                      // update list ui
                                      setState(() {
                                        allTimeSlots[selectedDay]['timeSlots']
                                            .removeAt(i);
                                      });
                                      logger.d('empty slot $i removed');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                    );
                  }),
                ),
          SizedBox(height: 20),
          error_msg != ''
              ? paragraphText(title: error_msg, size: 16, color: errorColor)
              : Container(),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              allTimeSlots[selectedDay]['timeSlots'].length == 0
                  ? Container()
                  : ElevatedButton(
                      style: elevatedButtonSecondStyle,
                      child: Text(
                        'Update',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: whiteTextColor,
                            fontSize: 20.0),
                      ),
                      onPressed: () async {
                        for (var i = 0;
                            i < allTimeSlots[selectedDay]['timeSlots'].length;
                            i++) {
                          if (controllersListLeft[i].text.isEmpty ||
                              controllersListRight[i].text.isEmpty) {
                            setState(() {
                              error_msg = 'Please fill all time slots';
                            });
                          } else {
                            await BookingServices.deleteSelectedTimeSlot(
                                selectedDay + 1,
                                allTimeSlots[selectedDay]['timeSlots'][i]
                                    .toString());
                            await BookingServices.addTimeSlots(
                                selectedDay + 1,
                                controllersListLeft[i].text +
                                    ' to ' +
                                    controllersListRight[i].text);
                          }
                        }
                        if (error_msg == '') {
                          onAlert(
                            context,
                            'Alert',
                            'Slots are updated.',
                            AlertType.success,
                            isNavigation: false,
                            btnText: 'Okay',
                          );
                        }
                      },
                    ),
              allTimeSlots[selectedDay]['timeSlots'].length == 0
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              ElevatedButton(
                style: elevatedButtonSecondStyle,
                child: Text(
                  'Add Slot',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteTextColor,
                      fontSize: 20.0),
                ),
                onPressed: () async {
                  // add text controller in list
                  controllersListLeft.add(TextEditingController());
                  controllersListRight.add(TextEditingController());

                  // update list ui
                  setState(() {
                    allTimeSlots[selectedDay]['timeSlots'].add('');
                  });
                  logger.d('slot added');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectTimeSlotUI() {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Column(children: [
      const SizedBox(
        height: 20,
      ),
      allTimeSlots[selectedDay]['timeSlots'].length == 0
          ? Container()
          : paragraphText(
              title: "Available Time for selected day",
              size: 14.0,
              color: lightGrey),
      const SizedBox(
        height: 20,
      ),
      allTimeSlots[selectedDay]['timeSlots'].length == 0 ||
              allTimeSlots[selectedDay]['timeSlots'].length == null
          ? noMsgText('All timings are booked for this date.')
          : ListView.separated(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: allTimeSlots[selectedDay]['timeSlots'].length != 0
                  ? allTimeSlots[selectedDay]['timeSlots'].length
                  : 0,
              itemBuilder: (context, i) {
                return Container(
                  height: _height * 0.070,
                  width: _width,
                  child: ElevatedButton(
                    style: elevatedButtonSecondOutlineStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          allTimeSlots[selectedDay]['timeSlots'][i].toString(),
                          // textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appSecondaryColor,
                              fontSize: 20.0),
                        ),
                        slotNumber == i
                            ? Icon(
                                Icons.timelapse,
                                color: appSecondaryColor,
                                size: 32.0,
                              )
                            : Container(),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        selectedSlot = 'timeSlot$i';
                        selectedSlotTime =
                            allTimeSlots[selectedDay]['timeSlots'][i];
                        slotNumber = i;
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 10,
                );
              },
            ),
      const SizedBox(
        height: 20,
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
                'Next',
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
            if (allTimeSlots[selectedDay]['timeSlots'].length != 0) {
              if (totalAppointments != 0) {
                setState(() {
                  totalAppointments -= 1;
                });
                await BookingServices.deleteSelectedTimeSlot(
                    selectedDay + 1, selectedSlotTime);
                // await Authentication.updatePackageCounter(
                //     false, totalAppointments, currentUser!.uid);
                await Authentication.updateUserDetails(false, 'packageDetails',
                    totalAppointments, currentUser!.uid,
                    fieldName2: 'totalAppointments');
                await Authentication.addAppointmentCollection(
                    isPhoneLogin,
                    true,
                    'verified',
                    googleUserDetails!,
                    dateController.selectedDate!.day,
                    selectedSlotTime,
                    selectedSlot,
                    selectedDate,
                    "Pending");
                // send notification to non consumer
                if (isConsumer == true) {
                  dynamic userDetails =
                      await Authentication.getUserDetailsWithId(
                          googleUserDetails!.uid);
                  await NotificationsServices.sendNotification(
                      AuthUtils.getServerKey(), AuthUtils.getAdminFcmToken(),
                      displayName: userDetails['displayName'],
                      body: userDetails['displayName'] +
                          ' ' +
                          'has booked a appointment.',
                      title: 'Appointment booked.',
                      status: 'verified',
                      type: 'appointment',
                      uid: AuthUtils.getFriendUid());
                  await NotificationsServices.addNotificationToCollection(
                      userDetails['displayName'] +
                          ' ' +
                          'has booked a appointment.',
                      'Appointment booked.',
                      dateFormatter.format(currentDate),
                      dateTimeFormat,
                      isPhoneLogin == true
                          ? AuthUtils.getDisplayName()
                          : googleUserDetails!.displayName,
                      googleUserDetails!.uid,
                      'verified',
                      'appointment');
                }

                onAlert(
                    context, 'Alert', 'Pending Verification', AlertType.success,
                    isNavigation: true, btnText: 'Okay', screenName: '/home');
              } else {
                onAlert(
                  context,
                  'Alert',
                  'You have reached your weekly appointment limit.',
                  AlertType.warning,
                  isNavigation: false,
                  btnText: 'Okay',
                );
              }
            } else {
              onAlert(
                  context, 'Alert', 'Please select the day.', AlertType.warning,
                  isNavigation: false,
                  // screenName: '/home',
                  btnText: 'Okay',
                  argData: screenData);
            }
          },
        ),
      ),
      const SizedBox(
        height: 20,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return allTimeSlots == null
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: appPrimaryColor,
              ),
            ),
          )
        : Scaffold(
            drawer: drawer(context, isPackagePurchased, isConsumer),
            key: scaffoldKey,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: appbarCustom(
                        globalKey: scaffoldKey,
                        textColor: blackTextColor,
                        isShadow: false,
                        labelText: "Booking",
                        bgColor: lightBlue)
                    .paddingOnly(top: 25.0)),
            backgroundColor: Colors.white,
            // bottomNavigationBar: BottomBarScreen(),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SfDateRangePicker(
                        navigationMode: DateRangePickerNavigationMode.none,
                        initialSelectedDate: DateTime.now(),
                        selectionColor: lightBlue,
                        allowViewNavigation: false,
                        // showTodayButton: true,
                        onSelectionChanged: _onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.single,
                        controller: dateController,
                        minDate: isConsumer == false
                            ? null
                            : DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                0,
                                0,
                                0),
                      ),
                    ),
                    isConsumer == false
                        ? headingText(
                            title: "Add Time Slots",
                            size: 28.0,
                            color: appSecondaryColor)
                        : headingText(
                            title: "Booking",
                            size: 28.0,
                            color: appSecondaryColor),
                    isConsumer == false ? addTimeSlotsUI() : selectTimeSlotUI(),
                  ],
                ).paddingOnly(left: 20, right: 20),
              ),
            ));
  }
}

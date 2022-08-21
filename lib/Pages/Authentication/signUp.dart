// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../main.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'authenticationServices.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  String error = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode phoneBtnFocus = FocusNode();
  FocusNode btnFocus = FocusNode();

  late Map<String, dynamic> loginData = <String, dynamic>{};

  final storage = GetStorage();

  // validate email regex
  bool emailValidRegExp = false;
  String emailValidateMsg = "";

  bool isLoading = false;
  TextEditingController pinCodeController = new TextEditingController();
  late String _verificationCode;

  FocusNode pinCodeFocus = FocusNode();

  String checkVersion = "";
  final btnKey = GlobalKey();
  String timer = "";
  var loginResponse;
  String _code = "";
  String? appSignature;

  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  int _start = 120;
  bool isResend = false;
  bool isVerify = false;
  bool isEmailAuth = false;
  var data;

  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;
  bool isChecked = false;

  // location fields
  String locationAddress = '';

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
    super.initState();
    data = Get.arguments;
    init();
  }

  init() async {
    emailValidRegExp = true;
    // FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   if (user == null) {
    //     logger.d('User is currently signed out!');
    //     Get.offNamed("/login");
    //   } else {
    //     logger.d('User is signed in!' + user.uid);
    //   }
    // });
    // await SmsAutoFill().listenForCode;
    SmsAutoFill().listenForCode;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await getAddressFromLatLong(position);
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      locationAddress = '${place.locality} ${place.country}';
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 3);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            isResend = true;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _timer.cancel();
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
    return Scaffold(
        // appBar: PreferredSize(
        //     preferredSize: const Size.fromHeight(50),
        //     child: appbarCustom(
        //         isShadow: false, labelText: "OTP", navigateLogin: true)),
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              Icon(
                Icons.pin_drop_outlined,
                size: 32.0,
              ),
              paragraphText(
                  title: locationAddress, size: 14.0, color: lightGrey),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          headingText(title: "Getting Started", size: 22.0),
          SizedBox(
            height: 20,
          ),
          paragraphText(
              title: "Create an account to continue!",
              size: 14.0,
              color: lightGrey),
          SizedBox(
            height: 60,
          ),
          // social buttons
          Column(
            children: <Widget>[
              Container(
                height: _height * 0.070,
                width: _width,
                child: ElevatedButton.icon(
                  style: elevatedButtonStyleFB,
                  icon: Icon(
                    Icons.facebook,
                    color: whiteColor,
                    size: 32.0,
                  ),
                  label: isLoading == true
                      ? CircularProgressIndicator(
                          color: whiteColor,
                        )
                      : Text(
                          'Continue with Facebook',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: whiteTextColor,
                              fontSize: 20.0),
                        ),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: _height * 0.070,
                width: _width,
                child: ElevatedButton(
                  style: elevatedButtonStyle,
                  child: isLoading == true
                      ? CircularProgressIndicator(
                          color: whiteColor,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/googleIcon.png",
                              isAntiAlias: true,
                              scale: 1.7,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blackTextColor,
                                  fontSize: 20.0),
                            ),
                          ],
                        ),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: _height * 0.070,
                width: _width,
                child: ElevatedButton(
                  style: elevatedButtonStyle,
                  child: isLoading == true
                      ? CircularProgressIndicator(
                          color: whiteColor,
                        )
                      : Text(
                          'Continue with Phone',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: blackTextColor,
                              fontSize: 20.0),
                        ),
                  onPressed: () {
                    Get.toNamed("/loginWithPhone");
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(blackAppBarColor),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: 'By creating an account, you agree to our ',
                        style: TextStyle(fontSize: 14, color: blackTextColor),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Term & Conditions',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: blackTextColor,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Get.toNamed("/signUp")),
                        ],
                      ),
                    ),
                  )
                ],
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
                        'SIGN UP',
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
                    Get.toNamed("/loginPhone");
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              error.trim() != ""
                  ? Column(children: [
                      Text(error,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ])
                  : Container(),
            ],
          ),
          SizedBox(
            height: _height * 0.05,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(fontSize: 14, color: lightGrey),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                          fontSize: 14,
                          color: lightGrey,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.toNamed("/login")),
                ],
              ),
            ),
          ),
        ],
      ).paddingOnly(left: 20, right: 20),
    ));
  }
}

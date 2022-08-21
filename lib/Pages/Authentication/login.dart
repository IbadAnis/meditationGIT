// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import 'package:meditation/Utils/authUtils.dart';
import '../../main.dart';
import 'authenticationServices.dart';
import 'package:geocoding/geocoding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  String error = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pinCodeController = new TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode phoneBtnFocus = FocusNode();
  FocusNode btnFocus = FocusNode();
  FocusNode pinCodeFocus = FocusNode();

  late Map<String, dynamic> loginData = <String, dynamic>{};

  final storage = GetStorage();

  // validate email regex
  bool emailValidRegExp = false;
  String emailValidateMsg = "";

  bool isLoading = false;

  late String _verificationCode;

  String timer = "";
  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  int _start = 120;
  bool isResend = false;
  bool isVerify = false;
  bool isEmailAuth = false;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  //login info
  bool _checking = true;
  // Firebase
  FirebaseAuth auth = FirebaseAuth.instance;
  User? googleUserDetails;
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;

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
    init();
  }

  init() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await getAddressFromLatLong(position);
    emailValidRegExp = true;

    await Authentication.facebookLoginCheck();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        logger.d('User is currently signed out!');
        Get.offNamed("/login");
      } else {
        logger.d('User is signed in!' + user.uid);
        if (AuthUtils.getLoggedIn() == true ||
            AuthUtils.getLoggedIn() != null) {
          Get.offNamed("/home");
        }
      }
    });
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
          headingText(title: "Let’s Sign You In", size: 22.0),
          SizedBox(
            height: 20,
          ),
          paragraphText(
              title: "Welcome back, you’ve been missed!",
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
                  onPressed: () {
                    Authentication.signInWithFacebook();
                  },
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
                  onPressed: () async {
                    await Authentication.signInWithGoogle(context: context);
                  },
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
            height: _height * 0.2,
          ),
        ],
      ).paddingOnly(left: 20, right: 20),
    ));
  }
}

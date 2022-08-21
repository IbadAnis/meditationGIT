// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, sized_box_for_whitespace, unnecessary_brace_in_string_interps

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../main.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'authenticationServices.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginWithPhoneScreen extends StatefulWidget {
  const LoginWithPhoneScreen({Key? key}) : super(key: key);

  @override
  LoginWithPhoneScreenState createState() => LoginWithPhoneScreenState();
}

class LoginWithPhoneScreenState extends State<LoginWithPhoneScreen> {
  String error = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pinCodeController = new TextEditingController();

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
  late String _verificationCode;

  FocusNode pinCodeFocus = FocusNode();

  String checkVersion = "";
  final btnKey = GlobalKey();
  String timer = "";
  String _code = "";
  String? appSignature;

  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  int _start = 60;
  bool isResend = false;
  bool isPhoneNoShow = true;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  // location fields
  String locationAddress = '';

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  String initialCountry = 'PK';
  PhoneNumber number = PhoneNumber(isoCode: 'PK');
  String countryCode = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
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

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCode,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              // Get.offNamed('home');
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) async {
          logger.d(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
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
          // Phone Section
          isPhoneNoShow == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    headingText(title: "Enter Phone Number", size: 22.0),
                    SizedBox(
                      height: 80,
                    ),
                    // Phone Number textfield
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InternationalPhoneNumberInput(
                      isEnabled: isPhoneNoShow == true ? true : false,
                      focusNode: phoneBtnFocus,
                      validator: (value) => value!.isEmpty
                          ? "Phone number cannot be empty"
                          : null,
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          countryCode = number.phoneNumber!;
                        });
                        logger.d(countryCode);
                      },
                      onInputValidated: (bool value) {
                        logger.d(value);
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: number,
                      textFieldController: phoneController,
                      formatInput: false,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, passwordFocus, btnFocus);
                      },
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      // inputBorder: OutlineInputBorder(),
                      inputDecoration: CustomPhoneInputDecoration(
                        errorTextSize: 14.0,
                        inputBorder: InputBorder.none,
                        filled: true,
                        hint: 'Enter Phone Number',
                      ),
                      onSaved: (PhoneNumber number) {
                        logger.d('On Saved: $number');
                      },
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Container(
                      height: _height * 0.070,
                      width: _width,
                      child: ElevatedButton(
                        style: elevatedButtonSecondStyle,
                        onPressed: () async {
                          // Get.toNamed("/signUpForm");
                          if (phoneController.text.isNotEmpty) {
                            setState(() {
                              isPhoneNoShow = false;
                            });
                            startTimer();
                            _verifyPhone();
                          } else {
                            setState(() {
                              error = "Phone number cannot be empty.";
                            });
                          }
                        },
                        child: isLoading == true
                            ? CircularProgressIndicator(
                                color: whiteColor,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'CONTINUE',
                                    // textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: whiteTextColor,
                                        fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    width: _width * 0.2,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_outlined,
                                    color: whiteColor,
                                    size: 32.0,
                                  ),
                                ],
                              ),
                      ),
                    )
                  ],
                )

              // PINCODE Section
              : Column(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        headingText(title: "OTP Authentication", size: 22.0),
                        SizedBox(
                          height: 20,
                        ),
                        paragraphText(
                            title: "An authentication code has been sent to " +
                                phoneController.text,
                            size: 14.0,
                            color: lightGrey),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // pincode field
                    Container(
                      width: _width,
                      child: PinFieldAutoFill(
                        controller: pinCodeController,
                        codeLength: 6,
                        decoration: UnderlineDecoration(
                          textStyle: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          colorBuilder:
                              FixedColorBuilder(Colors.black.withOpacity(0.3)),
                        ),
                        currentCode: _code,
                        onCodeSubmitted: (code) async {},
                        onCodeChanged: (code) async {
                          // pinCodeController.text = code!;
                          _code = code!;
                          if (code.length == 6) {
                            _code = code;
                            try {
                              await FirebaseAuth.instance
                                  .signInWithCredential(
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationCode,
                                          smsCode: _code))
                                  .then((value) async {
                                if (value.user != null) {
                                  if (value.additionalUserInfo!.isNewUser ==
                                      true) {
                                    screenData['phoneController'] =
                                        phoneController.text;
                                    // save firebase token if it doesn't exist
                                    await Authentication.saveFCMToken();
                                    await Authentication.addUser(value.user!,
                                        isPhoneLogin: true);
                                    Get.offNamed('/signUpForm',
                                        arguments: screenData);
                                  } else {
                                    Get.offNamed('/home');
                                  }
                                }
                              });
                            } catch (e) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                error = "Invalid OTP.";
                                isPhoneNoShow = true;
                                _start = 60;
                                _timer.cancel();
                                pinCodeController.text = '';
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text("$_start",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: lightGrey,
                              fontSize: 20.0)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    isResend == true
                        ? paragraphText(
                            title: "Didn’t receive any code? Resend",
                            size: 16.0,
                          )
                        : Container(),
                    SizedBox(
                      height: 30,
                    ),
                    isResend == true
                        ? Container(
                            height: _height * 0.070,
                            width: _width,
                            child: Focus(
                                focusNode: btnFocus,
                                autofocus: true,
                                child: ElevatedButton(
                                  style: elevatedButtonSecondStyle,
                                  onPressed: () async {
                                    setState(() {
                                      _code = "";
                                      pinCodeController.text = "";
                                    });
                                    SmsAutoFill().listenForCode;
                                    setState(() {
                                      _start = 60;
                                      startTimer();
                                      isResend = false;
                                    });
                                  },
                                  child: isLoading == true
                                      ? CircularProgressIndicator(
                                          color: whiteColor,
                                        )
                                      : Text(
                                          'Resend',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: whiteTextColor,
                                              fontSize: 20.0),
                                        ),
                                )),
                          )
                        : Container(),
                  ],
                ),
          const SizedBox(
            height: 30,
          ),
          error.trim() != ""
              ? Center(
                  child: Text(error,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                )
              : Container(),
        ],
      ).paddingOnly(left: 20, right: 20),
    ));
  }
}

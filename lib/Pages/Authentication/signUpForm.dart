// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, unused_field, prefer_final_fields, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../main.dart';
import 'authenticationServices.dart';

enum SingingCharacter { male, female }

class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({Key? key}) : super(key: key);

  @override
  SignUpFormScreenState createState() => SignUpFormScreenState();
}

class SignUpFormScreenState extends State<SignUpFormScreen> {
  String error = "";
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController pobController = TextEditingController();
  SingingCharacter? _character = SingingCharacter.male;
  String gender = 'male';

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode nickNameFocus = FocusNode();
  FocusNode dobFocus = FocusNode();
  FocusNode pobFocus = FocusNode();
  FocusNode motherFocus = FocusNode();
  FocusNode phoneBtnFocus = FocusNode();

  late Map<String, dynamic> loginData = <String, dynamic>{};
  final storage = GetStorage();

  // validate email regex
  bool emailValidRegExp = false;
  String emailValidateMsg = "";

  TextEditingController pinCodeController = new TextEditingController();
  late String _verificationCode;

  FocusNode pinCodeFocus = FocusNode();

  final btnKey = GlobalKey();

  bool isResend = false;
  bool isVerify = false;
  bool isEmailAuth = false;
  bool isLoading = false;
  bool isDatePicker = false;
  var data;

  bool isPhoneNoShow = true;
  String initialCountry = 'PK';
  PhoneNumber number = PhoneNumber(isoCode: 'PK');

  final DateRangePickerController dateController = DateRangePickerController();

  // location fields
  String locationAddress = '';

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // Firebase
  final currentUser = FirebaseAuth.instance.currentUser!;
  dynamic getCurrentUserDetailsResponse;
  bool isPhoneLogin = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    await storage.write('loggedIn', true);

    data = Get.arguments;
    if (data != null) {
      phoneController.text = data['phoneController'];
    }

    emailValidRegExp = true;
    getCurrentUserDetailsResponse =
        await Authentication.getCurrentUserDetails(currentUser);
    if (getCurrentUserDetailsResponse != null) {
      isPhoneLogin = getCurrentUserDetailsResponse['isPhoneLogin'];
    }
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      dobController.text = args.value.toString().split(' ').first;
    });
    logger.d("date of birth selected: " + dobController.text.toString());
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                direction: Axis.vertical,
                children: [
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
                    height: 20,
                  ),
                  headingText(title: "Getting Started", size: 22.0),
                  SizedBox(
                    height: 20,
                  ),
                  paragraphText(
                      title: "Create an account to continue!",
                      size: 14.0,
                      color: lightGrey),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 20.0,
                spacing: 4.0,
                children: [
                  Container(
                      // height: _height * 0.070,
                      width: _width * 0.43,
                      child: TextFormField(
                          enabled: true,
                          controller: nameController,
                          focusNode: nameFocus,
                          validator: (value) => value!.isEmpty
                              ? "First Name can not be empty"
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, nameFocus, lastNameFocus);
                          },
                          obscureText: false,
                          decoration: CustomInputDecoration(
                            errorTextSize: 14.0,
                            inputBorder: InputBorder.none,
                            filled: true,
                            hint: 'First Name',
                          ))),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      // height: _height * 0.070,
                      width: _width * 0.43,
                      child: TextFormField(
                          enabled: true,
                          controller: lastNameController,
                          focusNode: lastNameFocus,
                          validator: (value) => value!.isEmpty
                              ? "Last Name can not be empty"
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, lastNameFocus, nickNameFocus);
                          },
                          obscureText: false,
                          decoration: CustomInputDecoration(
                            errorTextSize: 14.0,
                            inputBorder: InputBorder.none,
                            filled: true,
                            hint: 'Last Name',
                          ))),
                ],
              ),
              isPhoneLogin == true
                  ? SizedBox(
                      height: 20,
                    )
                  : Container(),
              isPhoneLogin == true
                  ? Container(
                      // height: _height * 0.070,
                      width: _width,
                      child: TextFormField(
                          controller: emailController,
                          focusNode: emailFocus,
                          validator: (value) {
                            if (value!.isEmpty) {
                              emailValidateMsg = 'Email cannot be blank';
                            }
                            if (value.isNotEmpty && emailValidRegExp == false) {
                              emailValidateMsg = "Invalid email";
                            } else {
                              emailValidateMsg = "";
                              error = "";
                            }
                            return emailValidateMsg != ""
                                ? emailValidateMsg
                                : null;
                          },
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, emailFocus, nickNameFocus);
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            value = value.replaceAll(' ', '');
                            emailValidRegExp = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              caseSensitive: false,
                            ).hasMatch(value);
                            logger.d("emailValidRegExp $emailValidRegExp");
                          },
                          keyboardType: TextInputType.text,
                          decoration: CustomInputDecoration(
                            errorTextSize: 14.0,
                            inputBorder: InputBorder.none,
                            filled: true,
                            hint: 'Enter Email',
                          )))
                  : Container(),
              SizedBox(
                height: 20,
              ),
              InternationalPhoneNumberInput(
                isEnabled: isPhoneNoShow == true ? true : false,
                focusNode: phoneBtnFocus,
                validator: (value) =>
                    value!.isEmpty ? "Phone number cannot be empty" : null,
                onInputChanged: (PhoneNumber number) {
                  logger.d(number.phoneNumber);
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
                  _fieldFocusChange(context, phoneBtnFocus, nickNameFocus);
                },
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                // inputBorder: OutlineInputBorder(),
                searchBoxDecoration: CustomInputDecoration(
                  errorTextSize: 14.0,
                  inputBorder: InputBorder.none,
                  filled: true,
                  hint: 'Search...',
                ),
                inputDecoration: CustomInputDecoration(
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
                height: 20,
              ),
              Container(
                  // height: _height * 0.070,
                  width: _width,
                  child: TextFormField(
                      enabled: isVerify == true ? false : true,
                      controller: nickNameController,
                      focusNode: nickNameFocus,
                      validator: (value) =>
                          value!.isEmpty ? "Nick Name can not be empty" : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, nickNameFocus, dobFocus);
                      },
                      obscureText: false,
                      decoration: CustomInputDecoration(
                        errorTextSize: 14.0,
                        inputBorder: InputBorder.none,
                        filled: true,
                        hint: 'Enter your Nick Name',
                      ))),
              SizedBox(
                height: 20,
              ),
              isDatePicker == true
                  ? SfDateRangePicker(
                      showActionButtons: true,
                      onSubmit: (obs) {
                        setState(() {
                          isDatePicker = false;
                        });
                      },
                      onCancel: () {
                        setState(() {
                          isDatePicker = false;
                        });
                      },
                      initialSelectedDate: DateTime.now(),
                      selectionColor: lightBlue,
                      allowViewNavigation: true,
                      onSelectionChanged: _onSelectionChanged,
                      navigationMode: DateRangePickerNavigationMode.scroll,
                      selectionMode: DateRangePickerSelectionMode.single,
                      controller: dateController,
                    )
                  : Container(
                      // height: _height * 0.070,
                      width: _width,
                      child: TextFormField(
                          onTap: () {
                            setState(() {
                              isDatePicker = true;
                            });
                          },
                          enabled: isVerify == true ? false : true,
                          controller: dobController,
                          focusNode: dobFocus,
                          validator: (value) =>
                              value!.isEmpty ? "Month can not be empty" : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(context, dobFocus, pobFocus);
                          },
                          obscureText: false,
                          decoration: CustomInputDecoration(
                            errorTextSize: 14.0,
                            inputBorder: InputBorder.none,
                            filled: true,
                            hint: 'Enter your date of birth',
                          ))),
              SizedBox(
                height: 20,
              ),
              Container(
                  // height: _height * 0.070,
                  width: _width,
                  child: TextFormField(
                      enabled: isVerify == true ? false : true,
                      keyboardType: TextInputType.text,
                      controller: pobController,
                      focusNode: pobFocus,
                      validator: (value) => value!.isEmpty
                          ? "Place of birth can't be empty."
                          : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, pobFocus, motherFocus);
                      },
                      obscureText: false,
                      decoration: CustomInputDecoration(
                        errorTextSize: 14.0,
                        inputBorder: InputBorder.none,
                        filled: true,
                        hint: 'Enter your Place of birth',
                      ))),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: _width,
                  child: TextFormField(
                      enabled: isVerify == true ? false : true,
                      controller: motherNameController,
                      focusNode: motherFocus,
                      validator: (value) =>
                          value!.isEmpty ? "Mother name can't be empty." : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (term) {
                        motherFocus.unfocus();
                      },
                      obscureText: false,
                      decoration: CustomInputDecoration(
                        errorTextSize: 14.0,
                        inputBorder: InputBorder.none,
                        filled: true,
                        hint: "Enter your Mother's name",
                      ))),
              // Password textfield
              // Column(
              //   children: <Widget>[
              //
              //     // Container(
              //     //     height: _height * 0.070,
              //     //     width: _width,
              //     //     child: TextFormField(
              //     //         enabled: isVerify == true ? false : true,
              //     //         keyboardType: TextInputType.number,
              //     //         controller: passwordController,
              //     //         focusNode: passwordFocus,
              //     //         validator: (value) => value!.isEmpty
              //     //             ? "Place of birth can not be empty"
              //     //             : null,
              //     //         autovalidateMode: AutovalidateMode.onUserInteraction,
              //     //         onFieldSubmitted: (term) {
              //     //           _fieldFocusChange(
              //     //               context, passwordFocus, passwordFocus);
              //     //         },
              //     //         obscureText: false,
              //     //         decoration: CustomPasswordInputDecoration(
              //     //           errorTextSize: 14.0,
              //     //           inputBorder: InputBorder.none,
              //     //           filled: false,
              //     //           hint: 'Place of birth',
              //     //         ))),
              //     SizedBox(
              //       height: 20,
              //     ),
              //     // Radio Buttons
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Radio<SingingCharacter>(
                    value: SingingCharacter.male,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        gender = 'male';
                      });
                    },
                  ),
                  Text(
                    'MALE',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  Spacer(),
                  Radio<SingingCharacter>(
                    value: SingingCharacter.female,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        gender = 'female';
                      });
                    },
                  ),
                  Text(
                    'FEMALE',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: _height * 0.070,
                width: _width,
                child: ElevatedButton(
                  style: elevatedButtonSecondStyle,
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        lastNameController.text.isNotEmpty &&
                        nickNameController.text.isNotEmpty &&
                        dobController.text.isNotEmpty &&
                        pobController.text.isNotEmpty &&
                        motherNameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      setState(() {
                        error = "";
                      });
                      await Authentication.addSignUpFormDetails(
                          nameController.text,
                          lastNameController.text,
                          nickNameController.text,
                          dobController.text,
                          pobController.text,
                          motherNameController.text,
                          gender,
                          phoneController.text);
                      if (isPhoneLogin == true) {
                        await Authentication.updateUser(currentUser,
                            isPhoneLogin: isPhoneLogin,
                            name: nameController.text,
                            email: emailController.text,
                            currentAppScreen: 'signUpForm',
                            isUserOnline: true);
                        Get.toNamed("/onboarding");
                      } else {
                        Get.toNamed("/onboarding");
                      }
                    } else {
                      setState(() {
                        error = "Please fill all the your details to continue.";
                      });
                    }
                  },
                  child: isLoading == true
                      ? CircularProgressIndicator(
                          color: whiteColor,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              width: _width * 0.01,
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: whiteColor,
                              size: 32.0,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(
                height: 20,
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
              // SizedBox(
              //   height: 30,
              // ),
              // Center(
              //   child: RichText(
              //     text: TextSpan(
              //       text: 'Already have an account? ',
              //       style: TextStyle(fontSize: 14, color: lightGrey),
              //       children: <TextSpan>[
              //         TextSpan(
              //             text: 'Sign in',
              //             style: TextStyle(
              //                 fontSize: 14,
              //                 color: lightGrey,
              //                 fontWeight: FontWeight.bold),
              //             recognizer: TapGestureRecognizer()
              //               ..onTap = () => Get.toNamed("/signIn")),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
            ],
          ).paddingOnly(left: 20, right: 20),
        ),
      ),
    ));
  }
}

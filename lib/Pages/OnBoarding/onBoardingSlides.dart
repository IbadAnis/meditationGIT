// ignore_for_file: file_names, unnecessary_new, prefer_const_constructors, unused_field, prefer_final_fields, sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/Widgets.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  String error = "";

  late Map<String, dynamic> loginData = <String, dynamic>{};
  final storage = GetStorage();
  String checkVersion = "";
  final btnKey = GlobalKey();
  String timer = "";
  var loginResponse;
  String _code = "";
  String? appSignature;
  bool isLoading = false;
  final PageController controller = PageController();
  int pageNumber = 0;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() {}

  @override
  void dispose() {
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
      // appBar: AppBar(title: Text('')),
      body: Builder(
        builder: (context) {
          return PageView(
            onPageChanged: (value) {
              setState(() {
                pageNumber = value;
              });
            },
            controller: controller,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PAGE 1
                  onboardingDetails(
                      width: _width,
                      labelText: "Lorem Ipsum",
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
                      services: "+Serivces",
                      imageURL: "assets/images/ob1.png"),
                  slidersDots(pageNumber: pageNumber)
                ],
              ),
              // PAGE 2
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  onboardingDetails(
                      width: _width,
                      labelText: "Lorem Ipsum",
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
                      services: "+Serivces",
                      imageURL: "assets/images/ob2.png"),
                  slidersDots(pageNumber: pageNumber)
                ],
              ),
              // PAGE 3
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  onboardingDetails(
                      width: _width,
                      labelText: "Lorem Ipsum",
                      text:
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
                      services: "+Serivces",
                      imageURL: "assets/images/ob2.png"),
                  slidersDots(pageNumber: pageNumber),
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
                            'Next',
                            // textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: whiteTextColor,
                                fontSize: 20.0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Get.toNamed("/home");
                      },
                    ),
                  ),
                ],
              ).paddingOnly(left: 20.0, right: 20.0),
            ],
          );
        },
      ),
    );
  }
}

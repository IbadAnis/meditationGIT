// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/photoItem.dart';
import 'package:meditation/Utils/viewPhotoItem.dart';
import '../Pages/Authentication/authenticationServices.dart';
import '../Pages/Chat/chatMsg.dart';
import '../Pages/Chat/user.dart';
import '../Pages/Playlist/categoriesPlaylist.dart';
import 'appColors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'HexColors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'authUtils.dart';

var alertStyle = AlertStyle(
  animationType: AnimationType.grow,
  isCloseButton: false,
  isOverlayTapDismiss: false,
);

var alertStyleRD = AlertStyle(
  animationType: AnimationType.grow,
  isCloseButton: true,
  isOverlayTapDismiss: true,
);

ButtonStyle elevatedButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(whiteColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    )));
ButtonStyle elevatedButtonStyleFB = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(fbColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    )));
ButtonStyle elevatedButtonSecondStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(appSecondaryColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32.0),
    )));
ButtonStyle elevatedButtonThirdBtnStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(thirdBtnColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32.0),
    )));
ButtonStyle elevatedButtonSecondOutlineStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(whiteColor),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: appPrimaryColor))));

InputDecoration CustomPhoneInputDecoration({
  String? labeltext,
  String? hint,
  dynamic icon,
  TextStyle? hintStyle,
  Widget? suffixIcon,
  Widget? prefixIcon,
  Color? fillColor,
  bool? filled = false,
  InputBorder? inputBorder,
  double? errorTextSize,
}) {
  return InputDecoration(
    errorStyle: TextStyle(
      fontSize: errorTextSize,
    ),
    hintStyle: hintStyle,
    // border: OutlineInputBorder(
    //     borderRadius: BorderRadius.all(Radius.circular(12.0))),
    filled: filled,
    fillColor: fillColor ?? HexColor("#F4F4F4"),
    hintText: hint,
  );
}

InputDecoration CustomInputDecoration({
  String? labeltext,
  String? hint,
  dynamic icon,
  TextStyle? hintStyle,
  Widget? suffixIcon,
  Widget? prefixIcon,
  Color? fillColor,
  bool? filled = false,
  InputBorder? inputBorder,
  double? errorTextSize,
}) {
  return InputDecoration(
    suffixIcon: suffixIcon,
    prefix: prefixIcon,
    errorStyle: TextStyle(
      fontSize: errorTextSize,
    ),
    hintStyle: hintStyle,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0))),
    filled: filled,
    fillColor: fillColor ?? HexColor("#F4F4F4"),
    hintText: hint,
  );
}

InputDecoration CustomPasswordInputDecoration({
  String? labeltext,
  String? hint,
  dynamic icon,
  TextStyle? hintStyle,
  Widget? suffixIcon,
  Widget? prefixIcon,
  Color? fillColor,
  bool? filled = true,
  InputBorder? inputBorder,
  double? errorTextSize,
}) {
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: appPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: appPrimaryColor, width: 2.0),
    ),
    suffixIcon: IconButton(
      icon: Icon(Icons.remove_red_eye_rounded),
      onPressed: () => {print('suffixIcon pressed')},
      iconSize: 32.0,
    ),
    errorStyle: TextStyle(
      fontSize: errorTextSize,
    ),
    hintStyle: hintStyle,
    prefixIcon: prefixIcon,
    border: inputBorder,
    filled: filled,
    fillColor: fillColor ?? HexColor("#F4F4F4"),
    hintText: hint,
  );
}

Widget bigBox(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    String imageURL = "",
    Icon? icon}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageURL),
          fit: BoxFit.cover,
        ),
        color: HexColor("#F4F4F4"),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // width: width! * 0.8,
            child: Center(
              child: Text(labelText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                      fontSize: 28.0)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget mediumBox(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    Color? boxColor,
    Color? textColor,
    Icon? icon}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: boxColor ?? whiteColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: width! * 0.8,
                child: Text(labelText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor == null ? whiteColor : textColor,
                        fontSize: 16.0)),
              ),
              Center(
                child: icon,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: width * 0.8,
                child: Text(text,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor == null ? whiteColor : textColor,
                        fontSize: 16.0)),
              ),
            ],
          ),
        ],
      ).paddingOnly(left: 5.0, right: 5.0),
    ),
  );
}

Widget smallBox(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    Color? boxColor,
    Color? textColor,
    Icon? icon}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: boxColor ?? whiteColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width! * 0.8,
            child: Text(labelText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor == null ? whiteColor : textColor,
                    fontSize: 16.0)),
          ),
          SizedBox(height: 10),
          Center(
            child: icon,
          )
        ],
      ),
    ),
  );
}

Widget categorybox({
  double? width,
  double? height,
  String title = "",
  dynamic backgroundImageUrl,
  bool isbackgroundImage = true,
}) {
  return Stack(
    children: [
      ClipRRect(
        child: Image.network(
          backgroundImageUrl,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                color: whiteColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      Padding(
        padding: EdgeInsets.only(top: height! * 0.2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Center(
              child: Text(title,
                  style: TextStyle(fontSize: 20, color: whiteColor))),
        ),
      ),
    ],
  );

  // Container(
  //     padding: const EdgeInsets.only(top: 180),
  //     child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.black87,
  //           borderRadius: BorderRadius.circular(0),
  //         ),
  //         child: Center(
  //             child: Text(title,
  //                 style: TextStyle(fontSize: 20, color: whiteColor)))),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10),
  //       image: DecorationImage(
  //         image: NetworkImage(backgroundImageUrl),
  //         fit: BoxFit.fill,
  //       ),
  //     ));
}

Widget smallCardButton(
    {double? width,
    double? height,
    String? imageAsset,
    Color? color,
    Icon? icon,
    bool? isPurchasedPackage}) {
  return Card(
    color: color ?? whiteColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Container(
      width: width,
      height: height,
      child: isPurchasedPackage == true
          ? Image.asset(
              imageAsset!,
              scale: 10.0,
              isAntiAlias: true,
            )
          : icon,
    ),
  );
}

Widget chatMsgBox(
    {double? width, double? height, String labelText = "", String text = ""}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: HexColor("#F4F4F4"),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(labelText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HexColor("#EE0606"),
                    fontSize: 30.0)),
          ),
          Center(
            child: Text(text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          )
        ],
      ),
    ),
  );
}

Widget tasksLoadRequestBox(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    int? index,
    Map<String, dynamic>? screenData}) {
  return InkWell(
    onTap: () {
      screenData!["index"] = index;
      Get.toNamed("/viewTasks", arguments: screenData);
    },
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: HexColor("#F4F4F4"),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(labelText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HexColor("#EE0606"),
                      fontSize: 30.0)),
            ),
            Center(
              child: Text(text,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            )
          ],
        ),
      ),
    ),
  );
}

Widget smallProfileBox(
    {double? width, double? height, String labelText = "", String text = ""}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: HexColor("#F4F4F4"),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(labelText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: HexColor("#EE0606"),
                        fontSize: 20.0)),
              ),
            ],
          ).paddingOnly(left: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width! * 0.9,
                child: Text(text,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
              )
            ],
          ).paddingOnly(left: 13)
        ],
      ),
    ),
  );
}

Widget smallProfileBoxWithIcon(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    bool? showIcon = true,
    PhotoItem? photoItem}) {
  return GestureDetector(
    onTap: () {
      Get.to(
        ViewPhotoItemScreen(image: photoItem!.image, name: ""),
      );
    },
    child: Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: HexColor("#F4F4F4"),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(labelText,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HexColor("#EE0606"),
                          fontSize: 20.0)),
                ),
                showIcon == true
                    ? photoItem!.image == ""
                        ? GestureDetector(
                            onTap: () {
                              Get.to(
                                ViewPhotoItemScreen(
                                    image: photoItem.image, name: ""),
                              );
                            },
                            child: GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.upload_file_outlined,
                                size: 32.0,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(photoItem.image),
                            // child:
                            //     Image(image: NetworkImage(photoItem.image)),
                            radius: 15,
                            backgroundColor: Colors.black,
                          )
                    : Container(),
              ],
            ).paddingOnly(left: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.0)),
                ),
              ],
            ).paddingOnly(left: 13)
          ],
        ),
      ),
    ),
  );
}

Widget card({
  double? width,
  double? height,
  String labelText = "",
  String estimatedTimeText = "",
  String text = "",
  String dollarText = "",
  String text1 = "",
  String text2 = "",
  String dateTime1 = "",
  String dateTime2 = "",
  String timeRemaining = "",
  String source = "",
  String sourceDateTime = "",
  String destination = "",
  String destinationDateTime = "",
  int? index,
  String status = "",
  int? bidStatusId,
  int? loadRequestId,
  Map<String, dynamic>? screenData,
}) {
  return InkWell(
    onTap: () {
      screenData!["getCurrentLoadIndex"] = index;
      screenData["getCurrentBidStatusId"] = bidStatusId;
      screenData["getBidstatus"] = status;
      screenData["loadRequestId"] = loadRequestId;
      Get.toNamed("/startTripWarning", arguments: screenData);
      // if (bidStatusId == 0 || bidStatusId == 1) {
      //   Get.toNamed("/startTrip", arguments: screenData);
      // } else if (bidStatusId == 2) {
      //   Get.offNamed("/uploadBOL", arguments: screenData);
      // } else if (bidStatusId == 3 || bidStatusId == 4) {
      //   Get.offNamed("/uploadPOD", arguments: screenData);
      // }
    },
    child: Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: HexColor("#F4F4F4"),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Spacer(flex: 1),
                  Container(
                    width: width! * 0.35,
                    height: height! * 0.15,
                    child: Container(
                      child: Center(
                        child: Text(status,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: whiteColor)),
                      ),
                      decoration: BoxDecoration(
                          color: appPrimaryColor,
                          border: Border.all(
                            color: appPrimaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              bottomLeft: Radius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("LR-" + loadRequestId.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    )),
                Spacer(flex: 1),
                Text(dollarText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appPrimaryColor,
                        fontSize: 35.0)),
                Text(text,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              ],
            ).paddingOnly(left: 10, right: 10),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sourceDateTime,
                                style: TextStyle(
                                    fontSize: 12.0, color: lightGrey)),
                            Text(source,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(destinationDateTime,
                                style: TextStyle(
                                    fontSize: 12.0, color: lightGrey)),
                            Text(destination,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                          ],
                        ),
                      ],
                    ).paddingOnly(left: 5, right: 5),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          color: HexColor("#EE0606"),
                          size: 32.0,
                        ),
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Divider(
                                color: Colors.black,
                                height: 36,
                              )),
                        ),
                        Icon(
                          Icons.circle_rounded,
                          color: HexColor("#EE0606"),
                          size: 32.0,
                        ),
                      ],
                    ).paddingOnly(left: 20, right: 20),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(estimatedTimeText,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                Spacer(flex: 1),
                Text(labelText,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              ],
            ).paddingOnly(left: 10, right: 10),
          ],
        ),
      ),
    ),
  );
}
// Widget uploadRecieptBox(
//     {double? width, double? height, String labelText = "", String text = ""}) {
//   return DottedBorder(
//     color: appPrimaryColor,
//     borderType: BorderType.RRect,
//     radius: Radius.circular(12),
//     child: Container(
//       alignment: Alignment.center,
//       width: width,
//       height: height,
//       color: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//           color: lightGreyBoxColor,
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.camera_alt_outlined,
//               color: HexColor("#EE0606"),
//               size: 80.0,
//             ),
//             Center(
//               child: Text(labelText,
//                   style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
//             ),
//             Center(
//               child: Text(text,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: lightGrey)),
//             )
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Widget notificationBox(
//     {double? width,
//     double? height,
//     String labelText = "",
//     String text = "",
//     String time = ""}) {
//   return DottedBorder(
//     color: appPrimaryColor,
//     borderType: BorderType.RRect,
//     radius: Radius.circular(12),
//     child: Container(
//       alignment: Alignment.center,
//       width: width,
//       height: height,
//       color: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//           color: lightGreyBoxColor,
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Text(labelText,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.0,
//                         color: appPrimaryColor)),
//                 Spacer(
//                   flex: 1,
//                 ),
//                 Text(time,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 10.0,
//                         color: lightGrey)),
//               ],
//             ).paddingOnly(left: 5, right: 5),
//             Row(
//               children: [
//                 Container(
//                   width: 300,
//                   child: Text(text,
//                       maxLines: 3,
//                       softWrap: true,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12.0,
//                       )),
//                 ),
//               ],
//             ).paddingOnly(left: 5, right: 5),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Widget taskBox(
//     {double? width,
//     double? height,
//     String labelText = "",
//     String text = "",
//     String time = ""}) {
//   return DottedBorder(
//     color: appPrimaryColor,
//     borderType: BorderType.RRect,
//     radius: Radius.circular(12),
//     child: Container(
//       alignment: Alignment.center,
//       width: width,
//       height: height,
//       color: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//           color: lightGreyBoxColor,
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Text(labelText,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.0,
//                         color: appPrimaryColor)),
//                 Spacer(
//                   flex: 1,
//                 ),
//                 Text(time,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 10.0,
//                         color: lightGrey)),
//               ],
//             ).paddingOnly(left: 5, right: 5),
//             Row(
//               children: [
//                 Container(
//                   width: 300,
//                   child: Text(text,
//                       maxLines: 3,
//                       softWrap: true,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.0,
//                       )),
//                 ),
//               ],
//             ).paddingOnly(left: 5, right: 5),
//           ],
//         ),
//       ),
//     ),
//   );
// }

Widget appbarCustom(
    {double? width,
    double? height,
    dynamic data,
    int index = 0,
    String labelText = "",
    String text = "",
    bool? isShadow,
    bool showBackBtn = true,
    bool navigateHome = false,
    bool navigateLogin = false,
    bool showMusics = false,
    bool isMusicPlaying = false,
    String screenName = '/home',
    Color? bgColor,
    Color? textColor,
    GlobalKey<ScaffoldState>? globalKey,
    bool isTransparent = false,
    Function? showMusicsList,
    Function? setState}) {
  return AppBar(
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      // systemNavigationBarColor: Colors.black, // navigation bar color
      statusBarColor: whiteColor, // status bar color
    ),
    elevation: isShadow == false ? 0.0 : 10.0,
    title: Text(labelText,
        style: TextStyle(
          fontSize: 24.0,
          color:
              isTransparent == true ? whiteColor : textColor ?? blackTextColor,
        )),
    leading: showBackBtn == true
        ? BackButton(
            color: isTransparent == true
                ? whiteColor
                : textColor ?? blackTextColor,
            onPressed: () async {
              if (navigateHome == true) {
                Get.offNamed("/home");
              } else if (isMusicPlaying == true &&
                  Get.currentRoute == '/PlaylistItemScreen') {
                await storage.write('isMusicPlaying', true);
                Get.to(
                    () => Playlist(
                          playlist: data['categoriesData']
                              [data['playlistIndex']]['playlist'],
                          photo: data['categoriesData'][data['playlistIndex']]
                              ['imageUrl'],
                        ),
                    arguments: screenData);
                // Get.offNamed('/categories')!.then((value) => setState);
              } else if (isMusicPlaying == true &&
                  Get.previousRoute == '/PlaylistItemScreen') {
                Get.toNamed(screenName);
              } else if (isMusicPlaying == true) {
                Get.toNamed(screenName);
              } else if (isMusicPlaying == false &&
                      Get.previousRoute == '/home' &&
                      Get.currentRoute == '/playlistItem' ||
                  Get.currentRoute == '/PlaylistItemScreen') {
                Get.toNamed("/home");
              } else if (navigateLogin == true) {
                Get.offAndToNamed("/login");
              } else {
                Get.back();
              }
            },
          )
        : Container(),
    backgroundColor:
        isTransparent == true ? Colors.transparent : bgColor ?? appPrimaryColor,
    actions: <Widget>[
      IconButton(
        color: isTransparent == true ? whiteColor : textColor ?? blackTextColor,
        icon: Icon(Icons.menu),
        onPressed: () {
          if (showMusics == true) {
            showMusicsList!();
          } else {
            globalKey!.currentState!.openDrawer();
          }
        },
      ),
    ],
  );
}

SliverAppBar tabBarCustom(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    bool? isShadow,
    bool showBackBtn = true}) {
  return SliverAppBar(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      // systemNavigationBarColor: Colors.black, // navigation bar color
      // statusBarColor: appPrimaryColor, // status bar color
    ),
    bottom: TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: appPrimaryColor,
      automaticIndicatorColorAdjustment: true,
      indicatorColor: appPrimaryColor,
      tabs: <Widget>[
        Tab(
          child: Text("Active",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              )),
          icon: Icon(
            Icons.directions_bus_filled_outlined,
            color: blackAppBarColor,
          ),
        ),
        Tab(
          child: Text("Pending",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              )),
          icon: Icon(
            Icons.pending_outlined,
            color: blackAppBarColor,
          ),
        ),
        Tab(
          child: Text("Finished",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              )),
          icon: Icon(
            Icons.done_all_rounded,
            color: blackAppBarColor,
          ),
        ),
      ],
    ),
    elevation: 0.0,
    title: Text("Load Request",
        style: TextStyle(
          fontSize: 24.0,
          color: Colors.black,
        )),
    leading: BackButton(
      color: Colors.black,
      onPressed: () async {
        Get.back();
      },
    ),
    backgroundColor: Colors.white,
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 10.0),
        child: IconButton(
          icon: const Icon(Icons.power_settings_new_outlined),
          color: appPrimaryColor,
          iconSize: 30.0,
          onPressed: () {
            // AuthUtils.logout();
          },
        ),
      ),
    ],
  );
}

Widget customDraggableScrollableSheet(
    {double? width,
    double? height,
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    String? screenName,
    Map<String, dynamic>? screenData,
    String? btnText1,
    String? btnText2,
    String? billingRate,
    String? cityPickUp,
    String? cityDestination,
    String? statePickUp,
    String? stateDestination,
    String? pickAddress,
    String? destinationAddress,
    String? distance,
    String? roomId,
    Function(dynamic, dynamic)? callActivity,
    String? activityTitle,
    String? activityMsg,
    Function(dynamic)? callUpdateBidStatus,
    String? bidStatusName,
    String? companyPocPhone}) {
  return DraggableScrollableSheet(
    initialChildSize: initialChildSize!,
    minChildSize: minChildSize!,
    maxChildSize: maxChildSize!,
    builder: (BuildContext context, ScrollController scrollController) {
      return SingleChildScrollView(
          controller: scrollController,
          child: Card(
            elevation: 12.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.all(0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: height! * 0.85,
                      child: Container(
                        height: height,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                width: width! * 0.2,
                                height: height * 0.01,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor,
                                    border: Border.all(
                                      color: appPrimaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 60,
                            // ),
                            // Text("Distance: $distance",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 22.0)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // IconButton(
                                //     icon: Icon(
                                //       Icons.chat_outlined,
                                //       color: appPrimaryColor,
                                //       size: 28,
                                //     ),
                                //     onPressed: () {
                                //       if (roomId != "" || roomId != null) {
                                //         Get.toNamed("/chatMsg",
                                //             arguments: [roomId]);
                                //       }
                                //     }),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                // IconButton(
                                //     icon: Icon(
                                //       Icons.phone_enabled_outlined,
                                //       color: appPrimaryColor,
                                //       size: 28,
                                //     ),
                                //     onPressed: () {
                                //       launch(
                                //         "tel://$companyPocPhone",
                                //       );
                                //     }),
                                Spacer(
                                  flex: 1,
                                ),
                                Text("\$",
                                    style: TextStyle(
                                        color: appPrimaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 35.0)),
                                Text(billingRate!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25.0)),
                              ],
                            ),
                            Text(cityPickUp! + ", " + statePickUp!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 20,
                            ),
                            Text(pickAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            SizedBox(
                              height: 50,
                            ),
                            Text(cityDestination! + ", " + stateDestination!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 20,
                            ),
                            Text(destinationAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            SizedBox(
                              height: 80,
                            ),
                            Container(
                              height: height * 0.070,
                              width: width,
                              // margin: EdgeInsets.only(left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  callActivity!(activityMsg!, activityTitle!);
                                  callUpdateBidStatus!(bidStatusName);
                                  // Respond to button press
                                  Get.toNamed(screenName!,
                                      arguments: screenData);
                                },
                                child: Text(
                                  btnText1!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: whiteTextColor,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: height * 0.070,
                              width: width,
                              // margin: EdgeInsets.only(left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  onAlertRD(context, "Contact Via:", "",
                                      btnText: "Chat",
                                      isNavigation: false,
                                      argData: [roomId, companyPocPhone],
                                      btnText2: "Call");
                                },
                                child: Text(
                                  btnText2!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: whiteTextColor,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ],
                        ).paddingOnly(
                          left: 20,
                          right: 20,
                        ),
                      ),
                    )
                  ],
                )),
          ));
    },
  );
}

Widget customTwoBtnsDraggableScrollableSheet(
    {double? width,
    double? height,
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    String? screenName,
    Map<String, dynamic>? screenData,
    String? btnText1,
    String? btnText2,
    String? btnText3,
    bool isLumperRequest = false,
    bool isImage = false,
    String? billingRate,
    String? cityPickUp,
    String? cityDestination,
    String? statePickUp,
    String? stateDestination,
    String? pickAddress,
    String? destinationAddress,
    String? distance,
    String? roomId,
    String? companyPocPhone,
    String? routeName,
    String? miles}) {
  return DraggableScrollableSheet(
    initialChildSize: initialChildSize!,
    minChildSize: minChildSize!,
    maxChildSize: maxChildSize!,
    builder: (BuildContext context, ScrollController scrollController) {
      return SingleChildScrollView(
          controller: scrollController,
          child: Card(
            elevation: 12.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.all(0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: height! * 0.85,
                      child: Container(
                        height: height,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                width: width! * 0.2,
                                height: height * 0.01,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor,
                                    border: Border.all(
                                      color: appPrimaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 60,
                            // ),
                            // Text("Distance: $distance",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 22.0)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // IconButton(
                                //     icon: Icon(
                                //       Icons.chat_outlined,
                                //       color: appPrimaryColor,
                                //       size: 28,
                                //     ),
                                //     onPressed: () {
                                //       if (roomId != "" || roomId != null) {
                                //         Get.toNamed("/chatMsg",
                                //             arguments: [roomId]);
                                //       }
                                //     }),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                // IconButton(
                                //     icon: Icon(
                                //       Icons.phone_enabled_outlined,
                                //       color: appPrimaryColor,
                                //       size: 28,
                                //     ),
                                //     onPressed: () {
                                //       launch(
                                //         "tel://$companyPocPhone",
                                //       );
                                //     }),
                                Spacer(
                                  flex: 1,
                                ),
                                Text("\$",
                                    style: TextStyle(
                                        color: appPrimaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 30.0)),
                                Text(billingRate!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25.0)),
                              ],
                            ),
                            Text(cityPickUp! + ", " + statePickUp!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(pickAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            SizedBox(
                              height: 20,
                            ),
                            Text(cityDestination! + ", " + stateDestination!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(destinationAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            SizedBox(
                              height: 20,
                            ),
                            // circles path
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.circle_outlined,
                                      color: HexColor("#EE0606"),
                                      size: 32.0,
                                    ),
                                    Text("Pickup",
                                        style: TextStyle(
                                            color: routeName == "/uploadBol"
                                                ? appPrimaryColor
                                                : null,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.0)),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                          child: Divider(
                                            color: Colors.black,
                                            height: 36,
                                          )),
                                      Text("$miles miles",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16.0)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.circle_rounded,
                                      color: HexColor("#EE0606"),
                                      size: 32.0,
                                    ),
                                    Text("Dropoff",
                                        style: TextStyle(
                                            color: routeName == "/uploadPod"
                                                ? appPrimaryColor
                                                : null,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.0)),
                                  ],
                                ),
                              ],
                            ).paddingOnly(left: 20, right: 20),
                            SizedBox(
                              height: 20,
                            ),
                            isImage == false
                                ? Container(
                                    height: height * 0.070,
                                    width: width,
                                    // margin: EdgeInsets.only(left: 20, right: 20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Respond to button press
                                        screenData!["isLumperRequest"] = true;
                                        Get.toNamed(screenName!,
                                            arguments: screenData);
                                      },
                                      child: Text(
                                        btnText1!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: whiteTextColor,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  )
                                : Container(),
                            isImage == false
                                ? SizedBox(
                                    height: 20,
                                  )
                                : Container(),
                            isImage == false
                                ? Container(
                                    height: height * 0.070,
                                    width: width,
                                    // margin: EdgeInsets.only(left: 20, right: 20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Respond to button press
                                        Get.toNamed(screenName!,
                                            arguments: screenData);
                                      },
                                      child: Text(
                                        btnText2!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: whiteTextColor,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  )
                                : Container(),
                            isImage == false
                                ? SizedBox(
                                    height: 20,
                                  )
                                : Container(),
                            isImage == false
                                ? Container(
                                    height: height * 0.070,
                                    width: width,
                                    // margin: EdgeInsets.only(left: 20, right: 20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        onAlertRD(context, "Contact Via:", "",
                                            btnText: "Chat",
                                            isNavigation: false,
                                            argData: [roomId, companyPocPhone],
                                            btnText2: "Call");
                                      },
                                      child: Text(
                                        btnText3!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: whiteTextColor,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ).paddingOnly(
                          left: 20,
                          right: 20,
                        ),
                      ),
                    )
                  ],
                )),
          ));
    },
  );
}

Widget customDraggableScrollableSheetWarning(
    {double? width,
    double? profileWidth,
    double? height,
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    String? screenName,
    Map<String, dynamic>? screenData,
    String? btnText1,
    String? billingRate,
    String? cityPickUp,
    String? cityDestination,
    String? statePickUp,
    String? stateDestination,
    String? pickAddress,
    String? destinationAddress,
    String? distance,
    String? roomId,
    Function(dynamic, dynamic)? callActivity,
    String? activityTitle,
    String? activityMsg,
    Function(dynamic)? callUpdateBidStatus,
    String? bidStatusName,
    String? companyPocPhone,
    String? profileImageUrl,
    String? name}) {
  return DraggableScrollableSheet(
    initialChildSize: initialChildSize!,
    minChildSize: minChildSize!,
    maxChildSize: maxChildSize!,
    builder: (BuildContext context, ScrollController scrollController) {
      return SingleChildScrollView(
          controller: scrollController,
          child: Card(
            elevation: 12.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.all(0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: height! * 0.85,
                      child: Container(
                        height: height,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                width: width! * 0.2,
                                height: height * 0.01,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor,
                                    border: Border.all(
                                      color: appPrimaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            profileAvatar(
                                radius: 32.0,
                                name: name,
                                profileImage: profileImageUrl,
                                width: profileWidth),
                            SizedBox(
                              height: 20,
                            ),

                            Text(cityPickUp! + ", " + statePickUp!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 20,
                            ),
                            Text(pickAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            SizedBox(
                              height: 50,
                            ),
                            Text(cityDestination! + ", " + stateDestination!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.0)),
                            SizedBox(
                              height: 20,
                            ),
                            Text(destinationAddress!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: darkGrey)),
                            // SizedBox(
                            //   height: 80,
                            // ),
                            // Container(
                            //   height: height / 13.0,
                            //   width: width,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       Get.toNamed(screenName!,
                            //           arguments: screenData);
                            //     },
                            //     child: Text(
                            //       btnText1!,
                            //       style: TextStyle(
                            //           fontWeight: FontWeight.bold,
                            //           color: whiteTextColor,
                            //           fontSize: 20.0),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ).paddingOnly(
                          left: 20,
                          right: 20,
                        ),
                      ),
                    )
                  ],
                )),
          ));
    },
  );
}

// Widget imageDottedBox(
//     {double? width, double? height, Image? image, Function? cancelImage}) {
//   return Stack(
//     children: <Widget>[
//       // Positioned(
//       //   right: 10,
//       //   top: -10,
//       //   child: IconButton(
//       //       icon: Icon(
//       //         Icons.cancel,
//       //         color: appPrimaryColor,
//       //         size: 50,
//       //       ),
//       //       onPressed: () {
//       //         cancelImage!();
//       //       }),
//       // ),
//       DottedBorder(
//           color: appPrimaryColor,
//           borderType: BorderType.RRect,
//           radius: Radius.circular(12),
//           child: Container(
//             alignment: Alignment.center, // This is needed
//             child: Image(
//               alignment: Alignment.center,
//               image: image!.image,
//               height: height,
//               width: width,
//             ),
//           )),
//     ],
//   );
// }

Widget errorMsg(String msg) {
  return Center(
    child: Text(msg,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: appPrimaryColor)),
  );
}

Future<bool?> onAlert(context, String title, String msg, AlertType type,
    {bool isNavigation = false,
    String? btnText,
    String? screenName,
    dynamic argData}) {
  return Alert(
      type: type,
      style: alertStyle,
      onWillPopActive: true,
      context: context,
      title: title,
      desc: msg,
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          color: appPrimaryColor,
          child: btnText!.isNotEmpty
              ? Text(
                  btnText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              : Container(),
          onPressed: () async {
            isNavigation == false
                ? Get.back()
                : Get.offAllNamed(screenName!, arguments: argData);
          },
        ),
      ]).show();
}

Future<bool?> onAlertTwoBtns(context, String title, String msg,
    {bool isNavigation = false,
    String? btnText,
    String? lumperBtnText,
    String? screenName,
    dynamic argData}) {
  return Alert(
      style: alertStyle,
      onWillPopActive: false,
      context: context,
      title: title,
      desc: msg,
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          color: appPrimaryColor,
          child: btnText!.isNotEmpty
              ? Text(
                  btnText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              : Container(),
          onPressed: () async {
            if (argData != null) {
              argData["isLumperRequest"] = false;
            }
            isNavigation == false
                ? Get.back()
                : Get.offAllNamed(screenName!, arguments: argData);
          },
        ),
        DialogButton(
          color: appPrimaryColor,
          child: lumperBtnText!.isNotEmpty
              ? Text(
                  lumperBtnText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              : Container(),
          onPressed: () async {
            argData["isLumperRequest"] = true;
            Get.offAllNamed(screenName!, arguments: argData);
          },
        )
      ]).show();
}

Future<bool?> onAlertRD(context, String title, String msg,
    {bool isNavigation = false,
    String? btnText,
    String? btnText2,
    String? screenName,
    dynamic argData}) {
  return Alert(
      style: alertStyleRD,
      onWillPopActive: false,
      context: context,
      title: title,
      // desc: msg,
      content: Column(
        children: <Widget>[],
      ),
      buttons: [
        DialogButton(
          color: appPrimaryColor,
          child: btnText!.isNotEmpty
              ? Text(
                  btnText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              : Container(),
          onPressed: () {
            if (argData[0] != "" || argData[0] != null) {
              // Get.toNamed("/chatMsg", arguments: [argData[0]]);
            }
          },
        ),
        DialogButton(
          color: appPrimaryColor,
          child: btnText2!.isNotEmpty
              ? Text(
                  btnText2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              : Container(),
          onPressed: () {
            launch(
              "tel://${argData[1]}",
            );
          },
        )
      ]).show();
}

Future<dynamic> imageUploadBottomSheet(context, double width, double height,
    Function getCamImage, Function selectFile) {
  return showCupertinoModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                width: width * 0.2,
                height: height * 0.01,
                child: Container(
                  decoration: BoxDecoration(
                    color: appPrimaryColor,
                    border: Border.all(
                      color: appPrimaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              alignment: Alignment.center,
              height: height * 0.2,
              child: Center(
                child: Column(
                  children: [
                    // viewImage
                    // Column(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       GestureDetector(
                    //         onTap: () {
                    //           viewImage();
                    //         },
                    //         child: Icon(
                    //           Icons.image_outlined,
                    //           size: 60.0,
                    //           color: appPrimaryColor,
                    //         ),
                    //       ),
                    //       Text("View Image",
                    //           style: TextStyle(
                    //               fontWeight: FontWeight.w300,
                    //               fontSize: 20.0,
                    //               color: Colors.black,
                    //               decoration: TextDecoration.none))
                    //     ]),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  selectFile();
                                },
                                child: Icon(
                                  Icons.image_search_outlined,
                                  size: 60.0,
                                  color: appPrimaryColor,
                                ),
                              ),
                              Text("Select Image",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      decoration: TextDecoration.none))
                            ]),
                        SizedBox(
                          width: 50,
                        ),
                        Column(children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              getCamImage();
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 60.0,
                              color: appPrimaryColor,
                            ),
                          ),
                          Text("Take Picture",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                  decoration: TextDecoration.none))
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> bottomSheetView(
    context, double width, double height, String imageUrl) {
  return showCupertinoModalBottomSheet(
    isDismissible: true,
    context: context,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                width: width * 0.2,
                height: height * 0.01,
                child: Container(
                  decoration: BoxDecoration(
                    color: appPrimaryColor,
                    border: Border.all(
                      color: appPrimaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              alignment: Alignment.center,
              height: height * 0.2,
              child: Center(
                child: Column(
                  children: [
                    // viewImage
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ViewPhotoItemScreen(
                                  image: imageUrl,
                                  name: "",
                                ),
                              )!
                                  .then((value) => Get.back());
                            },
                            child: Icon(
                              Icons.image_outlined,
                              size: 60.0,
                              color: appPrimaryColor,
                            ),
                          ),
                          Text("View Image",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                  decoration: TextDecoration.none))
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget musicCard({
  double? width,
  double? height,
  dynamic title = "",
  dynamic description = "",
  dynamic time = "",
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
  Color? textColor,
}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 52,
              width: 52,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    backgroundColor: whiteColor,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  Positioned(
                    left: 30,
                    top: 40,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            // name
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: textColor ?? whiteTextColor,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(description,
                    style: TextStyle(
                      color: textColor ?? lightGreyBoxColor,
                      fontSize: 12.0,
                    )),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget currentMusicCard({
  double? width,
  double? height,
  dynamic title = "",
  dynamic description = "",
  dynamic time = "",
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
  Color? textColor,
}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 52,
              width: 52,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    backgroundColor: whiteColor,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  Positioned(
                    left: 30,
                    top: 40,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            // name
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: textColor ?? whiteTextColor,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(description,
                    style: TextStyle(
                      color: textColor ?? lightGreyBoxColor,
                      fontSize: 12.0,
                    )),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget chatLoadBox({
  double? width,
  double? height,
  dynamic labelText = "",
  dynamic lastMsg = "",
  dynamic time = "",
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
  bool isUserOnline = false,
  bool isPackagePurchased = false,
}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 52,
              width: 52,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    backgroundColor: whiteColor,
                    backgroundImage: NetworkImage(profileImageUrl != ''
                        ? profileImageUrl
                        : "https://cdn-icons-png.flaticon.com/512/21/21104.png"),
                  ),
                  // online circle
                  isUserOnline == true
                      ? Positioned(
                          left: 30,
                          top: 40,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 16.0,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),

            SizedBox(
              width: 10,
            ),
            // name
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labelText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(lastMsg,
                    style: TextStyle(
                      color: lightGrey,
                      fontSize: 12.0,
                    )),
              ],
            ),
            SizedBox(
              width: 5,
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Package Expired badge
                isPackagePurchased == false
                    ? Container(
                        child: Container(
                            decoration: BoxDecoration(
                              color: errorColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Package Expired',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 14.0,
                                )).paddingAll(5.0)),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          maxWidth: width! * 0.3,
                        ),
                        child: Text(time)),
                SizedBox(
                  height: 10,
                ),
                // unread msgs badge
                unreadMsgCount >= 1
                    ? Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 22,
                          minHeight: 22,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadMsgCount',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget noMsgText(String msg) {
  return Center(
    child: Text(msg,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.0,
            color: blackAppBarColor)),
  );
}

Widget chatProfileAvatarAndStatus(
    {String? name,
    dynamic profileImage,
    bool isOnline = false,
    double? nameWidth}) {
  return Row(
    children: [
      CircleAvatar(
        radius: 24.0,
        backgroundImage: profileImage != null
            ? NetworkImage(profileImage)
            : NetworkImage(
                'https://cdn-icons-png.flaticon.com/512/21/21104.png',
              ),
        backgroundColor: Colors.transparent,
      ),
      Center(
        child: isOnline == true
            ? Container(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 12.0,
                ),
              )
            : Container(),
      ),
      SizedBox(width: 10),
      Container(
        width: nameWidth,
        child: Text(
          name ?? "Abcd",
          style: TextStyle(fontSize: 24),
        ),
      )
    ],
  );
}

Widget profileAvatar(
    {String? name,
    dynamic profileImage,
    double? radius,
    double? width,
    Color? textColor,
    double? fontSize}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: radius == null || radius == 0.0 ? 24.0 : radius,
        backgroundImage: profileImage != null
            ? NetworkImage(profileImage)
            : NetworkImage(
                'https://cdn-icons-png.flaticon.com/512/21/21104.png',
              ),
        backgroundColor: Colors.transparent,
      ),
      SizedBox(width: 10),
      Container(
        constraints: BoxConstraints(
          maxWidth: width! * 0.35,
        ),
        child: Text(
          name == null || name == "" ? "" : name,
          style: TextStyle(
              fontSize: fontSize ?? 24, color: textColor ?? appPrimaryColor),
        ),
      )
    ],
  );
}

Widget headingText({String? title, double? size, Color? color}) {
  return Container(
    child: Text(
      title!,
      style:
          TextStyle(fontWeight: FontWeight.bold, fontSize: size, color: color),
      // textAlign: TextAlign.center,
    ),
  );
}

Widget paragraphText({String? title, double? size, Color? color}) {
  return Container(
      child: Text(
    title!,
    style: TextStyle(fontSize: size, color: color),
    // textAlign: TextAlign.center,
  ));
}

Widget customButtonContainer(double? width, double? height) {
  return Container(
    height: height! * 0.070,
    width: width,
  );
}

Widget subcriptionPlanCard({
  BuildContext? context,
  double? width,
  double? height,
  String packageType = "",
  int packageAmount = 0,
  int packageTotalMsgs = 0,
  int packageTotalAppointments = 0,
  List<dynamic>? services,
  String imageURL = "",
  Map<String, dynamic>? screenData,
  bool? packagePurchased = false,
  bool? packagePayment = false,
  String packageExpiryDate = '',
  int? expiryDateDays,
  String alertTitle = "",
  String alertMsg = "",
  bool isNavigation = false,
  String? alertBtnText,
  User? user,
  Function? isCheckStatus,
  bool isPhoneLogin = false,
}) {
  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    color: Colors.transparent,
    child: Container(
      // width: width,
      // height: height,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.all(Radius.circular(32)),
      //   gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomRight,
      //       colors: [appSecondaryColor, appSecondaryColor2]),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Image.asset(
            imageURL,
            height: 100,
            width: 100,
            isAntiAlias: true,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            // width: width! * 0.8,
            child: Center(
              child: Text(packageType.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                      fontSize: 28.0)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            // width: width! * 0.8,
            child: Text(packageAmount.toString() + '\$',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                    fontSize: 28.0)),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              SizedBox(
                height: height! * 0.2,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  itemCount: services!.length,
                  itemBuilder: (context, index) {
                    return services[index] != ""
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.done_outlined,
                                color: whiteColor,
                                size: 16.0,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(services[index].toString().capitalize!,
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 16.0,
                                  )),
                            ],
                          )
                        : Container();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: elevatedButtonSecondStyle,
            onPressed: () async {
              if (packagePayment == true) {
                if (packagePurchased == false) {
                  onAlert(context, 'Payment Pending',
                      'Payment verification under process.', AlertType.warning,
                      isNavigation: isNavigation, btnText: alertBtnText);
                } else {
                  onAlert(context, alertTitle, alertMsg + packageExpiryDate,
                      AlertType.warning,
                      isNavigation: isNavigation, btnText: alertBtnText);
                }
              } else {
                screenData!["packageType"] = packageType;
                screenData["packageAmount"] = packageAmount;
                screenData["totalMsgs"] = packageTotalMsgs;
                screenData["totalAppointments"] = packageTotalAppointments;
                screenData["expiryDateDays"] = expiryDateDays;
                screenData["routeName"] = Get.currentRoute;
                screenData["dateTime"] = DateTime.now();
                Get.toNamed("/bankDetails", arguments: screenData);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buy Now',
                  // textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteTextColor,
                      fontSize: 20.0),
                ),
              ],
            ),
          ),
          packagePayment == true && packagePurchased == false
              ? ElevatedButton(
                  style: elevatedButtonThirdBtnStyle,
                  onPressed: () {
                    if (packagePayment == true) {
                      if (packagePurchased == false) {
                        isCheckStatus!(true);
                      }
                    } else {}
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Check Status',
                        // textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: whiteTextColor,
                            fontSize: 20.0),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ).paddingOnly(left: 20, right: 20),
    ),
  );
}

Widget onboardingDetails(
    {double? width,
    double? height,
    String labelText = "",
    String text = "",
    String services = "",
    String imageURL = ""}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        imageURL,
        height: width,
        width: height,
        isAntiAlias: true,
      ),
      Text(labelText,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: blackTextColor,
              fontSize: 32.0),
          textAlign: TextAlign.center),
      SizedBox(
        height: 20,
      ),
      Text(text,
          style: TextStyle(color: lightGrey, fontSize: 20.0),
          textAlign: TextAlign.center),
      SizedBox(
        height: 20,
      ),
    ],
  ).paddingOnly(left: 20, right: 20);
}

Widget slidersDots({int? pageNumber = 0}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.circle_rounded,
        color: pageNumber == 0 ? blackAppBarColor : lightGrey,
        size: 10.0,
      ),
      SizedBox(width: 5),
      Icon(
        Icons.circle_rounded,
        color: pageNumber == 1 ? blackAppBarColor : lightGrey,
        size: 10.0,
      ),
      SizedBox(width: 5),
      Icon(
        Icons.circle_rounded,
        color: pageNumber == 2 ? blackAppBarColor : lightGrey,
        size: 10.0,
      ),
    ],
  );
}

Widget notificationBox({
  double? width,
  double? height,
  dynamic labelText = "",
  dynamic lastMsg = "",
  dynamic time = "",
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
}) {
  return Container(
    width: width,
    height: height,
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // name
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: TextStyle(
                      color: lightGrey,
                      fontSize: 12.0,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(labelText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: width! * 0.7,
                  child: Text(lastMsg,
                      style: TextStyle(
                        overflow: TextOverflow.clip,
                        color: lightGrey,
                        fontSize: 14.0,
                      )),
                ),
              ],
            ),

            SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget appointmentBox({
  double? width,
  double? height,
  int index = 0,
  dynamic getUserData,
  dynamic uid,
  dynamic name = "",
  dynamic postType = "",
  dynamic time = "",
  dynamic timeSlot = '',
  int day = 0,
  dynamic status = "",
  dynamic statusCode = "",
  dynamic imageUrl = '',
  dynamic date = '',
  String appointmentTitle = '',
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
  bool isConsumer = false,
  Function? paymentReceived,
  Function? paymentNotReceived,
  dynamic docType,
  bool isIndivisual = false,
}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.0), topRight: Radius.circular(22.0)),
    ),
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Column(
        children: [
          Card(
            color: lightBlue,
            child: Row(
              children: [
                Text(date,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 14.0,
                    )),
                Spacer(),
                Text(appointmentTitle == '' ? time : appointmentTitle,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 14.0,
                    )),
              ],
            ).paddingOnly(left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
          ).paddingOnly(top: 20.0),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  )),
              Spacer(),
              Container(
                // width: width! * 0.2,
                // height: height! * 0.01,
                child: Container(
                    decoration: BoxDecoration(
                      color: appSecondaryColor,
                      // border: Border.all(
                      //   color: appPrimaryColor,
                      //   width: 2,
                      // ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(status!,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14.0,
                        )).paddingAll(5.0)),
              ),
            ],
          ),
          // Post type
          // SizedBox(
          //   height: 5,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text(postType,
          //         style: TextStyle(
          //           color: lightGrey,
          //           fontSize: 12.0,
          //         )),
          //   ],
          // ),

          // if status verifed
          statusCode == 1
              ? isConsumer == false
                  ? Column(
                      children: [
                        Divider(
                          color: Colors.black,
                          height: 36,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Slot available?',
                                style: TextStyle(
                                  color: blackTextColor,
                                  fontSize: 16.0,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: elevatedButtonSecondStyle,
                              onPressed: () {
                                if (statusCode == 0) {
                                  docType = 'pending';
                                } else if (statusCode == 1) {
                                  docType = 'verified';
                                } else if (statusCode == 2) {
                                  docType = 'approved';
                                } else {
                                  docType = 'verified';
                                }
                                paymentReceived!(
                                    isIndivisual,
                                    name,
                                    uid,
                                    imageUrl,
                                    docType,
                                    FirebaseAuth.instance.currentUser,
                                    day,
                                    time,
                                    timeSlot,
                                    date,
                                    status);
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              style: elevatedButtonSecondStyle,
                              onPressed: () {
                                if (statusCode == 0) {
                                  docType = 'pending';
                                } else if (statusCode == 1) {
                                  docType = 'verified';
                                } else if (statusCode == 2) {
                                  docType = 'approved';
                                } else {
                                  docType = 'verified';
                                }
                                paymentNotReceived!(
                                    isIndivisual,
                                    name,
                                    uid,
                                    imageUrl,
                                    docType,
                                    FirebaseAuth.instance.currentUser,
                                    day,
                                    time,
                                    timeSlot,
                                    date,
                                    status);
                              },
                              child: Text(
                                'No',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container()
              : Container()
        ],
      ).paddingOnly(left: 20.0, right: 20.0, bottom: 20.0),
    ),
  ).paddingOnly(top: 20.0);
}

Widget packagesBox({
  double? width,
  double? height,
  int index = 0,
  dynamic getUserData,
  dynamic uid,
  dynamic name = "",
  dynamic postType = "",
  dynamic time = "",
  dynamic timeSlot = '',
  int day = 0,
  dynamic status = "",
  dynamic statusCode = "",
  dynamic imageUrl = '',
  dynamic date = '',
  int unreadMsgCount = 0,
  dynamic profileImageUrl,
  bool isProfileImage = false,
  bool isConsumer = false,
  Function? paymentReceived,
  Function? paymentNotReceived,
  dynamic docType,
  bool isIndivisual = false,
  int expiryDateDays = 0,
  int packageAmount = 0,
  int totalAppointments = 0,
  int totalMsgs = 0,
  bool isPackagePayment = false,
  bool packagePurchased = false,
  String packageType = '',
  String expiryDate = '',
}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.0), topRight: Radius.circular(22.0)),
    ),
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Column(
        children: [
          Card(
            color: lightBlue,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(32.0),
            //       topRight: Radius.circular(32.0)),
            // ),
            child: Row(
              children: [
                Text(date,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 14.0,
                    )),
                Spacer(),
                Text(time,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 14.0,
                    )),
              ],
            ).paddingOnly(left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
          ).paddingOnly(top: 20.0),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  )),
              Spacer(),
              Container(
                // width: width! * 0.2,
                // height: height! * 0.01,
                child: Container(
                    decoration: BoxDecoration(
                      color: appSecondaryColor,
                      // border: Border.all(
                      //   color: appPrimaryColor,
                      //   width: 2,
                      // ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(status!,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14.0,
                        )).paddingAll(5.0)),
              ),
            ],
          ),
          // Post type
          // SizedBox(
          //   height: 5,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text(postType,
          //         style: TextStyle(
          //           color: lightGrey,
          //           fontSize: 12.0,
          //         )),
          //   ],
          // ),

          // if status verifed
          statusCode == 1
              ? isConsumer == false
                  ? Column(
                      children: [
                        Divider(
                          color: Colors.black,
                          height: 36,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Payment Recieved?',
                                style: TextStyle(
                                  color: blackTextColor,
                                  fontSize: 16.0,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: elevatedButtonSecondStyle,
                              onPressed: () {
                                if (statusCode == 0) {
                                  docType = 'pending';
                                } else if (statusCode == 1) {
                                  docType = 'verified';
                                } else if (statusCode == 2) {
                                  docType = 'approved';
                                } else {
                                  docType = 'verified';
                                }
                                paymentReceived!(
                                    isIndivisual,
                                    name,
                                    uid,
                                    imageUrl,
                                    docType,
                                    FirebaseAuth.instance.currentUser,
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
                                    packagePurchased);
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              style: elevatedButtonSecondStyle,
                              onPressed: () {
                                if (statusCode == 0) {
                                  docType = 'pending';
                                } else if (statusCode == 1) {
                                  docType = 'verified';
                                } else if (statusCode == 2) {
                                  docType = 'approved';
                                } else {
                                  docType = 'verified';
                                }
                                paymentNotReceived!(
                                    isIndivisual,
                                    name,
                                    uid,
                                    imageUrl,
                                    docType,
                                    FirebaseAuth.instance.currentUser,
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
                                    packagePurchased);
                              },
                              child: Text(
                                'No',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: whiteTextColor,
                                    fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: elevatedButtonSecondStyle,
                          onPressed: () {
                            Get.to(
                              () => ViewPhotoItemScreen(
                                image: imageUrl,
                                name: "",
                              ),
                            );
                          },
                          child: Text(
                            'View Screenshot',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: whiteTextColor,
                                fontSize: 20.0),
                          ),
                        ),
                      ],
                    )
                  : Container()
              : Container()
        ],
      ).paddingOnly(left: 20.0, right: 20.0, bottom: 20.0),
    ),
  ).paddingOnly(top: 20.0);
}

Widget drawer(
  BuildContext? context,
  bool? isPackagePurchased,
  bool? isConsumer, {
  double? width,
  double? height,
}) {
  return Drawer(
    backgroundColor: lightBlue,
    elevation: 20.0,
    // column holds all the widgets in the drawer
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        SizedBox(
          height: 60,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
                onTap: () => Get.toNamed('/home'),
                leading: Icon(Icons.home_filled),
                title: Text('Home')),
            ListTile(
                onTap: () {
                  if (isConsumer == false) {
                    Get.toNamed("/chat");
                  } else {
                    if (isPackagePurchased == false) {
                      onAlert(
                        context,
                        'Alert',
                        'Please buy any subscription plan to access this feature.',
                        AlertType.warning,
                        isNavigation: false,
                        btnText: 'Okay',
                      );
                    } else {
                      isConsumer == false
                          ? Get.toNamed("/chat")
                          : Get.to(() => ChatMsgScreen(
                              friendUid: AuthUtils.getFriendUid(),
                              friendName: AuthUtils.getFriendName()));
                    }
                  }
                },
                leading: Icon(Icons.message_rounded),
                title: Text('Message')),
            ListTile(
                onTap: () {
                  if (isConsumer == false) {
                    Get.toNamed("/notifications");
                  } else {
                    if (isPackagePurchased == false) {
                      onAlert(
                        context,
                        'Alert',
                        'Please buy any subscription plan to access this feature.',
                        AlertType.warning,
                        isNavigation: false,
                        btnText: 'Okay',
                      );
                    } else {
                      Get.toNamed("/notifications");
                    }
                  }
                },
                leading: Icon(Icons.notifications),
                title: Text('Notifications')),
            ListTile(
                onTap: () => Get.toNamed("/categories"),
                leading: Icon(Icons.video_library),
                title: Text('Media')),
            ListTile(
                onTap: () {
                  if (isConsumer == false) {
                    Get.toNamed("/appointments");
                  } else {
                    if (isPackagePurchased == false) {
                      onAlert(
                        context,
                        'Alert',
                        'Please buy any subscription plan to access this feature.',
                        AlertType.warning,
                        isNavigation: false,
                        btnText: 'Okay',
                      );
                    } else {
                      Get.toNamed("/appointments");
                    }
                  }
                },
                leading: Icon(Icons.bookmark_outlined),
                title: Text('Appointment')),
            Wrap(
              children: [
                PopupMenuButton<dynamic>(
                    color: lightBlue,
                    // initialValue: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    child: ListTile(
                        // onTap: () => {},
                        leading: Icon(
                          Icons.arrow_drop_down_outlined,
                        ),
                        title: Text('Subscriptions')),
                    // Callback that sets the selected popup menu item.
                    onSelected: (item) {
                      if (item == 0) {
                        Get.toNamed('/subcriptionPlans');
                      } else if (item == 1) {
                        screenData['isCheckStatus'] = true;
                        Get.toNamed('/subcriptionPlans', arguments: screenData);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<dynamic>>[
                          const PopupMenuItem<dynamic>(
                            value: 0,
                            child: Text('Buy'),
                          ),
                          const PopupMenuItem<dynamic>(
                            value: 1,
                            child: Text('View'),
                          ),
                        ]),
              ],
            ),
            // ListTile(
            //     onTap: () => Get.toNamed('/subcriptionPlans'),
            //     leading: Icon(Icons.subscriptions_rounded),
            //     title: Text('Plans')),
            // ListTile(
            //     onTap: () => {
            //           screenData['isCheckStatus'] = true,
            //           Get.toNamed('/subcriptionPlans', arguments: screenData)
            //         },
            //     leading: Icon(Icons.list_alt_outlined),
            //     title: Text('Subscriptions')),
            ListTile(
                onTap: () => Authentication.signOut(),
                leading: Icon(Icons.logout_rounded),
                title: Text('Logout')),
          ],
        )
      ],
    ),
  );
}

Widget musicQueueList(
    {double? width,
    double? height,
    dynamic playlist,
    String photoUrl = '',
    int index = 0,
    Function? playQueueTrack}) {
  return Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Now Playing',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: textColor,
                    fontSize: 22.0)),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        currentMusicCard(
            width: width,
            height: height! * 0.09,
            profileImageUrl: photoUrl,
            title: playlist[index]['title'],
            description: playlist[index]['description'],
            textColor: blackTextColor),
        SizedBox(
          height: 30,
        ),
        Text('Next Other Songs',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                // color: textColor,
                fontSize: 22.0)),
        SizedBox(
          height: 20,
        ),
        Expanded(
            child: ListView.separated(
          // controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: playlist.length,
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                playQueueTrack!(i);
              },
              child: musicCard(
                  width: width,
                  height: height * 0.09,
                  profileImageUrl: photoUrl,
                  title: playlist[i]['title'],
                  description: playlist[i]['description'],
                  textColor: blackTextColor),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: lightGrey,
            );
          },
        )),
      ],
    ).paddingAll(20.0),
  );
}

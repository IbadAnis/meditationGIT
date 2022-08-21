// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meditation/Pages/Playlist/categoriesPlaylist.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/authUtils.dart';
import '../../main.dart';
import 'mediaPlayer.dart';
import 'playlistServices.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List categoriesData = [];
  bool isPackagePurchased = false;
  bool isConsumer = true;
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();

  late Map<String, dynamic> screenData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();

    // get categories data
    QuerySnapshot categoriesDataTemp = await PlaylistServices.getCategories();
    logger.d(categoriesDataTemp);
    for (var element in categoriesDataTemp.docs) {
      logger.d(element.data());
      setState(() {
        categoriesData.add(element.data());
      });
    }
    logger.d(categoriesData.length);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return categoriesData.isEmpty
        ? Center(
            child: CircularProgressIndicator(
              color: whiteColor,
            ),
          )
        : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [appSecondaryColor, appSecondaryColor2])),
            child: WillPopScope(
              onWillPop: () async {
                AuthUtils.getIsMusicPlaying() == true
                    ? Get.toNamed('/home')
                    : Get.back();
                return false;
              },
              child: Scaffold(
                  key: scaffoldKey,
                  drawer: drawer(context, isPackagePurchased, isConsumer),
                  backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100),
                      child: appbarCustom(
                              globalKey: scaffoldKey,
                              textColor: whiteTextColor,
                              isShadow: false,
                              labelText: "Categories",
                              bgColor: Colors.transparent,
                              isMusicPlaying: AuthUtils.getIsMusicPlaying(),
                              screenName: '/home')
                          .paddingOnly(top: 25.0)),
                  body: Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          mainAxisExtent: 220.0,
                        ),
                        itemCount: categoriesData.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              screenData['categoriesData'] = categoriesData;
                              screenData['playlistIndex'] = index;
                              Get.to(
                                  () => Playlist(
                                        playlist: categoriesData[index]
                                            ['playlist'],
                                        photo: categoriesData[index]
                                            ['imageUrl'],
                                      ),
                                  arguments: screenData);
                            },
                            child: categorybox(
                                width: _width,
                                height: _height,
                                isbackgroundImage: true,
                                backgroundImageUrl: categoriesData[index]
                                    ['imageUrl'],
                                title: categoriesData[index]['title']),
                          );
                        },
                      ),
                      MediaPlayer(),
                    ],
                  )),
            ),
          );
  }
}

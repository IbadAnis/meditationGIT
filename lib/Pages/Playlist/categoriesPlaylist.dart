// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation/Pages/Playlist/playlistItem.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/authUtils.dart';
import 'mediaPlayer.dart';

class Playlist extends StatefulWidget {
  final playlist;
  final photo;

  const Playlist({
    Key? key,
    this.playlist,
    this.photo,
  }) : super(key: key);

  @override
  State<Playlist> createState() => _PlaylistState(playlist, photo);
}

class _PlaylistState extends State<Playlist> {
  var _controller;
  bool isPackagePurchased = false;
  bool isConsumer = true;
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic photo;
  dynamic playlist;

  // screen fields
  dynamic argumentData = Get.arguments;
  late Map<String, dynamic> screenData = <String, dynamic>{};

  _PlaylistState(
    this.playlist,
    this.photo,
  );

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();
    if (argumentData != null) {
      screenData['categoriesData'] = argumentData['categoriesData'];
      screenData['playlistIndex'] = argumentData['playlistIndex'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return playlist == null
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
                            labelText: "Playlist",
                            bgColor: Colors.transparent,
                            isMusicPlaying: AuthUtils.getIsMusicPlaying(),
                            screenName: '/categories')
                        .paddingOnly(top: 25.0)),
                body: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                              child: ListView.separated(
                            controller: _controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: playlist.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                  onTap: () {
                                    Get.to(
                                        () => PlaylistItemScreen(
                                              photo: photo,
                                              musicUrl: playlist[i]['musicUrl'],
                                              description: playlist[i]
                                                  ['description'],
                                              title: playlist[i]['title'],
                                              playlistData: playlist,
                                            ),
                                        arguments: screenData);
                                  },
                                  child: musicCard(
                                    width: _width,
                                    height: _height * 0.09,
                                    isProfileImage: true,
                                    profileImageUrl: photo,
                                    title: playlist[i]['title'],
                                    description: playlist[i]['description'],
                                  ));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: whiteTextColor,
                              );
                            },
                          )),
                        ],
                      ).paddingOnly(left: 20.0, right: 20.0),
                      MediaPlayer(),
                    ],
                  ),
                )),
          );
  }
}

// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/appColors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../Utils/Widgets.dart';
import '../../Utils/authUtils.dart';
import '../../main.dart';

class PlaylistItemScreen extends StatefulWidget {
  final title;
  final description;
  final photo;
  final musicUrl;
  final playlistData;
  const PlaylistItemScreen(
      {Key? key,
      this.title,
      this.description,
      this.photo,
      this.musicUrl,
      this.playlistData})
      : super(key: key);
  @override
  State<PlaylistItemScreen> createState() =>
      PlaylistItemState(title, description, photo, musicUrl, playlistData);
}

class PlaylistItemState extends State<PlaylistItemScreen> {
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "0:00:00";
  String audioasset = "assets/audio/music1.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  Uint8List? audiobytes;
  AudioPlayer player = AudioPlayer(playerId: 'playlistPlayer');
  int result = 0;

  var isPackagePurchased;
  var isConsumer;

  // playlist state data
  PlaylistItemState(this.title, this.description, this.photo, this.musicUrl,
      this.playlistData);
  dynamic title;
  dynamic description;
  dynamic photo;
  String musicUrl;
  dynamic playlistData;
  int counter = 0;

  // screen fields
  bool isLoading = false;
  bool showMusics = false;
  dynamic scaffoldKey = GlobalKey<ScaffoldState>();
  late Map<String, dynamic> currentMusicData = <String, dynamic>{};
  final storage = GetStorage();
  dynamic argumentData = Get.arguments;
  late Map<String, dynamic> screenData = <String, dynamic>{};
  int playlistIndex = 0;

  @override
  void initState() {
    init();
    Future.delayed(Duration.zero, () async {
      // ByteData bytes =
      //     await rootBundle.load(audioasset); //load audio from assets
      // audiobytes =
      //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List
      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        // setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        if (rseconds <= 9 && rminutes <= 9) {
          currentpostlabel = "$rhours:0$rminutes:0$rseconds";
        } else if (rminutes <= 9) {
          currentpostlabel = "$rhours:0$rminutes:$rseconds";
        } else {
          currentpostlabel = "$rhours:$rminutes:$rseconds";
        }

        setState(() {
          //refresh the UI
        });
      });
    });
    // player.onPlayerStateChanged.listen((PlayerState s) => {
    //       logger.d('Current player state: $s'),
    //       // setState(() => playerState = s),
    //     });
    player.onPlayerCompletion.listen((event) {
      nextTrack();
    });

    super.initState();
  }

  @override
  void dispose() {
    // player.stop();
    // player.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();

    // get screendata
    if (argumentData != null) {
      // for (var i = 0; i < argumentData.length; i++) {
      //   screenData.add(argumentData[i]);
      // }
      screenData['categoriesData'] = argumentData['categoriesData'];
      screenData['playlistIndex'] = argumentData['playlistIndex'];
    }

    // save current music data
    currentMusicData['title'] = title;
    currentMusicData['description'] = description;
    currentMusicData['photo'] = photo;
    currentMusicData['musicUrl'] = musicUrl;
    currentMusicData['playlistData'] = playlistData;
    storage.write('currentMusicData', currentMusicData);
    logger.d('currentMusicData saved!');

    result = await player.play(musicUrl);
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
      storage.write('isMusicPlaying', true);
    }
  }

  void nextTrack() async {
    await player.stop();
    storage.write('isMusicPlaying', false);
    setState(() {
      isLoading = true;
      isplaying = false;
    });
    setState(() {
      counter++;
      if (counter <= playlistData.length - 1) {
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      } else {
        counter = 0;
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      }
    });
    result = await player.play(musicUrl);
    storage.write('isMusicPlaying', true);
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void previousTrack() async {
    await player.stop();
    storage.write('isMusicPlaying', false);
    setState(() {
      isLoading = true;
      isplaying = false;
      counter--;
      if (counter >= 0) {
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      } else {
        counter = 0;
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      }
    });

    result = await player.play(musicUrl);
    storage.write('isMusicPlaying', true);
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void playQueueTrack(int index) async {
    await player.stop();
    storage.write('isMusicPlaying', false);
    setState(() {
      isLoading = true;
      isplaying = false;
    });
    setState(() {
      musicUrl = playlistData[index]['musicUrl'];
      title = playlistData[index]['title'];
    });
    result = await player.play(musicUrl);
    storage.write('isMusicPlaying', true);
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
    }
    setState(() {
      isLoading = false;
    });
    Get.back();
  }

  // temp
  void playSongAutomatically() async {
    await player.stop();
    storage.write('isMusicPlaying', false);
    setState(() {
      isLoading = true;
      isplaying = false;
    });
    setState(() {
      counter++;
      if (counter <= playlistData.length - 1) {
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      } else {
        counter = 0;
        musicUrl = playlistData[counter]['musicUrl'];
        title = playlistData[counter]['title'];
      }
    });
    result = await player.play(musicUrl);
    storage.write('isMusicPlaying', true);
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showMusicsList() {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      builder: (context) => musicQueueList(
          height: _height,
          width: _width,
          index: counter,
          playlist: playlistData,
          photoUrl: photo,
          playQueueTrack: playQueueTrack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return player == null
        ? Center(
            child: CircularProgressIndicator(
              color: whiteColor,
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              AuthUtils.getIsMusicPlaying() == true
                  ? Get.toNamed('/categories')
                  : Get.toNamed('/home');
              return false;
            },
            child: Scaffold(
                extendBodyBehindAppBar: true,
                // drawer: drawer(context, isPackagePurchased, isConsumer),
                key: scaffoldKey,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: appbarCustom(
                            data: screenData,
                            isTransparent: true,
                            globalKey: scaffoldKey,
                            isShadow: false,
                            labelText: "Music Player",
                            bgColor: lightBlue,
                            showMusics: true,
                            showMusicsList: showMusicsList,
                            screenName: '/playlist',
                            isMusicPlaying: AuthUtils.getIsMusicPlaying())
                        .paddingOnly(top: 25.0)),
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(photo),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (!isplaying && !audioplayed) {
                            // int result = await player.playBytes(audiobytes!);
                            result = await player.play(musicUrl);
                            if (result == 1) {
                              //play success
                              setState(() {
                                isplaying = true;
                                audioplayed = true;
                              });
                            } else {
                              logger.d("Error while playing audio.");
                            }
                          } else if (audioplayed && !isplaying) {
                            result = await player.resume();
                            storage.write('isMusicPlaying', true);
                            if (result == 1) {
                              //resume success
                              setState(() {
                                isplaying = true;
                                audioplayed = true;
                              });
                            } else {
                              logger.d("Error on resume audio.");
                            }
                          } else {
                            result = await player.pause();
                            storage.write('isMusicPlaying', false);
                            if (result == 1) {
                              //pause success
                              setState(() {
                                isplaying = false;
                              });
                            } else {
                              logger.d("Error on pause audio.");
                            }
                          }
                        },
                        child: isLoading == true
                            ? Lottie.asset('assets/lottie/lottieMusic.json',
                                width: 100.0, height: 100.0)
                            : Icon(
                                isplaying ? Icons.pause : Icons.play_arrow,
                                color: whiteColor,
                                size: 150.0,
                              ),
                      ),
                      isLoading == true
                          ? Container().paddingOnly(bottom: 250.0)
                          : Text(
                              title ?? 'Song Name',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold),
                            ).paddingOnly(bottom: 250.0),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              previousTrack();
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              currentpostlabel,
                              style: TextStyle(fontSize: 25, color: whiteColor),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 35,
                            ),
                            onPressed: () {
                              nextTrack();
                            },
                          ),
                        ],
                      ),
                      Container(
                          child: Slider(
                        activeColor: appSecondaryColor,
                        inactiveColor: whiteColor,
                        thumbColor: appSecondaryColor,
                        value: double.parse(currentpos.toString()),
                        min: 0,
                        max: double.parse(maxduration.toString()),
                        // divisions: maxduration,
                        label: currentpostlabel,
                        onChanged: (double value) async {
                          int seekval = value.round();
                          int result = await player
                              .seek(Duration(milliseconds: seekval));
                          if (result == 1) {
                            //seek successful
                            currentpos = seekval;
                          } else {
                            logger.d("Seek unsuccessful.");
                          }
                        },
                      )),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )),
          );
  }
}

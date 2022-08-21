// ignore_for_file: file_names, sized_box_for_whitespace, avoid_unnecessary_containers, no_logic_in_create_state

import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meditation/Utils/authUtils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../Utils/appColors.dart';
import '../../main.dart';
import 'playlistItem.dart';

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({
    Key? key,
  }) : super(key: key);

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  // playlist state data
  // _MediaPlayerState(this.title, this.description, this.photo, this.musicUrl,
  //     this.playlistData);

  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "0:00:00";
  String audioasset = "assets/audio/music1.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  Uint8List? audiobytes;
  AudioPlayer player = AudioPlayer(playerId: 'playlistPlayer');
  int result = 0;

  // music data fields
  String musicUrl = '';
  dynamic title;
  dynamic description;
  dynamic photo;
  dynamic playlistData;
  int counter = 0;

  // screen data fields
  bool isLoading = false;
  bool showMediaPlayer = false;
  dynamic currentMusicData;
  var isPackagePurchased;
  var isConsumer;
  var isMusicPlaying;
  bool isPlayBackMediaPlaying = true;
  final _width = Get.width;
  final _height = Get.height;
  final storage = GetStorage();

  @override
  void initState() {
    init();

    // set music labels
    Future.delayed(Duration.zero, () async {
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
    //       setState(() {
    //         isplaying = true;
    //         audioplayed = true;
    //       })
    //     });
    player.onPlayerCompletion.listen((event) {
      nextTrack();
    });

    super.initState();
  }

  init() async {
    isPackagePurchased = AuthUtils.getPackagePurchased();
    isConsumer = AuthUtils.getIsConsumer();
    isMusicPlaying = AuthUtils.getIsMusicPlaying();
    isPlayBackMediaPlaying = AuthUtils.getIsPlayBackMediaPlaying();

    // get music current data
    currentMusicData = AuthUtils.getCurrentMusicData();
    if (currentMusicData != null) {
      setState(() {
        musicUrl = currentMusicData['musicUrl'];
        title = currentMusicData['title'];
        description = currentMusicData['description'];
        photo = currentMusicData['photo'];
        playlistData = currentMusicData['playlistData'];
      });
    }

    // play music at start
    if (isPlayBackMediaPlaying == true) {
      result = await player.play(musicUrl);
    }
    if (result == 1) {
      //play success
      setState(() {
        isplaying = true;
        audioplayed = true;
      });
    }
  }

  @override
  void dispose() {
    // player.stop();
    // player.dispose();
    // storage.write('isMusicPlaying', true);
    super.dispose();
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

  Widget mediaPlayerUI() {
    return Stack(
      alignment: AlignmentDirectional.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => PlaylistItemScreen(
                          photo: photo,
                          musicUrl: musicUrl,
                          description: description,
                          title: title,
                          playlistData: playlistData,
                        ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      photo,
                      height: _height * 0.12,
                      width: _width * 0.12,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Song Name',
                      style: TextStyle(
                          fontSize: 14,
                          color: whiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: Get.width * 0.32,
                      ),
                      child: Text(
                        description ?? 'Artist',
                        style: TextStyle(
                            fontSize: 14,
                            color: whiteColor,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    previousTrack();
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    if (!isplaying && !audioplayed) {
                      // int result = await player.playBytes(audiobytes!);
                      result = await player.play(musicUrl);
                      storage.write('isPlayBackMediaPlaying', true);
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
                      storage.write('isPlayBackMediaPlaying', false);
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
                  child: Icon(
                    isplaying ? Icons.pause : Icons.play_arrow,
                    color: whiteColor,
                    size: 32.0,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: const Icon(
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
          ],
        ),
        // LinearProgressIndicator(
        //   value: double.parse(currentpos.toString()) * 0.000003,
        //   valueColor: AlwaysStoppedAnimation<Color>(
        //     lightGrey,
        //   ),
        //   backgroundColor: appPrimaryColor,
        // ),

        Positioned(
          width: _width,
          // right: 5.0,
          top: 60.0,
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
              int result = await player.seek(Duration(milliseconds: seekval));
              if (result == 1) {
                //seek successful
                currentpos = seekval;
              } else {
                logger.d("Seek unsuccessful.");
              }
            },
          ),
        ),

        // music timer label
        // Container(
        //   child: Text(
        //     currentpostlabel,
        //     style: TextStyle(fontSize: 25, color: whiteColor),
        //   ),
        // ),
      ],
    ).paddingOnly(left: 10.0, right: 10.0);
  }

  Widget mediaPlayerCustomSheet({
    double? width,
    double? height,
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    Map<String, dynamic>? screenData,
  }) {
    return Column(
      children: [
        const Spacer(),
        Container(
          // height: height! * 0.1,
          child: Card(
            color: blackAppBarColor,
            elevation: 12.0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22.0),
                    topRight: Radius.circular(22.0))),
            margin: const EdgeInsets.all(0),
            child: mediaPlayerUI(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isMusicPlaying == true
        ? mediaPlayerCustomSheet(height: _height, width: _width)
        : Container();
  }
}

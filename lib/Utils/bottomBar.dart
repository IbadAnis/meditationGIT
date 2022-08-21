// ignore_for_file: file_names, prefer_const_constructors

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meditation/Utils/appColors.dart';
import '../../main.dart';

class BottomBarScreen extends StatefulWidget implements PreferredSizeWidget {
  const BottomBarScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  BottomBarScreenState createState() => BottomBarScreenState();
}

class BottomBarScreenState extends State<BottomBarScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  int unreadChatsCounter = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        {
          Get.toNamed("/home");
        }
        break;
      case 1:
        {
          setState(() {
            _selectedIndex = index;
          });
          Get.toNamed("/history");
        }
        break;
      case 2:
        {
          setState(() {
            _selectedIndex = index;
          });
          Get.toNamed("/tasksLoadRequest");
        }
        break;
      case 3:
        {
          setState(() {
            _selectedIndex = index;
          });
          Get.toNamed("/chat");
        }
        break;
      default:
        {
          setState(() {
            _selectedIndex = index;
          });
          Get.toNamed("/home");
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return BottomNavigationBar(
      iconSize: 32,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
            icon: unreadChatsCounter == 0
                ? Icon(Icons.chat_outlined)
                : Stack(children: <Widget>[
                    Icon(Icons.chat_outlined),
                    Positioned(
                      left: _width * 0.035,
                      bottom: _height * 0.017,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadChatsCounter',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  ]),
            label: 'Chat'),
      ],
      elevation: 0.0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      selectedItemColor: appPrimaryColor,
      unselectedItemColor: blackAppBarColor,
      onTap: (value) =>
          setState(() => {_selectedIndex = value, onItemTapped(value)}),
    );
  }
}

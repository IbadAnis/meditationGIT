import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditation/Utils/authUtils.dart';

import '../Pages/Authentication/authenticationServices.dart';
import '../main.dart';

class LifeCycleManager extends StatefulWidget {
  const LifeCycleManager({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  // use this for checking app state for all routes

  //Firebase
  dynamic currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    if (AuthUtils.getLoggedIn() != null || AuthUtils.getLoggedIn() != false) {
      currentUser = FirebaseAuth.instance.currentUser;
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        logger.d("app in resumed");
        if (AuthUtils.getLoggedIn() != null ||
            AuthUtils.getLoggedIn() != false) {
          // update user online status
          await Authentication.updateUserDetails(
            true,
            'isUserOnline',
            true,
            currentUser.uid,
          );
        }
        break;
      case AppLifecycleState.inactive:
        logger.d("app in inactive");
        // update user online status
        await Authentication.updateUserDetails(
          true,
          'isUserOnline',
          false,
          currentUser.uid,
        );
        break;
      case AppLifecycleState.paused:
        logger.d("app in paused");
        // update user online status
        await Authentication.updateUserDetails(
          true,
          'isUserOnline',
          false,
          currentUser.uid,
        );
        break;
      case AppLifecycleState.detached:
        logger.d("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}

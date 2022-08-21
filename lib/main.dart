// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:meditation/Pages/Appointment/appointments.dart';
import 'package:meditation/Pages/Authentication/loginWithPhone.dart';
import 'package:meditation/Pages/Chat/chatUsers.dart';
import 'package:meditation/Pages/Booking/booking.dart';
import 'package:meditation/Pages/Home/home.dart';
import 'package:meditation/Pages/InAppPurchase/subcriptionPlans.dart';
import 'package:meditation/Pages/OnBoarding/onBoardingSlides.dart';
import 'package:meditation/Pages/Playlist/playlistItem.dart';
import 'package:meditation/Pages/Playlist/categoriesPlaylist.dart';
import 'package:meditation/Pages/UserDetails/bankDetails.dart';
import 'package:meditation/Utils/appColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Pages/Authentication/login.dart';
import 'Pages/Authentication/signUp.dart';
import 'Pages/Authentication/signUpForm.dart';
import 'Pages/Chat/chatMsg.dart';
import 'Pages/Notification/notifications.dart';
import 'Pages/Playlist/categories.dart';
import 'package:geolocator/geolocator.dart';

import 'Pages/Playlist/mediaPlayer.dart';
import 'Utils/LifecycleManager.dart';
import 'Utils/Widgets.dart';

var logger = Logger(filter: null, level: Level.debug);

ConnectivityResult _connectionStatus = ConnectivityResult.none;
final Connectivity _connectivity = Connectivity();
late StreamSubscription<ConnectivityResult> _connectivitySubscription;

// location fields

String errorText = "";
bool isError = false;

// Firebase Fields
Future<void> _firebaseMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.d("Firebase msg: ${message.messageId}");
}

// Notifications FIelds
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('launch_background');
InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  // iOS: initializationSettingsIOS,
);
AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
  '1',
  'meditation',
  description: 'this is meditation channel',
  importance: Importance.max,
  showBadge: true,
  playSound: true,
);

Future<void> firebaseBackgroundMsgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.d("firebaseBackgroundMsgHandler $message");
}

Future<void> main() async {
  // firebase init

  WidgetsFlutterBinding.ensureInitialized();
  // if (Firebase.apps.isNotEmpty) {
  //   await Firebase.initializeApp(
  //       name: "meditation",
  //       options: kIsWeb || Platform.isAndroid
  //           ? FirebaseOptions(
  //               apiKey:
  //                   "AAAAZs2m8rk:APA91bGhXa2pOopW4MQ51yU655MJVuuyf-mLZnyMZ4fnMCFXRwZ9sMBRTmyDKN5nLAYvKSrvWHV9nJECteKH5GAtbygXQqloHQD6i_AH8rqaHwc9PCpWeTCEzAHHWtz01qZD1sT1H6Bk",
  //               appId: "1:441536934585:android:478ba1b80b1661e391a168",
  //               messagingSenderId: "441536934585",
  //               projectId: "meditation-82f50",
  //               storageBucket:
  //                   "https://console.firebase.google.com/project/meditation-82f50/storage/meditation-82f50.appspot.com/files",
  //             )
  //           : null);
  // } else {
  //   Firebase.app();
  // }
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMsgHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: GetMaterialApp(
        initialRoute: '/',
        // builder: (context, widget) => MediaPlayer(),
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/signUp', page: () => SignUpScreen()),
          GetPage(name: '/signUpForm', page: () => SignUpFormScreen()),
          GetPage(name: '/loginWithPhone', page: () => LoginWithPhoneScreen()),
          GetPage(name: '/onboarding', page: () => OnBoardingScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/bankDetails', page: () => BankDetailsScreen()),
          GetPage(
              name: '/subcriptionPlans', page: () => SubcriptionPlansScreen()),
          GetPage(name: '/booking', page: () => BookingScreen()),
          GetPage(name: '/chatMsg', page: () => ChatMsgScreen()),
          GetPage(name: '/chat', page: () => ChatScreen()),
          GetPage(name: '/notifications', page: () => NotificationsScreen()),
          GetPage(name: '/appointments', page: () => AppointmentsScreen()),
          GetPage(name: '/playlistItem', page: () => PlaylistItemScreen()),
          GetPage(name: '/playlist', page: () => Playlist()),
          GetPage(name: '/categories', page: () => Categories()),
        ],
        theme: ThemeData(
          fontFamily: "UberMove",
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme(
            primary: appPrimaryColor,
            background: whiteColor,
            brightness: Brightness.light,
            error: errorColor,
            onBackground: whiteColor,
            onError: errorColor,
            onPrimary: appPrimaryColor,
            onSecondary: appSecondaryColor,
            onSurface: appPrimaryColor,
            secondary: appSecondaryColor,
            surface: appPrimaryColor,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  // late final AnimationController _controller = AnimationController(
  //   duration: const Duration(seconds: 3),
  //   vsync: this,
  // )..forward();
  // late final Animation<double> _animation = CurvedAnimation(
  //   parent: _controller,
  //   curve: Curves.easeInOut,
  // );
  bool loginSuccess = false;
  final storage = GetStorage();
  late Map<String, dynamic> screenData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    WidgetsBinding.instance!.addObserver(this);
    await storage.initStorage;

    // reset music playing
    storage.write("isMusicPlaying", false);

    // check internet connection
    ConnectivityResult result = await initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Firebase token
    if (result != ConnectivityResult.none) {
      String? token = await FirebaseMessaging.instance.getToken();
      storage.write("fcmToken", token);
      logger.d("fcmToken saved: " + token!);
      await setupInteractedMessage();
      // check location
      await _determinePosition();
      // listen notification message.
      listenFCM();

      Timer(Duration(seconds: 3), () {
        Get.offNamed(
          "/login",
        );
      });
    } else {
      _updateConnectionStatus(result);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onAlert(
        context,
        'Alert',
        'Location service is disabled!',
        AlertType.warning,
        isNavigation: false,
        btnText: 'Okay',
      );
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'appointment') {
      // screenData["fk_load_request"] = message.data["fk_load_request"];
      // screenData["status"] = message.data["status"];
      Get.toNamed("/appointments", arguments: screenData);
    } else if (message.data['type'] == 'package' &&
        message.data['status'] == 'Approved') {
      screenData['isCheckStatus'] = true;
      Get.toNamed('/subcriptionPlans', arguments: screenData);
    } else if (message.data['type'] == 'package' &&
        message.data['status'] == 'Rejected') {
      screenData['isCheckStatus'] = true;
      Get.toNamed('/subcriptionPlans', arguments: screenData);
    } else if (message.data['type'] == 'package') {
      Get.toNamed('/subcriptionPlans');
    } else if (message.data['type'] == 'chat') {
      Get.toNamed('/chat');
    } else {
      Get.toNamed('/home');
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<ConnectivityResult> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      logger.d(e.toString());
      return result;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return result;
  }

  void _updateConnectionStatus(ConnectivityResult connectResult) async {
    logger.d("_updateConnectionStatus");
    var result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      Get.defaultDialog(
        title: "Alert",
        middleText: "Your internet is disconnected.",
        backgroundColor: whiteColor,
        titleStyle: TextStyle(color: blackAppBarColor, fontSize: 20),
        middleTextStyle: TextStyle(color: blackAppBarColor, fontSize: 16),
        confirmTextColor: Colors.white,
        confirm: ElevatedButton(
          onPressed: () {
            // Respond to button press
            if (result == ConnectivityResult.none) {
              Get.offAllNamed('/login');
            } else {
              Get.back();
            }
          },
          child: Text(
            'Reconnect',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: whiteTextColor,
                fontSize: 20.0),
          ),
        ),
        buttonColor: appPrimaryColor,
        // barrierDismissible: false,
        radius: 12,
      );
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      Get.back();
    }

    // if (Get.currentRoute == "/") {
    //   setState(() {
    //     _connectionStatus = result;
    //   });
    // }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        logger.d(message);
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidNotificationChannel.id,
              androidNotificationChannel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    // _controller.stop();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                  width: _width,
                  height: _height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/Splash.png"),
                      fit: BoxFit.cover,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

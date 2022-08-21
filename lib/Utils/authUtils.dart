import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../main.dart';

class AuthUtils {
  // Keys to store and fetch data from SharedPreferences
  static GetStorage storage = GetStorage();

  static const String name = 'name';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String fcmToken = 'fcmToken';
  static const String userId = 'userId';
  static const String loginSuccess = 'loginSuccess';
  static const String loginResponse = 'loginResponse';
  static const String isPackagePurchased = 'isPackagePurchased';
  static const String isPackagePayment = 'isPackagePayment';
  static const String isConsumer = 'isConsumer';
  static const String friendUid = 'friendUid';
  static const String friendName = 'Astrologer Latif Ghauri';
  static const String isFacebookLogin = 'isFacebookLogin';
  static const String isPhoneLogin = 'isPhoneLogin';
  static const String photoURL = 'photoURL';
  static const String serverKey = 'serverKey';
  static const String adminFcmToken = 'adminFcmToken';
  static const String loggedIn = 'loggedIn';
  static const String currentMusicData = 'currentMusicData';
  static const String isMusicPlaying = 'isMusicPlaying';
  static const String isPlayBackMediaPlaying = 'isPlayBackMediaPlaying';

  static void logout() async {
    await storage.erase();
    Get.offAllNamed("/login");
  }

  static dynamic getLoggedIn() {
    return storage.read(loggedIn);
  }

  static String? getName() {}

  static setName(String value) {}

  static String? getSessionid() {}

  static String? getEmail() {}

  static setEmail(String value) {}

  static String? getDisplayName() {
    return storage.read(displayName);
  }

  static String? getfcmToken() {
    return storage.read(fcmToken);
  }

  static bool? getLoginSuccess() {
    return storage.read(loginSuccess);
  }

  static bool getIsMusicPlaying() {
    dynamic isBool = storage.read(isMusicPlaying);
    return isBool ?? false;
  }

  static bool getIsPlayBackMediaPlaying() {
    dynamic isBool = storage.read(isPlayBackMediaPlaying);
    return isBool ?? false;
  }

  static int? getUserId() {
    return storage.read(userId);
  }

  static dynamic getLoginResponse() {
    return storage.read(loginResponse);
  }

  static dynamic getPackagePurchased() {
    return storage.read(isPackagePurchased);
  }

  static dynamic getPackagePayment() {
    return storage.read(isPackagePayment);
  }

  static dynamic getIsConsumer() {
    return storage.read(isConsumer);
  }

  static dynamic getFriendUid() {
    return storage.read(friendUid);
  }

  static dynamic getFriendName() {
    return friendName;
  }

  static dynamic getIsFacebookLogin() {
    return storage.read(isFacebookLogin);
  }

  static dynamic getIsPhoneLogin() {
    return storage.read(isPhoneLogin);
  }

  static dynamic getPhotoURL() {
    return storage.read(photoURL);
  }

  static dynamic getServerKey() {
    return storage.read(serverKey);
  }

  static dynamic getAdminFcmToken() {
    return storage.read(adminFcmToken);
  }

  static dynamic getCurrentMusicData() {
    return storage.read(currentMusicData);
  }
}

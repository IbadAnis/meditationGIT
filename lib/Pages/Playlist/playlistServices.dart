import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../Utils/status.dart';
import '../../main.dart';

DateTime currentDate = DateTime.now();
String date = '';
String expiryDate = '';
dynamic currentUserDetails;
late Map<String, dynamic> screenData = <String, dynamic>{};

final storage = GetStorage();

class PlaylistServices {
  static Future<dynamic> getCategories() async {
    QuerySnapshot getCategoriesDetails;
    getCategoriesDetails =
        await FirebaseFirestore.instance.collection('categories').get();
    return getCategoriesDetails;
  }
}

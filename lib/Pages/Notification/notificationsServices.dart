import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

DateTime currentDate = DateTime.now();
final DateFormat formatter = DateFormat('yyyy-MM-dd');
final timeFormat = DateFormat.jm(); // "6:00 AM"
String date = formatter.format(currentDate);
String day = DateFormat('EEEE').format(currentDate);
String time = timeFormat.format(currentDate);

class NotificationsServices {
  static Future<void> sendNotification(
    String _serverKey,
    fcmToken, {
    String? body,
    String? title,
    String? uid,
    String? status,
    String? type,
    String? displayName,
  }) async {
    logger.d("fcmToken: " + fcmToken);
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=' + _serverKey,
        },
        body: jsonEncode(
          <String, dynamic>{
            'token': fcmToken,
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'uid': uid,
              'displayName': displayName,
              'status': status,
              'type': type,
              'date': date,
              'time': time,
              'day': day,
            },
            "to": fcmToken,
          },
        ),
      );
    } catch (e) {
      logger.d("error push notification");
    }
  }

  static Future<void> addNotificationToCollection(
    String? body,
    String? title,
    String date,
    String time,
    String? displayName,
    String? uid,
    String? status,
    String? type,
  ) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection(status.toString().toLowerCase());
    return notifications
        .doc('notifications')
        .update(
          {
            'data': FieldValue.arrayUnion([
              {
                'body': body,
                'title': title,
                'displayName': displayName,
                'uid': uid,
                'status': status,
                'type': type,
                'date': date,
                'time': time,
                'day': day,
              }
            ])
          },
        )
        .then((value) => logger.d("addNotificationToCollection added"))
        .catchError((error) =>
            logger.d("Failed to add addNotificationToCollection: $error"));
  }
}

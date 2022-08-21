import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../main.dart';
import '../Authentication/authenticationServices.dart';

String downloadURL = '';
String selectedDayToString = '';

class BookingServices {
  static Future<void> addTimeSlotDoc() async {
    dynamic docExists;
    CollectionReference timeslot =
        FirebaseFirestore.instance.collection('timeslot');
    String currentDate = '';
    if (DateTime.now().day < 9) {
      currentDate = '0' + DateTime.now().day.toString();
    } else {
      currentDate = DateTime.now().day.toString();
    }
    // check if user Exists
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentDate)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      docExists = documentSnapshot.exists;
    });

    return docExists == true
        ? timeslot
            .doc(DateTime.now().day.toString())
            .get()
            .then((value) => logger.d("get TimeSlotDoc"))
            .catchError(
                (error) => logger.d("Failed to get timeslot doc: $error"))
        : timeslot
            .doc(currentDate)
            .set({
              'timeSlots': [
                "1:00 PM to 3:00 PM",
                "4:00 PM to 6:00 PM",
                "7:00 PM to 9:00 PM"
              ]
            })
            .then((value) => logger.d("added TimeSlots"))
            .catchError(
                (error) => logger.d("Failed to add timeslots doc: $error"));
  }

  static Future<void> addTimeSlots(int selectedDay, String timeSlot) async {
    CollectionReference timeslot =
        FirebaseFirestore.instance.collection('timeslot');
    if (selectedDay <= 9) {
      selectedDayToString = '0' + selectedDay.toString();
    } else {
      selectedDayToString = selectedDay.toString();
    }

    // update current day array
    await timeslot
        .doc(selectedDayToString)
        .update({
          'timeSlots': FieldValue.arrayUnion([timeSlot]),
        })
        .then((value) => logger.d("added $timeSlot  TimeSlot"))
        .catchError(
            (error) => logger.d("Failed to add $timeSlot TimeSlot: $error"));
  }

  static Future<void> addRejectedTimeSlotDoc(
      int selectedDay, String timeSlot) async {
    CollectionReference timeslot =
        FirebaseFirestore.instance.collection('timeslot');
    if (selectedDay <= 9) {
      selectedDayToString = '0' + selectedDay.toString();
    } else {
      selectedDayToString = selectedDay.toString();
    }
    timeslot
        .doc(selectedDayToString)
        .update({
          'timeSlots': FieldValue.arrayUnion([timeSlot]),
        })
        .then((value) => logger.d("add rejected TimeSlot"))
        .catchError((error) =>
            logger.d("Failed to add rejected timeslots doc: $error"));
  }

  static Future<Set<Map<String, dynamic>?>> getTImeSlots() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('timeSlot')
        .doc(DateTime.now().day.toString())
        .get()
        .then((value) => {value.data()});
    return snapshot;
  }

  static Future<void> deleteSelectedTimeSlot(
      int selectedDay, String selectedSlotTime) {
    CollectionReference timeslot =
        FirebaseFirestore.instance.collection('timeslot');
    if (selectedDay <= 9) {
      selectedDayToString = '0' + selectedDay.toString();
    } else {
      selectedDayToString = selectedDay.toString();
    }
    return timeslot
        .doc(selectedDayToString)
        // .update({slotNumber: FieldValue.delete()})
        .update({
          "timeSlots": FieldValue.arrayRemove([selectedSlotTime])
        })
        .then(
            (value) => logger.d("selected timeslot: $selectedSlotTime Deleted"))
        .catchError(
            (error) => logger.d("Failed to delete timeslotproperty: $error"));
  }

  static Future<String> uploadImage(
      fileName, fileExtension, base64Image) async {
    // String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';
    String dataUrl = "data:image/$fileExtension;base64," + base64Image;
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('receipts/' + fileName)
          .putString(dataUrl, format: firebase_storage.PutStringFormat.dataUrl);
      logger.d('receipts/$fileName');
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('receipts/$fileName')
          .getDownloadURL();
      logger.d(downloadURL);
    } on FirebaseException catch (e) {
      logger.d("Image not uploaded." + e.toString());
      // e.g, e.code == 'canceled'
    }
    return downloadURL;
  }
}

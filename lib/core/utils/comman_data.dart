import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'dart:ui' as ui;

Future<void> addNotification(String userId, String title, String type,String id,double oldPrice, double newPrice) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .add({
     'title': title,
     'type': type,
     'id':id,
    'timestamp': FieldValue.serverTimestamp(),
    'oldPrice': oldPrice,
    'newPrice': newPrice,
    'isRead': false,
  });
}
Future<void> sendNotificationToAllUsers({String? userId, String? title,String? type,String? id, double? oldPrice, double? newPrice}) async {
 if(type=='order_placed' || type=='order_status' || type=='event_register'){
   await addNotification(
       userId??sharedPref.getString('user_id')??"", title ?? '', type ?? "default", id ?? "", oldPrice ?? 0.0,
       newPrice ?? 0.0);
 }else {
   QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

   for (var userDoc in usersSnapshot.docs) {
     await addNotification(
         userDoc.id, title ?? '', type ?? "default", id ?? "", oldPrice ?? 0.0,
         newPrice ?? 0.0);
   }
 }
}
Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}
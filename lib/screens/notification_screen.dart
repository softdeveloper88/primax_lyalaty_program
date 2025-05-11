import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';

import '../widgets/images.dart';

class NotificationScreen extends StatelessWidget {
  // final String userId = FirebaseAuth.instance.currentUser!.uid;

   NotificationScreen({this.userId,super.key});
   String? userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/Back.png', height: 60, width: 60),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            "Notifications",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _clearAllNotifications,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text("Clear All",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId??sharedPref.getString('user_id')??'')
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications available"));
          }

          final notifications = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> groupedNotifications = {};

          for (var doc in notifications) {
            DateTime date = doc['timestamp'].toDate();
            String formattedDate = _formatDate(date);

            if (!groupedNotifications.containsKey(formattedDate)) {
              groupedNotifications[formattedDate] = [];
            }
            groupedNotifications[formattedDate]!.add(doc);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: groupedNotifications.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                            color: Color(0xff1A2530),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...entry.value.map((notification) => Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) =>
                              _deleteNotification(notification.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: buildNotificationItem(
                            notification['title'],
                            notification['type'],
                            notification['id'],
                            _formatTimeAgo(notification['timestamp'].toDate()),
                            notification['oldPrice'],
                            notification['newPrice'],
                          ),
                        ))
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotificationItem(String title, String type, String id,
      String time, double oldPrice, double newPrice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type == 'new_product'
              ? Container(
                  height: 80,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Color(0xffF0F5FA),
                      borderRadius: BorderRadius.circular(15)),
                  child: Image.asset(Images.image1),
                )
              : Container(
                  // height: 80,
                  // width: 70,
                  decoration: BoxDecoration(
                      color: Color(0xffF0F5FA),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/icons/ic_notification.svg',
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( type.replaceAll('_', " ").capitalizeEachWord(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                Text(title,
                    style: TextStyle(
                        color: Color(0xff1A2530),
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
                SizedBox(height: 8),
                Row(
                  children: [
                    if (oldPrice > 0)
                      Text("PKR$oldPrice",
                          style: TextStyle(
                              color: Color(0xff1A2530),
                              fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    if (newPrice > 0)
                      Text("PKR$newPrice",
                          style: TextStyle(
                              color: Color(0xff707B81),
                              fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Today";
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return "Yesterday";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
  }

  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> _clearAllNotifications() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

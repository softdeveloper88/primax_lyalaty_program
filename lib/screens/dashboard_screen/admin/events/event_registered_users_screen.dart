import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

class EventRegisteredUsersScreen extends StatefulWidget {
  final String eventId;

  EventRegisteredUsersScreen({super.key, required this.eventId});

  @override
  _EventRegisteredUsersScreenState createState() => _EventRegisteredUsersScreenState();
}

class _EventRegisteredUsersScreenState extends State<EventRegisteredUsersScreen> {
  List<String> registeredUserIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredUsers();
  }

  Future<void> _fetchRegisteredUsers() async {
    DocumentSnapshot eventDoc =
    await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
    if (eventDoc.exists) {
      setState(() {
        registeredUserIds = List<String>.from(eventDoc['register_users'] ?? []);
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: CommonBackButton(onPressed: (){
            Navigator.pop(context);
          }),
          title: Text("Registered Users (${registeredUserIds.length})")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : registeredUserIds.isEmpty
          ? Center(child: Text("No users registered for this event."))
          : ListView.builder(
        itemCount: registeredUserIds.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchUserDetails(registeredUserIds[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text("Loading user..."));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListTile(title: Text("User not found"));
              }
              var user = snapshot.data!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(Images.ellipse),
                ),
                title: Text(user['fullName'] ?? "Unknown"),
                subtitle: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email :${user['email'] ?? "No email"}'),
                      Text('Contact :${user['phone'] ?? "No phone"}'),

                    ],
                  ),
                ),

              );
            },
          );
        },
      ),
    );
  }
}

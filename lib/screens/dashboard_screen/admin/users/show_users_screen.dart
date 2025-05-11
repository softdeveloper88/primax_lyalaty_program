import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

class ShowUsersScreen extends StatefulWidget {
  @override
  _ShowUsersScreenState createState() => _ShowUsersScreenState();
}

class _ShowUsersScreenState extends State<ShowUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text("All Users"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found."));
          }

          var users = snapshot.data!.docs;
          users.removeWhere((user)=>user.id=='1');
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(Images.ellipse),
                ),
                title: Text(user['fullName'] ?? "Unknown"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${user['email'] ?? "No email"}'),
                    Text('Contact: ${user['phone'] ?? "No phone"}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

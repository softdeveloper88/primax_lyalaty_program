import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

import 'edit_proflie.dart';

class PersonalInfo extends StatefulWidget {
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch User Data from Firestore**
  void _fetchUserData() async {
    String userId = sharedPref.getString('user_id')??'';

    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        userData = userSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/Back.png',
            height: 60,
            width: 60,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            "Personal Info",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
            bool isTrue = await EditProfile().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
             if(isTrue){
               _fetchUserData();
             }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "Edit",
                  style: TextStyle(
                      color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator()) // Show loading
          : Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 20),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:  userData!['profile']  !=''?FileImage(File(userData!['profile']??'')) as ImageProvider:AssetImage(Images.ellipse),

                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData!['fullName'] ?? 'Alisson Becker',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    Text(
                      userData!['bio'] ?? 'I love to buy inverter',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Profile(
              image: Images.person,
              title: 'Full Name',
              address: userData!['fullName'] ?? 'Alisson Becker',
              email: userData!['email'] ?? '',
              phone: userData!['phone'] ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class Profile extends StatelessWidget {
  String image;
  String title;
  String email;
  String phone;
  String address;

  Profile({super.key, required this.image, required this.title,required this.email,required this.phone, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
          color: Color(0xffF5F6FA), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildProfileRow(image, title, address),
          _buildProfileRow(Images.email, 'Email', email),
          _buildProfileRow(Images.call, 'Phone Number', phone),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 10, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            child: Image.asset(icon, scale: 3),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12)),
              SizedBox(height: 15),
            ],
          ),
        ],
      ),
    );
  }
}

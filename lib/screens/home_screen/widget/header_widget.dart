import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:primax_lyalaty_program/main.dart';

import '../../../widgets/images.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi ${sharedPref.getString('user_name') ?? ''}!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              "Find Your Inverter",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            ZoomDrawer.of(context)?.toggle();
          },
          child: CircleAvatar(
            radius: 25,
            backgroundImage: sharedPref.containsKey('user_id') && sharedPref.getString('profile') != null && sharedPref.getString('profile')!.isNotEmpty
                ? FileImage(File(sharedPref.getString('profile')!))
                : AssetImage(Images.ellipse) as ImageProvider,
          ),
        ),
      ],
    );
  }
}

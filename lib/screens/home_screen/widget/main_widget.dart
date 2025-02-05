import 'package:flutter/material.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/header_widget.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/searchbar_widget.dart';

import '../../../core/utils/comman_widget.dart';

class MainWidget extends StatelessWidget {
   MainWidget({this.mWidget,super.key});
  Widget? mWidget;
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Image.asset('assets/images/img_splash.png',fit: BoxFit.cover,),
          ),
          // Gradient background
          Container(
            height: 160,
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10) ),
              gradient:setGradient()
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const SizedBox(height: 60),

                const HeaderWidget(),
                const SizedBox(height: 20),
                // Search Bar
                const SearchBarWidget(),
                const SizedBox(height: 20),
                // Brand Selector
                Expanded(child: mWidget??SizedBox.shrink()),
              ],
            ),
          ),
        ],
      );

  }
}

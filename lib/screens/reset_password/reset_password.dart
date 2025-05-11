import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/app_colors.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isEmailSelected = true;
  bool isPasswordVisible = false;
  bool isKeepSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter tour Email address to get the password reset link',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            // Row(
            //   children: [
            //     GestureDetector(
            //       onTap: () => setState(() => isEmailSelected = true),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Email',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: isEmailSelected ? Colors.green : Colors.black,
            //               fontWeight: isEmailSelected
            //                   ? FontWeight.bold
            //                   : FontWeight.normal,
            //             ),
            //           ),
            //           if (isEmailSelected)
            //             Container(
            //               margin: const EdgeInsets.only(top: 4),
            //               height: 2,
            //               width: 50,
            //               color: Colors.green,
            //             ),
            //         ],
            //       ),
            //     ),
            //     const SizedBox(width: 30),
            //     GestureDetector(
            //       onTap: () => setState(() => isEmailSelected = false),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Phone Number',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: !isEmailSelected ? Colors.green : Colors.black,
            //               fontWeight: !isEmailSelected
            //                   ? FontWeight.bold
            //                   : FontWeight.normal,
            //             ),
            //           ),
            //           if (!isEmailSelected)
            //             Container(
            //               margin: const EdgeInsets.only(top: 4),
            //               height: 2,
            //               width: 90,
            //               color: Colors.green,
            //             ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 50),
            Text('Enter new Password',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            CustomTextFormField(
              obscureText: !isPasswordVisible,
              // decoration: InputDecoration(
              hintText: 'New Password',
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              // ),
            ),
            const SizedBox(height: 50),
            Text('Re-enter new Password',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            CustomTextFormField(
              obscureText: !isPasswordVisible,
              // decoration: InputDecoration(
              hintText: 'Re-enter Password',
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              // ),
            ),
            const SizedBox(height: 50),
            CustomButton(
              onPressed: () {
                // Handle login
              },
              width: double.maxFinite,
              text:'Reset Password',
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: (){
                LoginScreen(fromSplash: true,).launch(context,pageRouteAnimation: PageRouteAnimation.Slide,);
              },
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Create Account',
                        style: const TextStyle(color: Colors.blue),
                        // Add navigation action here
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
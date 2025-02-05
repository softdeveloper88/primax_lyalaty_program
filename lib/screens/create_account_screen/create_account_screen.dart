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

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
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
              'Create Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '',
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
            const SizedBox(height: 30),
            Text('Name',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            CustomTextFormField(
              // decoration: InputDecoration(
              hintText: 'Name',
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
              // ),
            ),
            const SizedBox(height: 30),
            Text('Email Address',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            CustomTextFormField(
              // decoration: InputDecoration(
              hintText: isEmailSelected ? 'Email Address' : 'Phone Number',
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(8),
              // ),
              // ),
            ),
            const SizedBox(height: 30),
            Text('Password',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            CustomTextFormField(
              obscureText: !isPasswordVisible,
              // decoration: InputDecoration(
              hintText: 'Password',
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
            const SizedBox(height: 30),
            Row(
              children: [
                Checkbox(
                  value: isKeepSignedIn,
                  onChanged: (value) =>
                      setState(() => isKeepSignedIn = value ?? false),
                ),
                Expanded(
                  child: const Text.rich(
                      TextSpan(
                        text: "By Continuing, you agree to out ",
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Terms & Condition',
                            style: const TextStyle(color: Colors.blue),
                            // Add navigation action here
                          ),
                        ],
                      ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: () {
                // Handle login
              },
              width: double.maxFinite,
              text:'Sign up',
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: (){
                LoginScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide,);
               },
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Sign in here',
                        style: const TextStyle(color: Colors.blue),
                        // Add navigation action here
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Expanded(child: Divider(color:Colors.blueGrey,indent: 2,endIndent: 10,)),
                Text('Or'),
                Expanded(child: Divider(color: Colors.blueGrey,indent: 10,endIndent: 2,)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Google login
                    },
                    icon: SvgPicture.asset('assets/icons/ic_google.svg'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Apple login
                    },
                    icon: SvgPicture.asset('assets/icons/ic_apple.svg'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Facebook login
                    },
                    icon: SvgPicture.asset('assets/icons/ic_facebook.svg'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
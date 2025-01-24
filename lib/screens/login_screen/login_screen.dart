import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/app_colors.dart';
import 'package:primax_lyalaty_program/screens/create_account_screen/create_account_screen.dart';
import 'package:primax_lyalaty_program/screens/forgot_passowrd/forgot_password.dart';
import 'package:primax_lyalaty_program/screens/reset_password/reset_password.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

import '../dashboard_screen/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome Back to the app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isEmailSelected = true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: isEmailSelected ? Colors.green : Colors.black,
                          fontWeight: isEmailSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isEmailSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2,
                          width: 50,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () => setState(() => isEmailSelected = false),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          color: !isEmailSelected ? Colors.green : Colors.black,
                          fontWeight: !isEmailSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (!isEmailSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2,
                          width: 90,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
              ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Password',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                TextButton(
                  onPressed: () {
                    ForgotPassword().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);

                    // Handle forgot password
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
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
                const Text('Keep me signed in'),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: () {
                DashboardScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide,);

                // Handle login
              },
              width: double.maxFinite,
              text:'Login',
            ),
            const SizedBox(height: 30),
            Center(
              child: InkWell(
                onTap: (){
                  CreateAccountScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                },
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
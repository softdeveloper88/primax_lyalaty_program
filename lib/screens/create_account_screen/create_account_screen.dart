import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/app_colors.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/utils/progress_dialog_utils.dart';
import '../dashboard_screen/dashboard_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool isEmailSelected = true;
  bool isPasswordVisible = true;
  bool isTermAccepted = false;

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      toast('Field cannot be empty');
      return;
    }
    if (!isTermAccepted) {
      toast('Please accept terms and condition first');
      return;
    }

    setState(() {
      ProgressDialogUtils.showProgressDialog();

      isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Optionally update user profile with a name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': '',
        'bio': '',
        'isSocial': false,
        'profile': '',
      });
      toast('Account created successfully');
      ProgressDialogUtils.hideProgressDialog();

      LoginScreen(
        fromSplash: true,
      ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase sign-up errors
      ProgressDialogUtils.hideProgressDialog();

      toast(e.message ?? 'An error occurred');
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();

      toast('An unexpected error occurred');
    } finally {
      ProgressDialogUtils.hideProgressDialog();
      setState(() {
        isLoading = false;
      });
    }
  }

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
            const SizedBox(height: 30),
            Text('Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _nameController,
              hintText: 'Name',
            ),
            const SizedBox(height: 30),
            Text('Email Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _emailController,
              hintText: isEmailSelected ? 'Email Address' : 'Phone Number',
            ),
            const SizedBox(height: 30),
            Text('Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _passwordController,
              obscureText: !isPasswordVisible,
              hintText: 'Password',
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Checkbox(
                  value: isTermAccepted,
                  onChanged: (value) =>
                      setState(() => isTermAccepted = value ?? false),
                ),
                Expanded(
                  child: const Text.rich(
                    TextSpan(
                      text: "By Continuing, you agree to our ",
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Terms & Condition',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: _signUp,
              // Disable button when loading
              width: double.maxFinite,
              text: isLoading ? 'Signing Up...' : 'Sign up',
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                LoginScreen(
                  fromSplash: true,
                ).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              },
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Sign in here',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: const [
            //     Expanded(
            //         child: Divider(
            //       color: Colors.blueGrey,
            //       indent: 2,
            //       endIndent: 10,
            //     )),
            //     Text('Or'),
            //     Expanded(
            //         child: Divider(
            //       color: Colors.blueGrey,
            //       indent: 10,
            //       endIndent: 2,
            //     )),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // Row(
            //   spacing: 10,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       decoration: BoxDecoration(
            //           color: AppColors.background,
            //           borderRadius: BorderRadius.circular(40)),
            //       child: IconButton(
            //         onPressed: () {
            //           onPressedGoogleLogin(context);
            //           // Google login
            //         },
            //         icon: SvgPicture.asset('assets/icons/ic_google.svg'),
            //       ),
            //     ),
            //     Container(
            //       decoration: BoxDecoration(
            //           color: AppColors.background,
            //           borderRadius: BorderRadius.circular(40)),
            //       child: IconButton(
            //         onPressed: () {
            //           signInWithApple(context);
            //           // Apple login
            //         },
            //         icon: SvgPicture.asset('assets/icons/ic_apple.svg'),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // onPressedGoogleLogin(context) async {
  //   try {
  //     // GoogleSignIn().signOut();
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     print(googleUser.toString());
  //     GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleUser!.authentication;
  //     // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //     //   email: emailController.text.trim(),
  //     //   password: passwordController.text.trim(),
  //     // );
  //
  //     // User? user = userCredential.user;
  //
  //     if (googleUser.id != '') {
  //       await sharedPref.setBool('isKeepSignedIn', true);
  //       await sharedPref.setString('user_email', googleUser.email ?? "");
  //       await sharedPref.setString('user_id', googleUser.id);
  //       await sharedPref.setString('user_name', googleUser.displayName ?? "");
  //       await sharedPref.setString('profile', googleUser.photoUrl ?? '');
  //       await sharedPref.setBool('isSocial', true);
  //       // await sharedPref.setString('user_password', passwordController.text ?? '');
  //       await FirebaseFirestore.instance.collection('users').doc(googleUser.id).set({
  //         'fullName': googleUser.displayName ?? "",
  //         'email':googleUser.email ?? "",
  //         'phone': '',
  //         'bio': '',
  //         'isSocial': true,
  //         'profile':googleUser.photoUrl ?? '',
  //       });
  //       toast('Login Successful');
  //
  //       ProgressDialogUtils.hideProgressDialog();
  //       DashboardScreen().launch(context, isNewTask: true);
  //     }
  //     // await FirebaseMessaging.instance.getToken().then((token) async {
  //     //   print('token$googleUser');
  //     // loginBloc.add(SocialLoginButtonPressed(
  //     //   email: googleUser.email,
  //     //   firstName: googleUser.displayName!.split(' ').first,
  //     //   lastName: googleUser.displayName!.split(' ').last,
  //     //   isSocialLogin: true,
  //     //   provider: 'google',
  //     //   token: googleUser.id,
  //     //   deviceToken: token ?? '',
  //     // ));
  //     GoogleSignIn().disconnect();
  //   } on Exception catch (e) {
  //     toast('Something went wrong please try again');
  //     print('error is ....... $e');
  //     // TODO
  //   }
  // }
  //
  // String generateNonce([int length = 32]) {
  //   const charset =
  //       '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  //   final random = Random.secure();
  //   return List.generate(length, (_) => charset[random.nextInt(charset.length)])
  //       .join();
  // }
  //
  // /// Returns the sha256 hash of [input] in hex notation.
  // String sha256ofString(String input) {
  //   final bytes = utf8.encode(input);
  //   final digest = sha256.convert(bytes);
  //   return digest.toString();
  // }
  //
  // signInWithApple(context) async {
  //   //   print('token$token');
  //   final rawNonce = generateNonce();
  //   final nonce = sha256ofString(rawNonce);
  //
  //   // Request credential for the currently signed in Apple account.
  //   final appleCredential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //     nonce: nonce,
  //   );
  //
  //   // Create an `OAuthCredential` from the credential returned by Apple.
  //   final oauthCredential = OAuthProvider('apple.com').credential(
  //     idToken: appleCredential.identityToken,
  //     rawNonce: rawNonce,
  //   );
  //   String? token = "";
  //   if (Platform.isAndroid) {
  //     token = await FirebaseMessaging.instance.getToken();
  //   } else {
  //     token = await FirebaseMessaging.instance.getToken();
  //   }
  //   var response =
  //       await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  //   if (response.user?.uid != '') {
  //     await sharedPref.setBool('isKeepSignedIn', true);
  //     await sharedPref.setString('user_email', response.user?.email ?? "");
  //     await sharedPref.setString('user_id', response.user?.uid ?? '');
  //     await sharedPref.setString('user_name', response.user?.displayName ?? "");
  //     await sharedPref.setString('profile', response.user?.photoURL ?? '');
  //     await sharedPref.setBool('isSocial', true);
  //
  //     await FirebaseFirestore.instance.collection('users').doc(response.user?.uid ?? '').set({
  //       'fullName': response.user?.displayName ?? "",
  //       'email': response.user?.email ?? "",
  //       'phone': '',
  //       'bio': '',
  //       'isSocial': true,
  //       'profile': response.user?.photoURL ?? '',
  //     });
  //     toast('Login Successful');
  //
  //
  //     DashboardScreen().launch(context, isNewTask: true);
  //   }
  //   print("${appleCredential.givenName} ${appleCredential.familyName}");
  //
  //   GoogleSignIn().disconnect();
  // }
}

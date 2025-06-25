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
import 'package:primax_lyalaty_program/core/utils/progress_dialog_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/create_account_screen/create_account_screen.dart';
import 'package:primax_lyalaty_program/screens/forgot_passowrd/forgot_password.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../dashboard_screen/admin/admin_dashboard.dart';
import '../dashboard_screen/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
   LoginScreen({this.fromSplash=false,Key? key}) : super(key: key);
  bool fromSplash;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isEmailSelected = true;
  bool isPasswordVisible = false;
  bool isKeepSignedIn = false;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!value.validateEmail()) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> loginUser(context) async {
    if (!_formKey.currentState!.validate()) return; // Stop if validation fails

    setState(() => isLoading = true);
    ProgressDialogUtils.showProgressDialog();
    if (emailController.text == 'admin@gmail.com' &&
        passwordController.text == 'admin124') {
      ProgressDialogUtils.hideProgressDialog();

      AdminDashboard().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        if (isKeepSignedIn) {
          await sharedPref.setBool('isKeepSignedIn', isKeepSignedIn);
        }
        await sharedPref.setString('user_email', user.email!);
        await sharedPref.setString('user_id', user.uid);
        await sharedPref.setString('user_name', user.displayName ?? '');
        await sharedPref.setString('profile', user.photoURL ?? '');
        await sharedPref.setString('user_password', passwordController.text ?? '');
        await sharedPref.setBool('isSocial', false);

        toast('Login Successful');

        ProgressDialogUtils.hideProgressDialog();
        if(widget.fromSplash) {

          DashboardScreen().launch(context, isNewTask: true);

        }else{

          Navigator.pop(context);

        }
      }
    } on FirebaseAuthException catch (e) {
      ProgressDialogUtils.hideProgressDialog();

      toast(e.message ?? 'Login failed');
    } finally {
      ProgressDialogUtils.hideProgressDialog();

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
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
              Text(
                'Email Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextFormField(
                validator: validateEmail, // validator: (v){
                //   // return ValidationResult;
                // },
                controller: emailController, // decoration: InputDecoration(
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
                  Text(
                    'Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      ForgotPassword().launch(context,
                          pageRouteAnimation: PageRouteAnimation.Slide);

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
                validator: validatePassword,
                controller: passwordController,
                obscureText: !isPasswordVisible,
                // decoration: InputDecoration(
                hintText: 'Password',
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
                suffix: IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
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
                onPressed: () => loginUser(context),
                width: double.maxFinite,
                text: 'Login',
              ),
              const SizedBox(height: 30),
              Center(
                child: InkWell(
                  onTap: () {
                    CreateAccountScreen().launch(context,
                        pageRouteAnimation: PageRouteAnimation.Slide);
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
              // const SizedBox(height: 30),
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
              //     // Container(
              //     //   decoration: BoxDecoration(
              //     //       color: AppColors.background,
              //     //       borderRadius: BorderRadius.circular(40)),
              //     //   child: IconButton(
              //     //     onPressed: () {
              //     //       // Facebook login
              //     //     },
              //     //     icon: SvgPicture.asset('assets/icons/ic_facebook.svg'),
              //     //   ),
              //     // ),
              //   ],
              // ),
            ],
          ),
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
  //     await googleUser!.authentication;
  //     // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //     //   email: emailController.text.trim(),
  //     //   password: passwordController.text.trim(),
  //     // );
  //
  //     // User? user = userCredential.user;
  //
  //     if (googleUser.id != '') {
  //
  //         await sharedPref.setBool('isKeepSignedIn', true);
  //       await sharedPref.setString('user_email',  googleUser.email??"");
  //       await sharedPref.setString('user_id',  googleUser.id);
  //       await sharedPref.setString('user_name', googleUser.displayName??"");
  //       await sharedPref.setString('profile',  googleUser.photoUrl??'');
  //         await sharedPref.setBool('isSocial',  true);
  //
  //         // await sharedPref.setString('user_password', passwordController.text ?? '');
  //         await FirebaseFirestore.instance.collection('users').doc(googleUser.id).set({
  //           'fullName': googleUser.displayName ?? "",
  //           'email':googleUser.email ?? "",
  //           'phone': '',
  //           'bio': '',
  //            'isSocial':true,
  //           'profile':googleUser.photoUrl ?? '',
  //         });
  //       toast('Login Successful');
  //
  //       ProgressDialogUtils.hideProgressDialog();
  //       if(widget.fromSplash) {
  //         DashboardScreen().launch(context, isNewTask: true);
  //
  //       }else{
  //
  //         Navigator.pop(context);
  //
  //       }
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
  //
  //
  //   } on Exception catch (e) {
  //     toast('Something went wrong please try again');
  //     print('error is ....... $e');
  //     // TODO
  //   }
  // }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

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
  //   var response = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  //   if (response.user?.uid != '') {
  //
  //     await sharedPref.setBool('isKeepSignedIn', true);
  //     await sharedPref.setString('user_email',  response.user?.email??"");
  //     await sharedPref.setString('user_id',  response.user?.uid??'');
  //     await sharedPref.setString('user_name', response.user?.displayName??"");
  //     await sharedPref.setString('profile',  response.user?.photoURL??'');
  //     await sharedPref.setBool('isSocial',  true);
  //     // await sharedPref.setString('user_password', passwordController.text ?? '');
  //     await FirebaseFirestore.instance.collection('users').doc(response.user?.uid).set({
  //       'fullName': response.user?.displayName ?? "",
  //       'email':response.user?.email ?? "",
  //       'phone': '',
  //       'bio': '',
  //       'isSocial':true,
  //       'profile':response.user?.photoURL ?? '',
  //     });
  //     toast('Login Successful');
  //
  //     ProgressDialogUtils.hideProgressDialog();
  //     if(widget.fromSplash) {
  //       DashboardScreen().launch(context, isNewTask: true);
  //
  //     }else{
  //
  //       Navigator.pop(context);
  //
  //     }
  //   }
  //   print("${appleCredential.givenName} ${appleCredential.familyName}");
  //
  //   GoogleSignIn().disconnect();
  // }
}

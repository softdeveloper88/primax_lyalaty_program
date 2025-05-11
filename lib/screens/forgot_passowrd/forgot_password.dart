import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/app_colors.dart';
import 'package:primax_lyalaty_program/screens/create_account_screen/create_account_screen.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isEmailSelected = true;
  bool isPasswordVisible = false;
  bool isKeepSignedIn = false;
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return; // Stop if validation fails

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      toast('Password reset email sent! Check your inbox.');
      finish(context); // Close Forgot Password screen
    } on FirebaseAuthException catch (e) {
      toast(e.message ?? 'Failed to send reset email');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!value.validateEmail()) {
      return 'Enter a valid email';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child:Form(
          key: _formKey,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Forgot Password',
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
              const SizedBox(height: 50),
              Text('Email Address',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
              const SizedBox(height: 5),
              CustomTextFormField(
                // decoration: InputDecoration(
                hintText: 'Email Address' ,
                controller: emailController,
                validator: validateEmail,
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
                // ),
              ),
              const SizedBox(height: 50),
              CustomButton(
                onPressed: resetPassword,
                width: double.maxFinite,
                text: isLoading ? 'Sending...' : 'Reset Password',
              ),
              const SizedBox(height: 50),
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
            ],
          ),
        ),
      ),
    );
  }
}
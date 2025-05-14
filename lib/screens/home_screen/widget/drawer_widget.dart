import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/favorite_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/about_us_screen.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/screens/my_cart_screen.dart';
import 'package:primax_lyalaty_program/screens/notification_screen.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

import '../../orders_screen/orders_screen.dart';
import '../../personal_info.dart';
import '../contact_us_screen.dart';
import '../web_view_screen.dart';

class DrawerWidget extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const DrawerWidget({
    Key? key,
    required this.userName,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Profile Header
          GestureDetector(
            onTap: () {
              ZoomDrawer.of(context)?.close();
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: sharedPref.getString('user_id') != null
                        ? (profileImageUrl != ""
                            ? FileImage(File(profileImageUrl))
                            : AssetImage(Images.ellipse)) as ImageProvider
                        : AssetImage(Images.ellipse),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sharedPref.getString('user_id') != null
                              ? userName
                              : "Guest User",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (sharedPref.getString('user_id') == null)
                          Text(
                            "Sign in to access all features",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer Items
          Expanded(
            child: GestureDetector(
              onTap: () {
                ZoomDrawer.of(context)?.close();
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_user.svg',
                    label: 'Profile',
                    onTap: () {
                      if (sharedPref.getString('user_id') != null) {
                        PersonalInfo().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      } else {
                        LoginScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      }
                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_home.svg',
                    label: 'Home Page',
                    onTap: () {
                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_shop.svg',
                    label: 'My Cart',
                    onTap: () {
                      if (sharedPref.getString('user_id') != null) {
                        MyCartScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      } else {
                        LoginScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      }
                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_favorite.svg',
                    label: 'Favorite',
                    onTap: () {
                      if (sharedPref.getString('user_id') != null) {
                        FavoriteScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      } else {
                        LoginScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      }
                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_order.svg',
                    label: 'Orders',
                    onTap: () {
                      if (sharedPref.getString('user_id') != null) {
                        OrdersScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      } else {
                        LoginScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      }
                      ZoomDrawer.of(context)?.close();
                    },
                  ),

                  // _buildDrawerItemIcon(
                  //   context,
                  //   icon: LucideIcons.info,
                  //   label: 'About Us',
                  //   onTap: () {
                  //     // Replace with your About screen navigation
                  //     AboutUsScreen(
                  //       url: 'https://primaxsolarenergy.com/?page_id=61#',
                  //       title: 'About Us',
                  //     ).launch(context,
                  //     pageRouteAnimation: PageRouteAnimation.Slide);
                  //     ZoomDrawer.of(context)?.close();
                  //   },
                  // ),
                  _buildDrawerItemIcon(
                    context,
                    icon: LucideIcons.contact,
                    label: 'Complaint Registration ',
                    onTap: () {
                      // Replace with your Contact Us screen navigation
                      WebViewScreen(
                        url: 'https://primaxsolarenergy.com/?page_id=1610',
                        title: 'Contact us',
                      ).launch(context,
                          pageRouteAnimation: PageRouteAnimation.Slide);

                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: 'assets/icons/ic_notification.svg',
                    label: 'Notifications',
                    onTap: () {
                      if (sharedPref.getString('user_id') != null) {
                        NotificationScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      } else {
                        LoginScreen().launch(
                          context,
                          pageRouteAnimation: PageRouteAnimation.Slide,
                        );
                      }
                      ZoomDrawer.of(context)?.close();
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(thickness: 2, color: Colors.black, indent: 20),
          // Sign Out Button
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/ic_signout.svg',
              color: Colors.red[400],
            ),
            title: Text(
              sharedPref.getString('user_id') != null ? 'Sign Out' : "Login",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              if (sharedPref.getString('user_id') != null) {
                logoutUser(context);
              } else {
                LoginScreen().launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              }
              // Handle Sign Out
            },
          ),
          if (sharedPref.getString('user_id') != null)
            ListTile(
              leading: Icon(LineIcons.remove_user, color: Colors.red[400]),
              title: Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                deleteAccount(context);

                // Handle Sign Out
              },
            ),
        ],
      ),
    );
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase Logout
      sharedPref.remove('user_id');
      sharedPref.remove('user_email');
      sharedPref.remove('user_name');
      sharedPref.remove('user_password');
      sharedPref.remove('isKeepSignedIn');
      toast('Logged out successfully');

      // Navigate back to LoginScreen
      LoginScreen(
        fromSplash: true,
      ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
    } catch (e) {
      toast('Logout failed: ${e.toString()}');
    }
  }

  deleteAccount(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete your Account?'),
          content: const Text(
            '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.

Since this is a security-sensitive operation, you eventually are asked to login before your account can be deleted.''',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                // color: Colors.red,
              ),
              onPressed: () async {
                if (sharedPref.getBool('isSocial') ?? false) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Get Google credentials
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    final GoogleSignInAccount? googleUser =
                        await googleSignIn.signIn();

                    if (googleUser == null) {
                      print("Google sign-in aborted");
                      return;
                    }

                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;

                    final AuthCredential credential =
                        GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );

                    // Reauthenticate user
                    await user.reauthenticateWithCredential(credential);

                    // Delete user from Firebase Auth
                    await user.delete();
                    print("Account deleted successfully from Firebase");

                    // Sign out user from Google and Firebase
                    await googleSignIn.signOut();
                    await FirebaseAuth.instance.signOut();
                  } else {
                    print("No user is signed in");
                  }
                } else {
                  User? user = FirebaseAuth.instance.currentUser;
                  // await FirebaseFirestore.instance.collection("users").doc(sharedPref.getString('user_id')).delete();
                  user?.delete();
                }
                LoginScreen().launch(
                  context,
                  isNewTask: true,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
                print("User account deleted successfully");

                // Call the delete account function
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: SvgPicture.asset(icon, color: Colors.black),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }
}
Widget _buildDrawerItemIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }

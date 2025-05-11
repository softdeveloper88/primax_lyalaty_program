import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primax_lyalaty_program/core/utils/progress_dialog_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import '../widgets/images.dart';
import 'my_address.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? profileImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch User Data from Firestore**
  void _fetchUserData() async {
    setState(() => isLoading = true);
    String userId = sharedPref.getString('user_id')??'';

    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      _fullNameController.text = userData['fullName'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _bioController.text = userData['bio'] ?? '';
      _selectedFile = File(userData['profile']);
      await sharedPref.setString('profile',_selectedFile?.path??'');
      setState(() => isLoading = false);
    }
  }

  /// **Update User Data in Firestore**
  void _updateProfile() async {
    String userId =sharedPref.getString('user_id')??'';
    ProgressDialogUtils.showProgressDialog();
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'profile': _selectedFile?.path??'',
    });
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(_selectedFile?.path??'');
    await sharedPref.setString('profile',_selectedFile?.path??'');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
    ProgressDialogUtils.hideProgressDialog();

    Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/Back.png', height: 60, width: 60),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(),

            _buildTextField(label: 'Full Name', controller: _fullNameController),
            _buildTextField(label: 'Email', controller: _emailController),
            _buildTextField(label: 'Phone Number', controller: _phoneController),
            _buildTextField(label: 'Bio', controller: _bioController),
            Spacer(),
            CustomButton(
              onPressed: _updateProfile,
              text:  "Save",
            ),
          ],
        ),
      ),
    );
  }
   File? _selectedFile;

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  File? file = await _pickFile(ImageSource.gallery);
                  if (file != null) {
                    setState(() {
                      print('ddd${file.path}');
                      _selectedFile = file;

                     });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () async {
                  Navigator.pop(context);
                  File? file = await _pickFile(ImageSource.camera);
                  if (file != null) {
                    setState(() {
                      print('ddd${file.path}');
                      _selectedFile = file;
                        });
                  }
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.insert_drive_file),
              //   title: const Text('Select a document'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     File? file = await _pickFile(ImageSource.gallery);
              //     if (file != null) {
              //       setState(() {
              //         _selectedFile = file;
              //       });
              //     }
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _pickFile(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
  /// **Profile Image Section**
  Widget _buildProfileImage() {
    return Center(
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _selectedFile !=null ? FileImage(_selectedFile??File('')) as ImageProvider:AssetImage('assets/profile.png'),
            ),
            Positioned(
              left: 70,
              top: 90,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.mode_edit_outline_outlined, color: Colors.white, size: 25),
                  onPressed: () async {
                    const permission = Permission.storage;
                    const permission1 = Permission.photos;
                    var status = await permission.status;
                    print(status);
                    if (await permission1.isGranted) {
                      _showFileOptions();
                      // _selectFiles(context);
                    } else if (await permission1.isDenied) {
                      final result = await permission1.request();
                      if (status.isGranted) {
                        _showFileOptions();
                        // _selectFiles(context);
                        print("isGranted");
                      } else if (result.isGranted) {
                        _showFileOptions();
                        // _selectFiles(context);
                        print("isGranted");
                      } else if (result.isDenied) {
                        final result = await permission.request();
                        print("isDenied");
                      } else if (result.isPermanentlyDenied) {
                        print("isPermanentlyDenied");
                        // _permissionDialog(context);
                      }
                    } else if (await permission.isPermanentlyDenied) {
                      print("isPermanentlyDenied");
                      // _permissionDialog(context);
                    }
                    // TODO: Implement image picker to update profile image
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Input Field**
  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xff32343E), fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffF0F5FA),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Color(0xff8F959E)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

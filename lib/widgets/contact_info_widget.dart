import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:primax_lyalaty_program/main.dart';

class ContactInfoWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(String) onEmailUpdate; // Callback for email update
  final Function(String) onPhoneUpdate; // Callback for phone update

  ContactInfoWidget({
    required this.userData,
    required this.onEmailUpdate,
    required this.onPhoneUpdate,
  });

  @override
  _ContactInfoWidgetState createState() => _ContactInfoWidgetState();
}

class _ContactInfoWidgetState extends State<ContactInfoWidget> {
  bool isEditingEmail = false;
  bool isEditingPhone = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
  }

  /// **Update Email in Firestore & UI**
  void _updateEmail() async {
    String newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) return;

    String userId = sharedPref.getString('user_id')??'';
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'email': newEmail,
    });

    widget.onEmailUpdate(newEmail); // Send updated email to parent
    setState(() => isEditingEmail = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email updated successfully!")),
    );
  }

  /// **Update Phone in Firestore & UI**
  void _updatePhone() async {
    String newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty) return;

    String userId = sharedPref.getString('user_id')??'';
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'phone': newPhone,
    });

    widget.onPhoneUpdate(newPhone); // Send updated phone to parent
    setState(() => isEditingPhone = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Phone number updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),

          // Email Section
          ListTile(
            leading: SvgPicture.asset('assets/icons/ic_email.svg'),
            title: isEditingEmail
                ? _buildEditableTextField(_emailController, _updateEmail)
                : Text(widget.userData['email'] ?? 'Add email'),
            subtitle: Text('Email'),
            trailing: GestureDetector(
              onTap: () => setState(() => isEditingEmail = !isEditingEmail),
              child: SvgPicture.asset('assets/icons/ic_edit.svg'),
            ),
          ),

          // Phone Section
          ListTile(
            leading: SvgPicture.asset('assets/icons/ic_phone.svg'),
            title: isEditingPhone
                ? _buildEditableTextField(_phoneController, _updatePhone)
                : Text(widget.userData['phone'] ?? 'Add phone number'),
            subtitle: Text('Phone'),
            trailing: GestureDetector(
              onTap: () => setState(() => isEditingPhone = !isEditingPhone),
              child: SvgPicture.asset('assets/icons/ic_edit.svg'),
            ),
          ),
        ],
      ),
    );
  }

  /// **Reusable Editable Text Field**
  Widget _buildEditableTextField(TextEditingController controller, VoidCallback onSave) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: onSave, // Call respective update function
        ),
      ],
    );
  }
}

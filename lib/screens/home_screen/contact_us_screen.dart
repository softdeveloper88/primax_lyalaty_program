import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactUsScreen extends StatefulWidget {
  final String appName;
  final String appEmail;

  const ContactUsScreen({
    Key? key,
    this.appName = "Primax",
    this.appEmail = "Support@primaxsolarenergy.com",
  }) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;
  String? _errorMessage;
  bool _formSubmitted = false;

  // App color scheme
  final Color seedColor = Color(0xFF1EA3D0);
  final Color primaryColor = Color(0xFF4AB255);
  final Color onPrimaryColor = Colors.white;
  final Color secondaryColor = Color(0xFF1EA3D0);
  final Color onSecondaryColor = Color(0xFF33384B);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSending = false;
      });
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: widget.appEmail,
      query: _encodeQueryParameters({
        'subject': '[${widget.appName} Feedback] ${_subjectController.text}',
        'body': 'Name: ${_nameController.text}\nEmail: ${_emailController.text}\n\n${_messageController.text}',
      }),
    );

    try {
      final canLaunch = await canLaunchUrl(emailLaunchUri);
      if (!canLaunch) {
        throw 'Could not launch email client';
      }

      await launchUrl(emailLaunchUri);

      setState(() {
        _formSubmitted = true;
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to open email client. Please try again later.';
        _isSending = false;
      });
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(
            color: onPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: onPrimaryColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _formSubmitted
          ? _buildSuccessContent()
          : _buildContactForm(),
    );
  }

  Widget _buildSuccessContent() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your feedback has been submitted successfully. We appreciate your input!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: onSecondaryColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _formSubmitted = false;
                    _nameController.clear();
                    _emailController.clear();
                    _subjectController.clear();
                    _messageController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Submit Another Feedback',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4AB255).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logo and title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            size: 40,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Get in Touch',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We value your feedback! Fill out the form below and we\'ll get back to you as soon as possible.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onSecondaryColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form fields
                  _buildInputField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Enter your name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _subjectController,
                    label: 'Subject',
                    hint: 'Enter subject',
                    icon: Icons.subject,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _messageController,
                    label: 'Message',
                    hint: 'Enter your message',
                    icon: Icons.message_outlined,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),

                  // Error message if any
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: onPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSending
                          ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: onPrimaryColor,
                          strokeWidth: 2,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: onPrimaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'SEND FEEDBACK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: onPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Copy email option
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact us directly:',
                          style: TextStyle(
                            fontSize: 14,
                            color: onSecondaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.appEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: widget.appEmail));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Email address copied to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: secondaryColor,
                                  ),
                                );
                              },
                              icon: Icon(Icons.copy, size: 16, color: secondaryColor),
                              label: Text(
                                'Copy',
                                style: TextStyle(color: secondaryColor),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: Size(0, 0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: onSecondaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: onSecondaryColor.withOpacity(0.4)),
            prefixIcon: Icon(icon, color: secondaryColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: secondaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }
}
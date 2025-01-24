import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final double borderRadius;
  final Color? startColor;
  final Color? endColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = 200,
    this.height = 50,
    this.borderRadius = 25,
    this.startColor,
    this.endColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              startColor ?? const Color(0xFF00C853), // Default green
              endColor ?? const Color(0xFF00B0FF), // Default blue
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// USAGE EXAMPLE:
// Add this button in any screen by calling CustomButton.
// Example:
// CustomButton(
//   text: 'Click Me',
//   onPressed: () {
//     // Handle button press
//   },
//   isLoading: false,
// )

import 'package:flutter/material.dart';

class CommonBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CommonBackButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
            ),
          ],
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 16,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

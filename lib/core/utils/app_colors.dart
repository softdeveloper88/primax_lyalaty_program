import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007BFF); // Example primary color
  static const Color primaryLight = Color(0xFF5AB9FF);
  static const Color primaryDark = Color(0xFF0056B3);

  // Secondary Colors
  static const Color secondary = Color(0xFFFFC107);
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFFFA000);
  // Background Colors
  static const Color background = Color(0xFFE9E9EA);
  static const Color backgroundScreenColor = Color(0xFFF2F7FF);
  static const Color backgroundDark = Color(0xFF303030);
  static const Color backgroundCustomLightGray = Color(0xFF2366B5);
  static const Color backgroundCustomBlueLight = Color(0xFFD9E3F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF6200EE);
  static const Color buttonSecondary = Color(0xFF5ADCC6);
  static const Color buttonCustomGray = Color(0xFFDBDFEB);
  static const Color buttonCustomRed = Color(0xFFE06161);

  // Icon Colors
  static const Color icon = Color(0xFF757575);
  static const Color iconActive = Color(0xFF212121);

  // Error Colors
  static const Color error = Color(0xFFB00020);

  // Custom Colors
  static const Color customYellow = Color(0xFFFFD319);
  static const Color customGreen = Color(0xFF32776C);

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

import 'package:flutter/material.dart';

class ShopStyles {
  // Colors
  static const Color primaryBlue = Color(0xFF0066cc);
  static const Color navBackground = Color(0xFF1a1a1a);
  static const Color mobileMenuBg = Color(0xFF2a2a2a);
  static const Color textMain = Colors.white;
  static const Color textSecondary = Color(0xFFcccccc);
  static const Color textMuted = Color(0xFF999999);

  // Text Styles
  static const TextStyle navLink = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // Input Decoration (Controls all TextFields)
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: primaryBlue),
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
  );
}
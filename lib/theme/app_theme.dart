import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF0A1628);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGold = Color(0xFFD4A843);
  static const Color cardDark = Color(0xFF1E293B);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentBlue,
      cardColor: cardDark,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentGold,
        surface: cardDark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: accentBlue,
        unselectedItemColor: Colors.white70.withValues(alpha: 0.5),
      ),
    );
  }
}

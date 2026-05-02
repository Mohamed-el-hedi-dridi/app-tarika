import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs islamiques
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF2E7D32);
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF5E6A3);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color parchment = Color(0xFFFAF0DC);
  static const Color borderGold = Color(0xFFB8960C);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: gold,
        surface: cream,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextStyle arabicTitle({double size = 22, Color color = darkBrown}) {
    return GoogleFonts.amiri(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color,
      height: 1.8,
    );
  }

  static TextStyle arabicBody({double size = 18, Color color = darkBrown}) {
    return GoogleFonts.amiri(
      fontSize: size,
      color: color,
      height: 2.0,
    );
  }

  static TextStyle arabicVerse({double size = 20, Color color = darkBrown}) {
    return GoogleFonts.scheherazadeNew(
      fontSize: size,
      color: color,
      height: 2.2,
    );
  }

  /// Police Warsh (WarshKFGQPC) pour les versets coraniques dans les أوراد
  static TextStyle warshVerse({double size = 20, Color color = darkBrown}) {
    return TextStyle(
      fontFamily: 'WarshKFGQPC',
      fontSize: size,
      color: color,
      height: 2.2,
    );
  }
}

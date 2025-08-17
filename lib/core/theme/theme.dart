import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primarySeed = Color(0xFF5971E8);
  static const Color background = Color(0xFFE6F1FC); 
  static const Color button = Color(0xFF6E757C);   
  static const Color white = Colors.white;

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.rubikTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    ),
  );

}
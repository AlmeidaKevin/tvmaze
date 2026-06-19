import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const orange    = Color(0xFFF5A623);
  static const orangeDim = Color(0xFFB87A1A);
  static const bg        = Color(0xFF0A0A0F);
  static const surface   = Color(0xFF16161F);
  static const card      = Color(0xFF1C1C28);
  static const border    = Color(0xFF2A2A3D);
  static const muted     = Color(0xFF9090B0);
  static const green     = Color(0xFF00C896);
  static const purple    = Color(0xFF6C5CE7);
  static const blue      = Color(0xFF74B9FF);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: orange,
          surface: surface,
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: orange, width: 2),
          ),
          labelStyle: const TextStyle(color: muted),
          hintStyle: const TextStyle(color: muted, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: orange,
          foregroundColor: Colors.black,
          elevation: 4,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: card,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: border),
          ),
          behavior: SnackBarBehavior.floating,
          insetPadding: const EdgeInsets.all(12),
        ),
        dividerTheme: const DividerThemeData(color: border, space: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: orange,
          unselectedItemColor: muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

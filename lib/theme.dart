import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = const Color.fromARGB(255, 9, 84, 182);
  static Color primaryAccent = const Color.fromARGB(255, 18, 53, 99);
  static Color secondaryColor = const Color.fromRGBO(45, 45, 45, 1);
  static Color secondaryAccent = const Color.fromRGBO(35, 35, 35, 1);
  static Color titleColor = const Color.fromRGBO(200, 200, 200, 1);
  static Color textColor = const Color.fromRGBO(150, 150, 150, 1);
  static Color successColor = const Color.fromRGBO(9, 149, 110, 1);
  static Color errorColor = const Color.fromRGBO(149, 9, 9, 1);
  static Color highlightColor = const Color.fromRGBO(212, 172, 13, 1);
  static Color disabledColor = const Color.fromRGBO(100, 100, 100, 1);
  static Color transparent = Colors.transparent;
}

ThemeData primaryTheme = ThemeData(
  // Seed
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
  ),

  // Scaffold
  scaffoldBackgroundColor: AppColors.secondaryAccent,

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: AppColors.textColor,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
  ),

  // Text
  textTheme: const TextTheme().copyWith(
    bodyMedium: TextStyle(
      color: AppColors.textColor,
      fontSize: 16,
      letterSpacing: 1,
    ),
    bodySmall: TextStyle(
      color: AppColors.textColor,
      fontSize: 14,
      letterSpacing: 1,
    ),
    headlineMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 16,
      letterSpacing: 1,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.titleColor,
      fontSize: 18,
      letterSpacing: 2,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Card
  cardTheme: CardTheme(
    color: AppColors.secondaryColor.withOpacity(0.5),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(),
    shadowColor: Colors.transparent,
    margin: const EdgeInsets.only(bottom: 16),
  ),

  // Input
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.secondaryColor.withOpacity(0.5),
    border: InputBorder.none,
    labelStyle: TextStyle(color: AppColors.textColor),
    prefixIconColor: AppColors.textColor,
  ),

  // Dialog
  dialogTheme: DialogTheme(
    backgroundColor: AppColors.secondaryColor,
    surfaceTintColor: Colors.transparent,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.secondaryColor,
    indicatorColor: AppColors.secondaryAccent,
    surfaceTintColor: AppColors.transparent,
    labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return TextStyle(
            color: AppColors.titleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: AppColors.disabledColor,
          fontWeight: FontWeight.w600,
        );
      },
    ),
    iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: AppColors.titleColor);
        }
        return IconThemeData(color: AppColors.disabledColor);
      },
    ),
  ),
);

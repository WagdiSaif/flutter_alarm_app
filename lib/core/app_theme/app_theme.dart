import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:flutter/material.dart';





class AppTheme {
  static ThemeData get theme {
    return ThemeData(
  
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
      
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.textPrimary,
        primaryContainer: AppColors.containerBg,
        onPrimaryContainer: AppColors.textPrimary,
        
        secondary: AppColors.primaryBlueLight,
        onSecondary: AppColors.textPrimary,
        
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimary,
        
        // background: AppColors.backgroundDark,
        // onBackground: AppColors.textPrimary,
        
        error: AppColors.error,
        onError: AppColors.textPrimary,
        
        outline: AppColors.textPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(color: AppColors.containerBg),
      // Text Theme
      textTheme: const TextTheme(
        // displayLarge: headlineLarge,
        // displayMedium: AppTextStyles,
        // displaySmall: headlineSmall,
        
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        
        // labelLarge: AppTextStyles,l,
        // labelMedium: labelMedium,
      ),
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        // titleTextStyle: AppTextStyles.t,
      ),
      
      // Buttons
    
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      // Cards
      elevatedButtonTheme: ElevatedButtonThemeData(

        style:ElevatedButton.styleFrom(
  // backgroundColor: Colors.amber,
        // backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      )),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
     
      
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      
      // Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,

      ),
      
      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.textDisabled,
        thickness: 1,
      ),
      
      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        circularTrackColor: Color(0x33FFFFFF),
        linearTrackColor: Color(0x33FFFFFF),
      ),
      
      // Navigation
    
      
      // Enable Material 3
      useMaterial3: true,
      
      // Good touch targets
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

ThemeData get appTheme=>AppTheme.theme;
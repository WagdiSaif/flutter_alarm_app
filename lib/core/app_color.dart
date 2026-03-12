import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryBlue = Color(0xFF1A9DED);
  static const primaryBlueLight = Color(0xFF4FB4F0);
  
  // Background Colors
  static const backgroundDark = Color(0xFF0A2332);
  static const surfaceDark = Color(0xFF1A3442);
  static const containerBg = Color(0xFF37586D);
  static const cardBg = Color(0xFF2A4455);
  
  // Text Colors (ensuring good contrast)
  static const textPrimary = Color(0xFFFFFFFF);  // White - good contrast
  static const textSecondary = Color(0xFFE0E0E0); // Light gray - good contrast
  static const textDisabled = Color(0xFF9E9E9E);  // Medium gray
  static const textHint = Color(0xFFBDBDBD);      // Light gray
  
  // Semantic Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
  static const warning = Color(0xFFFFB74D);
}

class AppTextStyles {
  // Headlines
  static const headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  static const headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  // Titles
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 2,
    color: AppColors.textPrimary,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  static const titleSmall = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textSecondary,
  );
  
  // Labels
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.3,
    color: AppColors.textSecondary,
  );
}

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


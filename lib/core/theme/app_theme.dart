import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base) {
    final quicksand = GoogleFonts.quicksandTextTheme(base);
    return quicksand.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onWarm,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onWarm,
        tertiary: AppColors.plans,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.onWarm,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.scaffold,
    );

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: _textTheme(base.primaryTextTheme),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onWarm,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.onWarm,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          side: BorderSide(
            color: AppColors.stroke.withValues(alpha: 0.12),
            width: AppDecorations.outlineWidth,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onWarm,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          side: BorderSide(
            color: AppColors.stroke.withValues(alpha: 0.15),
            width: AppDecorations.outlineWidth,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onWarm,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
            side: BorderSide(
              color: AppColors.stroke.withValues(alpha: 0.12),
              width: AppDecorations.outlineWidth,
            ),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.stroke.withValues(alpha: 0.2),
            width: AppDecorations.outlineWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          borderSide: BorderSide(
            color: AppColors.stroke.withValues(alpha: 0.14),
            width: AppDecorations.outlineWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          borderSide: BorderSide(
            color: AppColors.stroke.withValues(alpha: 0.14),
            width: AppDecorations.outlineWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.stroke,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onWarm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.stroke.withValues(alpha: 0.1),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryLight,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(
          color: AppColors.stroke.withValues(alpha: 0.12),
          width: AppDecorations.outlineWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondary,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.background,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: AppTypography.fontFamily,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.white,
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: AppSpacing.elevationNone,
        color: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: AppSpacing.cardPadding,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSpacing.paddingHLg.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.textHint,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSpacing.paddingHLg.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: AppColors.border),
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: AppSpacing.paddingHLg.copyWith(
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        disabledColor: AppColors.disabled,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.primaryLight,
        labelStyle: AppTypography.caption,
        padding: AppSpacing.paddingSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationLg,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.white,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: const Color(0xFF93000A),
      onPrimaryContainer: const Color(0xFFFFDAD6),
      secondary: const Color(0xFF84B0FF),
      onSecondary: const Color(0xFF003258),
      secondaryContainer: const Color(0xFF00497D),
      onSecondaryContainer: const Color(0xFFD4E3FF),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF1A1C1E),
      onSurface: const Color(0xFFE2E2E6),
      surfaceContainerHighest: const Color(0xFF2C2E30),
      onSurfaceVariant: const Color(0xFFC4C6D0),
      outline: const Color(0xFF8E9099),
      outlineVariant: const Color(0xFF44474E),
      shadow: const Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: AppTypography.fontFamily,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1C1E),
        foregroundColor: const Color(0xFFE2E2E6),
        surfaceTintColor: const Color(0xFF1A1C1E),
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: const Color(0xFFE2E2E6),
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFE2E2E6),
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: AppSpacing.elevationNone,
        color: const Color(0xFF1A1C1E),
        surfaceTintColor: const Color(0xFF1A1C1E),
        shadowColor: const Color(0xFF000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: AppSpacing.cardPadding,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSpacing.paddingHLg.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: const Color(0xFF44474E),
          disabledForegroundColor: const Color(0xFF8E9099),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSpacing.paddingHLg.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: Color(0xFF8E9099)),
          foregroundColor: const Color(0xFF84B0FF),
          disabledForegroundColor: const Color(0xFF8E9099),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          foregroundColor: const Color(0xFF84B0FF),
          disabledForegroundColor: const Color(0xFF8E9099),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2E30),
        contentPadding: AppSpacing.paddingHLg.copyWith(
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF44474E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF44474E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1.5),
        ),
        labelStyle: AppTypography.bodyText2.copyWith(
          color: const Color(0xFFC4C6D0),
        ),
        hintStyle: AppTypography.bodyText2.copyWith(
          color: const Color(0xFF8E9099),
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: const Color(0xFFFFB4AB),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2E30),
        disabledColor: const Color(0xFF44474E),
        selectedColor: const Color(0xFF93000A),
        secondarySelectedColor: const Color(0xFF93000A),
        labelStyle: AppTypography.caption,
        padding: AppSpacing.paddingSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1C1E),
        selectedItemColor: Color(0xFFFFB4AB),
        unselectedItemColor: Color(0xFF8E9099),
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationLg,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF44474E),
        thickness: 1,
        space: AppSpacing.lg,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: const Color(0xFFE2E2E6),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(
          color: const Color(0xFFE2E2E6),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A1C1E),
        surfaceTintColor: Color(0xFF1A1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFFFB4AB),
        unselectedLabelColor: Color(0xFFC4C6D0),
        indicatorColor: Color(0xFFFFB4AB),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFF93000A),
      ),
    );
  }
}

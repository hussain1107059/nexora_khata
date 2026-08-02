import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  AppTheme._();

  static const double _radiusButton = 14;
  static const double _radiusInput = 14;
  static const double _radiusDialog = 24;
  static const double _radiusSheet = 28;
  static const double _radiusCard = AppSpacing.radiusLg;

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
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
      scrim: AppColors.scrim,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      canvasColor: AppColors.scaffoldBackground,
      fontFamily: AppTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.surface,
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shadowColor: AppColors.shadow,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          surfaceTintColor: Colors.transparent,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.textHint,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.2),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTypography.button.copyWith(
            fontWeight: FontWeight.w600,
          ),
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        labelStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textHint,
        ),
        helperStyle: AppTypography.caption.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
        errorMaxLines: 2,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primary,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        disabledColor: AppColors.disabled,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: true,
        checkmarkColor: AppColors.white,
        elevation: 0,
        pressElevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        indicatorShape: const StadiumBorder(),
        height: 68,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textHint,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelMedium.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationLg,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: AppTypography.bodyText2.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.bodyText2.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadow,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusDialog),
        ),
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.white,
        ),
        actionTextColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_radiusSheet)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
        shadowColor: AppColors.shadow,
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.disabled.withValues(alpha: 0.45);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textHint;
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        titleTextStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Premium dark palette
    const dSurface = Color(0xFF171A21);
    const dBackground = Color(0xFF1E222B);
    const dScaffold = Color(0xFF0F1115);
    const dTextPrimary = Color(0xFFE7EAF0);
    const dTextSecondary = Color(0xFF9AA3B0);
    const dTextHint = Color(0xFF6B7480);
    const dBorder = Color(0xFF2A2F3A);
    const dDivider = Color(0xFF232833);
    const dDisabled = Color(0xFF3A4150);
    const dChip = Color(0xFF21262F);

    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: Color(0xFF4A1E1D),
      onPrimaryContainer: Color(0xFFFFDAD6),
      secondary: Color(0xFF84B0FF),
      onSecondary: Color(0xFF003258),
      secondaryContainer: Color(0xFF00497D),
      onSecondaryContainer: Color(0xFFD4E3FF),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF3B0A0A),
      errorContainer: Color(0xFF331414),
      onErrorContainer: Color(0xFFFFB4AB),
      surface: dSurface,
      onSurface: dTextPrimary,
      surfaceContainerHighest: dBackground,
      onSurfaceVariant: dTextSecondary,
      outline: dBorder,
      outlineVariant: dDivider,
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: dScaffold,
      canvasColor: dScaffold,
      fontFamily: AppTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: dSurface,
        foregroundColor: dTextPrimary,
        surfaceTintColor: dSurface,
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: dTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: dTextPrimary, size: 24),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: dSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x66000000),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: dDivider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shadowColor: const Color(0x66000000),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          surfaceTintColor: Colors.transparent,
          disabledBackgroundColor: dDisabled,
          disabledForegroundColor: dTextHint,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
          side: const BorderSide(color: dBorder, width: 1.2),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
          foregroundColor: const Color(0xFF84B0FF),
          disabledForegroundColor: dTextHint,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
          foregroundColor: const Color(0xFF84B0FF),
          disabledForegroundColor: dTextHint,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: dBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: dBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.6),
        ),
        labelStyle: AppTypography.bodyText2.copyWith(color: dTextSecondary),
        hintStyle: AppTypography.bodyText2.copyWith(color: dTextHint),
        helperStyle: AppTypography.caption.copyWith(color: dTextHint),
        errorStyle: AppTypography.caption.copyWith(color: const Color(0xFFFF8A80)),
        prefixIconColor: dTextHint,
        suffixIconColor: dTextHint,
        errorMaxLines: 2,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: dChip,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        disabledColor: dDisabled,
        labelStyle: AppTypography.labelMedium.copyWith(color: dTextPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: true,
        checkmarkColor: AppColors.white,
        elevation: 0,
        pressElevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF4A1E1D),
        indicatorShape: const StadiumBorder(),
        height: 68,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? const Color(0xFFFFB4AB) : dTextHint,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelMedium.copyWith(
            color: selected ? const Color(0xFFFFB4AB) : dTextSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: dSurface,
        selectedItemColor: Color(0xFFFFB4AB),
        unselectedItemColor: dTextHint,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationLg,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: const Color(0xFFFFB4AB),
        unselectedLabelColor: dTextSecondary,
        indicatorColor: const Color(0xFFFFB4AB),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: AppTypography.bodyText2.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTypography.bodyText2.copyWith(fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: dDivider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: dSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x66000000),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusDialog),
        ),
        titleTextStyle: AppTypography.subtitle1.copyWith(
          color: dTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(color: dTextSecondary),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dBackground,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentTextStyle: AppTypography.bodyText2.copyWith(color: dTextPrimary),
        actionTextColor: const Color(0xFFFFB4AB),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: dSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: dSurface,
        elevation: 8,
        shadowColor: Color(0x66000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_radiusSheet)),
        ),
        showDragHandle: true,
        dragHandleColor: dBorder,
        dragHandleSize: Size(40, 4),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: dSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
        shadowColor: const Color(0x66000000),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: dSurface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : dTextPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : dDisabled;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : dTextHint;
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: dTextSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        titleTextStyle: AppTypography.bodyText2.copyWith(
          color: dTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTypography.caption.copyWith(color: dTextSecondary),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFF4A1E1D),
        circularTrackColor: Color(0xFF4A1E1D),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: dBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.caption.copyWith(color: dTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

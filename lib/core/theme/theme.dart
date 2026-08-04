import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_motion.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// PacePulse · Theme assembly.
///
/// Usage:
///   MaterialApp(
///     theme: ppLightTheme(),
///     darkTheme: ppDarkTheme(),
///     themeMode: ThemeMode.dark, // dark is the brand default
///   )
///
/// Custom tokens: `Theme.of(context).extension<PPColors>()!`
ThemeData ppDarkTheme() => _buildTheme(ppDarkColorScheme, PPColors.dark);

ThemeData ppLightTheme() => _buildTheme(ppLightColorScheme, PPColors.light);

ThemeData _buildTheme(ColorScheme scheme, PPColors pp) {
  final isDark = scheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: ppTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    extensions: [pp],
    scaffoldBackgroundColor: scheme.surface,

    // Cards sit one surface step above the canvas. Dark elevates via
    // the lighter surface step (elevation 0); light uses a soft shadow.
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: isDark ? 0 : 1,
      shadowColor: isDark ? Colors.transparent : const Color(0x1F25343F),
      shape: const RoundedRectangleBorder(borderRadius: PPRadius.cardRadius),
      margin: EdgeInsets.zero,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: ppTextTheme.headlineSmall?.copyWith(
        color: scheme.onSurface,
      ),
    ),

    // Primary action: Ember pill with Slate content — never white.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.primary.withValues(
          alpha: isDark ? 0.30 : 0.45,
        ),
        disabledForegroundColor: scheme.onPrimary.withValues(
          alpha: isDark ? 0.55 : 0.45,
        ),
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s6),
        shape: const StadiumBorder(),
        textStyle: ppTextTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: pp.accentText,
        side: BorderSide(color: scheme.outline, width: PPBorders.regular),
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s6),
        shape: const StadiumBorder(),
        textStyle: ppTextTheme.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: pp.accentText,
        minimumSize: const Size(PPSpacing.tapMin, PPSpacing.tapMin),
        textStyle: ppTextTheme.labelLarge,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PPSpacing.s4,
        vertical: PPSpacing.s4,
      ),
      border: OutlineInputBorder(
        borderRadius: PPRadius.inputRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: PPRadius.inputRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: PPRadius.inputRadius,
        borderSide: BorderSide(color: scheme.primary, width: PPBorders.strong),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: PPRadius.inputRadius,
        borderSide: BorderSide(color: scheme.error, width: PPBorders.regular),
      ),
    ),

    // T2: the modal barrier is the approved scrim — dark in BOTH themes.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBarrierColor: scheme.scrim,
      shape: const RoundedRectangleBorder(borderRadius: PPRadius.sheetRadius),
      showDragHandle: true,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      barrierColor: scheme.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPRadius.xl),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: PPBorders.hairline,
      space: PPBorders.hairline,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      height: 72,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          isDark ? scheme.surfaceContainerHighest : PPPalette.slate,
      contentTextStyle: ppTextTheme.bodyMedium?.copyWith(
        color: isDark ? scheme.onSurface : PPPalette.mist,
      ),
      actionTextColor: isDark ? pp.accentText : PPPalette.ember,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: PPRadius.tileRadius),
    ),
  );
}

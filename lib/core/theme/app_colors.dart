import 'package:flutter/material.dart';

/// PacePulse · Color tokens (generated from design-tokens/colors.css,
/// including the approved T2–T6 additions merged 2026-06-12).
///
/// Dark is the default theme. Hard rules baked into these values:
///   • Content on Ember is ALWAYS Slate (onPrimary) — never white.
///     Slate-on-Ember = 6.13:1 (AA). White-on-Ember = 2.09:1 (fails).
///   • Ember is NEVER text/small-icon on light surfaces; light accent
///     text uses emberStrong (#A24A0C — 5.14:1 on Mist). Read it via
///     `Theme.of(context).extension<PPColors>()!.accentText`, which
///     resolves per theme.
///   • Error is rose, hue-separated from Ember.
///   • The scrim (ColorScheme.scrim) is DARK in both themes so Ember
///     countdown numerals stay AAA on it.

/// Raw locked palette — theme-independent constants.
/// Prefer semantic roles (ColorScheme / PPColors) in widgets; reach for
/// these only in CustomPainters or one-off derivations.
abstract final class PPPalette {
  static const mist = Color(0xFFEAEFEF);
  static const steel = Color(0xFFBFC9D1);
  static const slate = Color(0xFF25343F);
  static const ember = Color(0xFFFF9B51);
  static const white = Color(0xFFFFFFFF);

  static const canvasDark = Color(0xFF16212B);
  static const surfaceDarkHigh = Color(0xFF2F4350);
  static const surfaceDarkHigher = Color(0xFF3A4E5C);
  static const emberPressed = Color(0xFFE8842F);
  static const emberStrong = Color(0xFFA24A0C);
  static const steelDark = Color(0xFF51616C);
  static const steelDeep = Color(0xFF3C4A54);
  static const steelPale = Color(0xFFD6DEE2);
  static const steelLightTrack = Color(0xFFE0E6E8);
}

/// Material ColorScheme — dark (default).
///
/// Mapping notes:
///   • surface = app canvas (#16212B); cards sit on surfaceContainerLow
///     (= Slate). Dark elevation climbs via lighter surface steps.
///   • secondary/tertiary are borrowed from the ring companions
///     (exercise teal / steps purple) so stock Material widgets stay
///     on-brand; the real data colors live in PPColors.
///   • scrim is the approved T2 value — identical in both themes.
const ColorScheme ppDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFF9B51),
  onPrimary: Color(0xFF25343F),
  primaryContainer: Color(0xFF3A2A1B),
  onPrimaryContainer: Color(0xFFFFB877),
  secondary: Color(0xFF21C7D6),
  onSecondary: Color(0xFF16212B),
  secondaryContainer: Color(0xFF123A40),
  onSecondaryContainer: Color(0xFF7CE3ED),
  tertiary: Color(0xFFC36BE6),
  onTertiary: Color(0xFF16212B),
  error: Color(0xFFFF7088),
  onError: Color(0xFF25343F),
  errorContainer: Color(0xFF311A20),
  onErrorContainer: Color(0xFFFF9DAE),
  surface: Color(0xFF16212B),
  onSurface: Color(0xFFEAEFEF),
  onSurfaceVariant: Color(0xFFBFC9D1),
  surfaceContainerLowest: Color(0xFF16212B),
  surfaceContainerLow: Color(0xFF25343F),
  surfaceContainer: Color(0xFF2A3A46),
  surfaceContainerHigh: Color(0xFF2F4350),
  surfaceContainerHighest: Color(0xFF3A4E5C),
  outline: Color(0x3DBFC9D1),
  outlineVariant: Color(0x1FBFC9D1),
  scrim: Color(0xD916212B),
);

/// Material ColorScheme — light.
///
/// Mist canvas, white cards; elevation is carried by shadows here
/// (PPColors.shadow1/2/3) because surface/high/highest are all white.
const ColorScheme ppLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFFF9B51),
  onPrimary: Color(0xFF25343F),
  primaryContainer: Color(0xFFFFE8D6),
  onPrimaryContainer: Color(0xFFA24A0C),
  secondary: Color(0xFF0E97A4),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD3F0F3),
  onSecondaryContainer: Color(0xFF0B6570),
  tertiary: Color(0xFF9B4FC9),
  onTertiary: Color(0xFFFFFFFF),
  error: Color(0xFFC81E43),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFBE0E6),
  onErrorContainer: Color(0xFFC81E43),
  surface: Color(0xFFEAEFEF),
  onSurface: Color(0xFF25343F),
  onSurfaceVariant: Color(0xFF51616C),
  surfaceContainerLowest: Color(0xFFEAEFEF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFF4F7F7),
  surfaceContainerHigh: Color(0xFFFFFFFF),
  surfaceContainerHighest: Color(0xFFFFFFFF),
  outline: Color(0x2E25343F),
  outlineVariant: Color(0x1A25343F),
  scrim: Color(0xD916212B),
);

/// Custom PacePulse roles that have no ColorScheme counterpart.
///
/// Usage: `final pp = Theme.of(context).extension<PPColors>()!;`
@immutable
class PPColors extends ThemeExtension<PPColors> {
  const PPColors({
    required this.accentText,
    required this.onSurfaceFaint,
    required this.onSurfaceDisabled,
    required this.primaryHover,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.errorDisabled,
    required this.live,
    required this.liveRing,
    required this.liveGlow,
    required this.hrZone1,
    required this.hrZone2,
    required this.hrZone3,
    required this.hrZone4,
    required this.hrZone5,
    required this.ringMove,
    required this.ringExercise,
    required this.ringSteps,
    required this.ringTrack,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.chartGrid,
    required this.chartAxis,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadow1,
    required this.shadow2,
    required this.shadow3,
  });

  /// Chart area fill alpha for fl_chart belowBarData (T4) — same in
  /// both themes.
  static const double chartFillAlpha = 0.14;

  /// Accent-colored text/icons: Ember on dark, emberStrong on light —
  /// never use raw Ember for text on light surfaces.
  final Color accentText;

  /// Tertiary/metadata text (--on-surface-faint).
  final Color onSurfaceFaint;

  /// Disabled text (--on-surface-disabled).
  final Color onSurfaceDisabled;

  /// Ember hover fill (--primary-hover) — pointer/desktop surfaces.
  final Color primaryHover;

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Disabled fill for destructive actions (T6, --error-disabled).
  final Color errorDisabled;

  final Color live;
  final Color liveRing;
  final Color liveGlow;

  final Color hrZone1;
  final Color hrZone2;
  final Color hrZone3;
  final Color hrZone4;
  final Color hrZone5;

  final Color ringMove;
  final Color ringExercise;
  final Color ringSteps;
  final Color ringTrack;

  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color chartGrid;
  final Color chartAxis;

  /// Skeleton shimmer pair (T5): base ↔ highlight over 1.4s
  /// (PPMotion.shimmerPeriod); static base under reduced motion.
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Elevation shadows (--shadow-1/2/3). The real elevation system in
  /// light mode (multi-layer); reserved for floating UI in dark.
  final List<BoxShadow> shadow1;
  final List<BoxShadow> shadow2;
  final List<BoxShadow> shadow3;

  /// Convenience views for indexed access (zones, chart series).
  List<Color> get hrZones => [hrZone1, hrZone2, hrZone3, hrZone4, hrZone5];
  List<Color> get chartSeries => [chart1, chart2, chart3, chart4, chart5];

  static const dark = PPColors(
    accentText: Color(0xFFFF9B51),
    onSurfaceFaint: Color(0xFF8FA0AB),
    onSurfaceDisabled: Color(0xFF5C6C76),
    primaryHover: Color(0xFFFFAA68),
    success: Color(0xFF3FD98B),
    onSuccess: Color(0xFF0C2418),
    successContainer: Color(0xFF11281D),
    onSuccessContainer: Color(0xFF6FE6AC),
    warning: Color(0xFFFFC53D),
    onWarning: Color(0xFF2A2103),
    warningContainer: Color(0xFF2A2103),
    onWarningContainer: Color(0xFFFFD24A),
    errorDisabled: Color(0x4DFF7088),
    live: Color(0xFFFF9B51),
    liveRing: Color(0x73FF9B51),
    liveGlow: Color(0x8CFF9B51),
    hrZone1: Color(0xFF5AB4EA),
    hrZone2: Color(0xFF34C7A8),
    hrZone3: Color(0xFFFFD24A),
    hrZone4: Color(0xFFFF9B51),
    hrZone5: Color(0xFFEF5A2B),
    ringMove: Color(0xFFFF9B51),
    ringExercise: Color(0xFF21C7D6),
    ringSteps: Color(0xFFC36BE6),
    ringTrack: Color(0x29BFC9D1),
    chart1: Color(0xFFFF9B51),
    chart2: Color(0xFF36C5D8),
    chart3: Color(0xFFB07CF0),
    chart4: Color(0xFF54CC82),
    chart5: Color(0xFFFFD24A),
    chartGrid: Color(0x1FBFC9D1),
    chartAxis: Color(0xFFBFC9D1),
    skeletonBase: Color(0xFF2A3A46),
    skeletonHighlight: Color(0xFF2F4350),
    shadow1: [
      BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x66000000)),
    ],
    shadow2: [
      BoxShadow(offset: Offset(0, 6), blurRadius: 18, color: Color(0x73000000)),
    ],
    shadow3: [
      BoxShadow(
        offset: Offset(0, 18),
        blurRadius: 48,
        color: Color(0x8C000000),
      ),
    ],
  );

  static const light = PPColors(
    accentText: Color(0xFFA24A0C),
    onSurfaceFaint: Color(0xFF6E7E88),
    onSurfaceDisabled: Color(0xFFA7B2B8),
    primaryHover: Color(0xFFFF8E3C),
    success: Color(0xFF0C7548),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD6F2E4),
    onSuccessContainer: Color(0xFF0C7548),
    warning: Color(0xFF8A5A00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFF4E9CE),
    onWarningContainer: Color(0xFF8A5A00),
    errorDisabled: Color(0x59C81E43),
    live: Color(0xFFD9711C),
    liveRing: Color(0x52D9711C),
    liveGlow: Color(0x66D9711C),
    hrZone1: Color(0xFF2F8FD6),
    hrZone2: Color(0xFF109C7E),
    hrZone3: Color(0xFFC98A00),
    hrZone4: Color(0xFFE5811F),
    hrZone5: Color(0xFFD23E12),
    ringMove: Color(0xFFE5811F),
    ringExercise: Color(0xFF0E97A4),
    ringSteps: Color(0xFF9B4FC9),
    ringTrack: Color(0x1A25343F),
    chart1: Color(0xFFC96A12),
    chart2: Color(0xFF0E8AA0),
    chart3: Color(0xFF7A4FC0),
    chart4: Color(0xFF2E8F52),
    chart5: Color(0xFF9A6300),
    chartGrid: Color(0x1A25343F),
    chartAxis: Color(0xFF51616C),
    skeletonBase: Color(0xFFD6DEE2),
    skeletonHighlight: Color(0xFFFFFFFF),
    shadow1: [
      BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x1A25343F)),
      BoxShadow(offset: Offset(0, 1), blurRadius: 1, color: Color(0x0F25343F)),
    ],
    shadow2: [
      BoxShadow(offset: Offset(0, 6), blurRadius: 18, color: Color(0x1F25343F)),
      BoxShadow(offset: Offset(0, 2), blurRadius: 6, color: Color(0x1425343F)),
    ],
    shadow3: [
      BoxShadow(
        offset: Offset(0, 18),
        blurRadius: 48,
        color: Color(0x2925343F),
      ),
      BoxShadow(offset: Offset(0, 6), blurRadius: 16, color: Color(0x1A25343F)),
    ],
  );

  @override
  PPColors copyWith({
    Color? accentText,
    Color? onSurfaceFaint,
    Color? onSurfaceDisabled,
    Color? primaryHover,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? errorDisabled,
    Color? live,
    Color? liveRing,
    Color? liveGlow,
    Color? hrZone1,
    Color? hrZone2,
    Color? hrZone3,
    Color? hrZone4,
    Color? hrZone5,
    Color? ringMove,
    Color? ringExercise,
    Color? ringSteps,
    Color? ringTrack,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? chartGrid,
    Color? chartAxis,
    Color? skeletonBase,
    Color? skeletonHighlight,
    List<BoxShadow>? shadow1,
    List<BoxShadow>? shadow2,
    List<BoxShadow>? shadow3,
  }) {
    return PPColors(
      accentText: accentText ?? this.accentText,
      onSurfaceFaint: onSurfaceFaint ?? this.onSurfaceFaint,
      onSurfaceDisabled: onSurfaceDisabled ?? this.onSurfaceDisabled,
      primaryHover: primaryHover ?? this.primaryHover,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      errorDisabled: errorDisabled ?? this.errorDisabled,
      live: live ?? this.live,
      liveRing: liveRing ?? this.liveRing,
      liveGlow: liveGlow ?? this.liveGlow,
      hrZone1: hrZone1 ?? this.hrZone1,
      hrZone2: hrZone2 ?? this.hrZone2,
      hrZone3: hrZone3 ?? this.hrZone3,
      hrZone4: hrZone4 ?? this.hrZone4,
      hrZone5: hrZone5 ?? this.hrZone5,
      ringMove: ringMove ?? this.ringMove,
      ringExercise: ringExercise ?? this.ringExercise,
      ringSteps: ringSteps ?? this.ringSteps,
      ringTrack: ringTrack ?? this.ringTrack,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      chartGrid: chartGrid ?? this.chartGrid,
      chartAxis: chartAxis ?? this.chartAxis,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      shadow1: shadow1 ?? this.shadow1,
      shadow2: shadow2 ?? this.shadow2,
      shadow3: shadow3 ?? this.shadow3,
    );
  }

  @override
  PPColors lerp(ThemeExtension<PPColors>? other, double t) {
    if (other is! PPColors) return this;
    return PPColors(
      accentText: Color.lerp(accentText, other.accentText, t)!,
      onSurfaceFaint: Color.lerp(onSurfaceFaint, other.onSurfaceFaint, t)!,
      onSurfaceDisabled:
          Color.lerp(onSurfaceDisabled, other.onSurfaceDisabled, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      errorDisabled: Color.lerp(errorDisabled, other.errorDisabled, t)!,
      live: Color.lerp(live, other.live, t)!,
      liveRing: Color.lerp(liveRing, other.liveRing, t)!,
      liveGlow: Color.lerp(liveGlow, other.liveGlow, t)!,
      hrZone1: Color.lerp(hrZone1, other.hrZone1, t)!,
      hrZone2: Color.lerp(hrZone2, other.hrZone2, t)!,
      hrZone3: Color.lerp(hrZone3, other.hrZone3, t)!,
      hrZone4: Color.lerp(hrZone4, other.hrZone4, t)!,
      hrZone5: Color.lerp(hrZone5, other.hrZone5, t)!,
      ringMove: Color.lerp(ringMove, other.ringMove, t)!,
      ringExercise: Color.lerp(ringExercise, other.ringExercise, t)!,
      ringSteps: Color.lerp(ringSteps, other.ringSteps, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      chartAxis: Color.lerp(chartAxis, other.chartAxis, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      shadow1: BoxShadow.lerpList(shadow1, other.shadow1, t)!,
      shadow2: BoxShadow.lerpList(shadow2, other.shadow2, t)!,
      shadow3: BoxShadow.lerpList(shadow3, other.shadow3, t)!,
    );
  }
}

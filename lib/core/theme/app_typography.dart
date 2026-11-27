import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PacePulse · Typography (generated from design-tokens/typography.css
/// + fonts.css — the approved Inter revision).
///
/// Roles:
///   display / headline / title → Inter (800 for hero numerals, 700 headers)
///   body / label               → Inter (400–700)
///   timers · pace · splits     → JetBrains Mono via [PPTextStyles]
///
/// TABULAR FIGURES ARE MANDATORY for any live-updating number — the
/// display styles carry `tnum` by default and mono is tabular by
/// construction, so ticking digits never jitter.
///
/// Requires the `google_fonts` package. For release builds, bundle the
/// woff2/ttf files locally (google_fonts supports asset fonts) so the
/// app doesn't fetch fonts at runtime.

const List<FontFeature> ppTabularFigures = [
  FontFeature.tabularFigures(),
  FontFeature.liningFigures(),
];

/// Material TextTheme mapping of the named CSS scale:
///   displayLarge  72  ← displayXL (the live workout metric)
///   displayMedium 56  ← displayL
///   displaySmall  44  ← displayM
///   headlineLarge 34  ← h1 · headlineMedium 28 ← h2 · headlineSmall 22 ← h3
///   bodyLarge 18 · bodyMedium 16 · bodySmall 14
///   labelLarge 14 (buttons — display face 700, +0.01em) ·
///   labelMedium 12 ← caption ·
///   labelSmall 11 ← overline (uppercase applied at call site)
final TextTheme ppTextTheme = TextTheme(
  displayLarge: GoogleFonts.inter(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    height: 0.95,
    letterSpacing: -0.72,
    fontFeatures: ppTabularFigures,
  ),
  displayMedium: GoogleFonts.inter(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 0.95,
    letterSpacing: -0.56,
    fontFeatures: ppTabularFigures,
  ),
  displaySmall: GoogleFonts.inter(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    height: 0.95,
    letterSpacing: -0.44,
    fontFeatures: ppTabularFigures,
  ),
  headlineLarge: GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.17,
  ),
  headlineMedium: GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.14,
  ),
  headlineSmall: GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.11,
  ),
  titleLarge: GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.1,
  ),
  titleMedium: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  ),
  titleSmall: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  ),
  bodyLarge: GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),
  bodyMedium: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),
  bodySmall: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  ),
  // Buttons use the display face at 700 with +0.01em tracking (per the
  // component library), unlike the display scale's negative tracking.
  labelLarge: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.14,
  ),
  labelMedium: GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.48,
  ),
  labelSmall: GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.54,
  ),
);

/// Styles that live outside TextTheme: the mono set (Material has no
/// mono slots) and the T7 countdown numeral. Colors are applied at the
/// call site from the active theme.
abstract final class PPTextStyles {
  /// 160 (T7 --text-countdown) — the full-screen 3-2-1 numerals ONLY.
  /// Color at call site: Ember on the T2 scrim in BOTH themes (the
  /// light theme deliberately keeps raw Ember here — the scrim is dark).
  static final countdown = GoogleFonts.inter(
    fontSize: 160,
    fontWeight: FontWeight.w900,
    height: 1.0,
    fontFeatures: ppTabularFigures,
  );

  /// 40 — big pace / timer readouts.
  static final monoXl = GoogleFonts.jetBrainsMono(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    fontFeatures: ppTabularFigures,
  );

  /// 24 — secondary live metrics.
  static final monoL = GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.1,
    fontFeatures: ppTabularFigures,
  );

  /// 16 — inline numeric values.
  static final monoM = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.1,
    fontFeatures: ppTabularFigures,
  );

  /// 13 — splits table.
  static final monoS = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.1,
    fontFeatures: ppTabularFigures,
  );
}

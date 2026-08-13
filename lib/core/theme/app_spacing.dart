import 'package:flutter/widgets.dart';

/// PacePulse · Spacing, radius & layout (generated from
/// design-tokens/spacing.css). 4px base grid.
abstract final class PPSpacing {
  // Spacing scale (4px base)
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 40;
  static const double s9 = 48;
  static const double s10 = 64;
  static const double s11 = 80;
  static const double s12 = 96;

  // Semantic aliases
  /// Icon ↔ label gap.
  static const double gapInline = s2;

  /// Between stacked text blocks.
  static const double gapStack = s3;

  /// Card interior padding.
  static const double padCard = s5;

  /// Screen gutter on the 390px frame.
  static const double padScreen = s5;

  /// Between major screen sections.
  static const double gapSection = s7;

  /// Minimum hit target — never smaller, mid-run.
  static const double tapMin = 44;
}

abstract final class PPRadius {
  /// Chips, tags, small controls.
  static const double xs = 6;

  /// Inputs, small buttons.
  static const double sm = 10;

  /// Nested tiles.
  static const double md = 14;

  /// Cards, sheets.
  static const double lg = 20;

  /// Hero cards, bottom sheets.
  static const double xl = 28;

  /// Primary buttons, segmented controls, badges.
  static const double pill = 999;

  // Ready-made BorderRadius presets.
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius tileRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class PPBorders {
  static const double hairline = 1;
  static const double regular = 1.5;
  static const double strong = 2;
}

/// Design reference frame (mockups are specced at 390×844).
abstract final class PPFrame {
  static const double width = 390;
  static const double height = 844;
}

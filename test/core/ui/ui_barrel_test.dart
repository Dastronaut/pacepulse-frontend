import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/ui/ui.dart';

/// Compile-time completeness: if any symbol is missing from the barrel,
/// this file fails to compile.
void main() {
  test('every kit symbol is exported through ui.dart', () {
    const types = [
      PPIcon, PPIcons, PPIconSize, PPPressable, PPTapTarget, PPSkeleton,
      PPLiveDot, PPLivePulse, PPSpinner,
      PPButton, PPButtonVariant, PPButtonSize, PPIconButton,
      PPIconButtonStyle, PPStartFab, PPSegmentedControl,
      PPChip, PPChipVariant, PPChipShape, PPToastKind, PPOfflineBanner,
      PPBannerAdSlot, PPEmptyState, PPErrorState, PPCountdownOverlay,
      PPIllustration, PPIllustrationSize, PPIllustrationAccent,
      PPRingGeometry, PPActivityRing, PPActivityRings, PPMetricDisplay,
      PPMetricFace, PPStatTile, PPWorkoutCard, PPProgressBar, PPChartCard,
      PPElevationProfile, PPHRZoneBar, PPSplitsHeader, PPSplitsRow,
      PPAvatar, PPAvatarStack, PPAvatarSize, PPLeaderboardRow,
      PPTextField, PPSettingsGroup, PPSettingsRow,
      PPBottomNavBar, PPAppBar,
      PPMapPreviewCard, PPDeviceTile, PPDeviceState, PPPaywallPlanCard,
    ];
    expect(types, isNotEmpty);
    // Function symbols compile-check by reference:
    expect([showPPToast, showPPSheet, showPPDialog, ppReducedMotion],
        isNotEmpty);
  });
}

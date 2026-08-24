import 'package:flutter/widgets.dart' show IconData;

import '../../../core/ui/foundations/pp_icon.dart';

/// The four permissions PacePulse primes, per Flow 5 S10.
///
/// S10's rules are normative: prime BEFORE the OS dialog, one ask per
/// moment, never a wall of four. Each kind names the moment it belongs to:
///   · location      — first workout start
///   · notifications — first challenge
///   · health        — after the first save
///   · bluetooth     — device pairing (wizard step 4 is the first one)
enum PermissionKind { location, notifications, health, bluetooth }

PermissionKind? permissionKindFromName(String? name) {
  for (final kind in PermissionKind.values) {
    if (kind.name == name) return kind;
  }
  return null;
}

extension PermissionKindCopy on PermissionKind {
  String get title => switch (this) {
    PermissionKind.location => 'See your route and distance',
    PermissionKind.notifications => 'Know when a race starts',
    PermissionKind.health => 'Sync workouts with Health',
    PermissionKind.bluetooth => 'Connect your heart-rate strap',
  };

  String get body => switch (this) {
    PermissionKind.location =>
      'PacePulse uses your location only while you work out — never in the background.',
    PermissionKind.notifications =>
      'PacePulse notifies you when a challenge starts or a friend passes you — nothing else.',
    PermissionKind.health =>
      'Your saved runs appear in Apple Health. PacePulse only writes workouts — it never reads your other data.',
    PermissionKind.bluetooth =>
      'Bluetooth lets PacePulse read live heart rate from your strap during workouts.',
  };

  String get allowLabel => switch (this) {
    PermissionKind.location => 'Allow location',
    PermissionKind.notifications => 'Allow notifications',
    PermissionKind.health => 'Allow Health',
    PermissionKind.bluetooth => 'Allow Bluetooth',
  };

  String get footnote => switch (this) {
    PermissionKind.location =>
      'Your phone will confirm — choose "While using the app"',
    PermissionKind.notifications =>
      'Your phone will confirm — you can turn these off anytime',
    PermissionKind.health => 'Your phone will confirm — choose what to share',
    PermissionKind.bluetooth =>
      'You can pair a strap later in Settings → Devices',
  };

  IconData get glyph => switch (this) {
    PermissionKind.location => PPIcons.mapPin,
    PermissionKind.notifications => PPIcons.bell,
    PermissionKind.health => PPIcons.heart,
    PermissionKind.bluetooth => PPIcons.bluetooth,
  };
}

abstract final class PermissionCopy {
  static const notNow = 'Not now';
}

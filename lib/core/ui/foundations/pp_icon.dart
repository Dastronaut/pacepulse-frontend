import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Icon sizes from the design system: 20 / 24 / 28 on the 4px grid.
enum PPIconSize {
  s20(20),
  s24(24),
  s28(28);

  const PPIconSize(this.dp);
  final double dp;
}

/// The single wrapper over the icon set. Swapping sets later touches
/// only this file ([PPIcons]).
class PPIcon extends StatelessWidget {
  const PPIcon(this.icon, {super.key, this.size = PPIconSize.s24, this.color});

  final IconData icon;
  final PPIconSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: size.dp, color: color ?? IconTheme.of(context).color);
}

/// The 36 spec-named icons (Deliverable 3 icon manifest), mapped to
/// Lucide. Names follow the sheet; Lucide constants may differ slightly
/// per package version (e.g. triangleAlert vs alertTriangle) — resolve
/// by autocomplete, keep OUR field names stable.
abstract final class PPIcons {
  static const house = LucideIcons.house;
  static const clock = LucideIcons.clock;
  static const zap = LucideIcons.zap;
  static const user = LucideIcons.user;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const chevronRight = LucideIcons.chevronRight;
  static const x = LucideIcons.x;
  static const share2 = LucideIcons.share2;
  static const slidersHorizontal = LucideIcons.slidersHorizontal;
  static const list = LucideIcons.list;
  static const calendarDays = LucideIcons.calendarDays;
  static const ellipsis = LucideIcons.ellipsis;
  static const footprints = LucideIcons.footprints;
  static const bike = LucideIcons.bike;
  static const dumbbell = LucideIcons.dumbbell;
  static const heartPulse = LucideIcons.heartPulse;
  static const flame = LucideIcons.flame;
  static const route = LucideIcons.route;
  static const mountain = LucideIcons.mountain;
  static const timer = LucideIcons.timer;
  static const gauge = LucideIcons.gauge;
  static const chartLine = LucideIcons.chartLine;
  static const trophy = LucideIcons.trophy;
  static const mapPin = LucideIcons.mapPin;
  static const play = LucideIcons.play;
  static const pause = LucideIcons.pause;
  static const square = LucideIcons.square;
  static const plus = LucideIcons.plus;
  static const minus = LucideIcons.minus;
  static const check = LucideIcons.check;
  static const bluetooth = LucideIcons.bluetooth;
  static const bell = LucideIcons.bell;
  static const crown = LucideIcons.crown;
  static const wifiOff = LucideIcons.wifiOff;
  static const triangleAlert = LucideIcons.triangleAlert;
  static const heart = LucideIcons.heart;

  static const List<IconData> all = [
    house, clock, zap, user, chevronLeft, chevronRight, x, share2,
    slidersHorizontal, list, calendarDays, ellipsis, footprints, bike,
    dumbbell, heartPulse, flame, route, mountain, timer, gauge, chartLine,
    trophy, mapPin, play, pause, square, plus, minus, check, bluetooth,
    bell, crown, wifiOff, triangleAlert, heart,
  ];
}

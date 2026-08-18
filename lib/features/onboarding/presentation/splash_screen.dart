import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_info.dart';
import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../auth/data/session.dart';
import '../../auth/presentation/auth_landing_placeholder.dart';
import '../../home/presentation/home_placeholder.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const path = '/splash';

  static const maxDuration = Duration(milliseconds: 1500);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawIn =
      AnimationController(vsync: this, duration: PPMotion.deliberate);
  late final Animation<double> _ringValue =
      CurvedAnimation(parent: _drawIn, curve: PPMotion.energetic);
  Timer? _cap;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    _cap = Timer(SplashScreen.maxDuration, () => _go(hasSession: false));
    if (ppReducedMotion(context)) {
      _drawIn.value = 1;
    } else {
      await _drawIn.forward();
    }
    final hasSession = await ref
        .read(sessionProvider.future)
        .catchError((_) => false);
    _go(hasSession: hasSession);
  }

  void _go({required bool hasSession}) {
    if (_navigated || !mounted) return;
    _navigated = true;
    _cap?.cancel();
    context
        .go(hasSession ? HomePlaceholder.path : AuthLandingPlaceholder.path);
  }

  @override
  void dispose() {
    _cap?.cancel();
    _drawIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _ringValue,
              builder: (context, _) => PPActivityRing(
                value: _ringValue.value,
                color: theme.colorScheme.primary,
                size: 180,
                thickness: 21,
              ),
            ),
            const SizedBox(height: PPSpacing.s6),
            Text(
              'PacePulse',
              style: theme.textTheme.headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              PPAppInfo.versionLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: pp.onSurfaceFaint),
            ),
            const SizedBox(height: PPSpacing.s11),
          ],
        ),
      ),
    );
  }
}

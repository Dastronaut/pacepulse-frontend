import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../auth/presentation/auth_landing_screen.dart';
import '../data/onboarding_seen.dart';
import 'onboarding_slides.dart';
import 'widgets/onboarding_page_dots.dart';

// Flow 5 S2 layout literals with no token (ruling 2026-08-17, convention
// per pp_button.dart:9-12): 28px specimen↔text gap; 28px screen bottom
// padding — the same value today but a different role, kept separate so
// design can move one without the other; 10px headline↔body gap; 300px
// body max width. The 28px bottom padding recurs across S2–S9 and is
// raised as a PPSpacing token candidate.
const _slideGap = 28.0;
const _screenBottomPad = 28.0;
const _textGap = 10.0;
const _bodyMaxWidth = 300.0;

class OnboardingCarouselScreen extends ConsumerStatefulWidget {
  const OnboardingCarouselScreen({super.key});

  static const path = '/onboarding';

  @override
  ConsumerState<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState
    extends ConsumerState<OnboardingCarouselScreen> {
  final _controller = PageController();
  int _index = 0;

  /// Skip and Get started are the same exit, and both are 44px+ targets a
  /// fast double-tap can hit twice. Without this, the second tap fires a
  /// second write and a second `context.go`.
  bool _finishing = false;

  bool get _isLast => _index == onboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    final target = _index + 1;
    if (ppReducedMotion(context)) {
      _controller.jumpToPage(target);
    } else {
      _controller.animateToPage(
        target,
        duration: PPMotion.base,
        curve: PPMotion.standard,
      );
    }
  }

  void _finish() {
    if (_finishing) return;
    _finishing = true;
    ref.read(onboardingSeenStoreProvider).markSeen().ignore();
    ref.invalidate(onboardingSeenProvider);
    context.go(AuthLandingScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s3),
              child: Align(
                alignment: Alignment.centerRight,
                child: PPButton(
                  label: 'Skip',
                  variant: PPButtonVariant.ghost,
                  onPressed: _finish,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingSlides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) =>
                    _SlideView(slide: onboardingSlides[i]),
              ),
            ),
            OnboardingPageDots(count: onboardingSlides.length, index: _index),
            const SizedBox(height: PPSpacing.s5),
            Padding(
              padding: const EdgeInsets.only(
                left: PPSpacing.s5,
                right: PPSpacing.s5,
                bottom: _screenBottomPad,
              ),
              child: PPButton(
                label: _isLast ? 'Get started' : 'Next',
                size: PPButtonSize.lg,
                fullWidth: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Scrolls rather than overflows at large text scale; the chrome
    // outside the pager stays pinned.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  slide.specimen,
                  const SizedBox(height: _slideGap),
                  Text(
                    slide.headline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: _textGap),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _bodyMaxWidth),
                    child: Text(
                      slide.body,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/ui/ui.dart';
import '../../permissions/domain/permission_kind.dart';
import '../../permissions/presentation/permission_priming_screen.dart';
import '../../shell/presentation/tab_placeholder.dart';
import '../domain/activity.dart';
import '../domain/daily_rings.dart';
import '../domain/home_copy.dart';
import '../domain/home_summary.dart';
import 'home_controller.dart';
import 'widgets/home_header.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/quick_start.dart';
import 'widgets/recent_section.dart';
import 'widgets/rings_card.dart';
import 'widgets/stats_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const path = '/home';

  void _startWorkout(BuildContext context, ActivityType type) {
    // TODO(flow2): route to the workout pre-start screen.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final offline = ref.watch(connectivityProvider).value == false;
    final reduced = ppReducedMotion(context);

    ref.listen(connectivityProvider, (previous, next) {
      if (previous?.value == false && next.value == true) {
        showPPToast(context, message: HomeCopy.backOnline);
      }
    });

    final summary = state.value;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                final controller = ref.read(homeControllerProvider.notifier);
                await controller.refresh();
                if (controller.lastRefreshError != null && context.mounted) {
                  showPPToast(
                    context,
                    message: HomeCopy.refreshFailed,
                    kind: PPToastKind.error,
                  );
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: PPSpacing.gapStack,
                  bottom: PPSpacing.s11,
                ),
                children: [
                  HomeHeader(
                    summary: summary ?? _placeholderSummary(now),
                    offline: offline,
                    now: now,
                    showWelcome: summary == null ? false : null,
                    showAvatar: summary != null,
                    onStreakTap: () {
                      // TODO(flow1-followup): open the streak detail sheet.
                    },
                    onAvatarTap: () => context.go(ProfileScreen.path),
                  ),
                  AnimatedSize(
                    duration: reduced ? Duration.zero : PPMotion.base,
                    curve: PPMotion.decelerate,
                    alignment: Alignment.topCenter,
                    child: offline
                        ? const Padding(
                            padding: EdgeInsets.only(top: PPSpacing.s4),
                            child: PPOfflineBanner(
                              message: HomeCopy.offlineBanner,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: PPSpacing.gapSection),
                  AnimatedSwitcher(
                    duration: reduced ? Duration.zero : PPMotion.base,
                    child: switch (state) {
                      AsyncError() => Column(
                        key: const ValueKey('home_phase_error'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PPSpacing.padScreen,
                            ),
                            child: PPErrorState(
                              title: HomeCopy.errorTitle,
                              body: HomeCopy.errorBody,
                              onRetry: () =>
                                  ref.invalidate(homeControllerProvider),
                            ),
                          ),
                          const SizedBox(height: PPSpacing.gapSection),
                          QuickStart(
                            onStart: (type) => _startWorkout(context, type),
                          ),
                        ],
                      ),
                      AsyncData(:final value) => Column(
                        key: const ValueKey('home_phase_data'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RingsCard(
                            rings: value.rings,
                            // TODO(flow3): open the stats overview.
                            onTap: null,
                          ),
                          const SizedBox(height: PPSpacing.gapSection),
                          StatsRow(
                            summary: value,
                            onConnectHealth: () => context.push(
                              PermissionPrimingScreen.routeFor(
                                PermissionKind.health,
                              ),
                            ),
                          ),
                          if (value.hasStats)
                            const SizedBox(height: PPSpacing.gapSection),
                          QuickStart(
                            onStart: (type) => _startWorkout(context, type),
                          ),
                          const SizedBox(height: PPSpacing.gapSection),
                          RecentSection(
                            recent: value.recent,
                            now: now,
                            onViewAll: () => context.go(HistoryScreen.path),
                            // TODO(flow3): open the workout detail.
                            onOpen: (_) {},
                            onStartFirst: () =>
                                _startWorkout(context, ActivityType.run),
                          ),
                        ],
                      ),
                      _ => Column(
                        key: const ValueKey('home_phase_loading'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const HomeSkeleton(),
                          const SizedBox(height: PPSpacing.gapSection),
                          QuickStart(
                            onStart: (type) => _startWorkout(context, type),
                          ),
                        ],
                      ),
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: PPSpacing.padScreen,
              bottom: PPSpacing.padScreen,
              child: PPStartFab(
                key: const Key('home_fab'),
                onPressed: () => _startWorkout(context, ActivityType.run),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

HomeSummary _placeholderSummary(DateTime now) => HomeSummary(
  displayName: '',
  initials: '',
  date: now,
  rings: DailyRings.empty,
  recent: const [],
);

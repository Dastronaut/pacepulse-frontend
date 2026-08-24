import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../home/presentation/home_placeholder.dart';
import '../../permissions/domain/permission_kind.dart';
import '../../permissions/presentation/permission_priming_screen.dart';
import '../../permissions/presentation/primed_this_session.dart';
import '../domain/profile_draft.dart';
import 'widgets/wizard_progress.dart';
import 'widgets/wizard_step_about.dart';
import 'widgets/wizard_step_gear.dart';
import 'widgets/wizard_step_goal.dart';
import 'widgets/wizard_step_units.dart';
import 'wizard_controller.dart';

const double _chromeHeight = 56;

class ProfileWizardScreen extends ConsumerStatefulWidget {
  const ProfileWizardScreen({super.key});

  static const path = '/wizard';

  @override
  ConsumerState<ProfileWizardScreen> createState() =>
      _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends ConsumerState<ProfileWizardScreen> {
  final _pager = PageController();

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _animateTo(int step) {
    if (!_pager.hasClients) return;
    if (ppReducedMotion(context)) {
      _pager.jumpToPage(step);
    } else {
      _pager.animateToPage(
        step,
        duration: PPMotion.base,
        curve: PPMotion.standard,
      );
    }
  }

  void _connect(GearDevice device) {
    // TODO(wizard-slice): pair `device` once flutter_blue_plus lands.
    if (ref
        .read(primedThisSessionProvider)
        .contains(PermissionKind.bluetooth)) {
      return;
    }
    ref.read(primedThisSessionProvider.notifier).mark(PermissionKind.bluetooth);
    context.push(PermissionPrimingScreen.routeFor(PermissionKind.bluetooth));
  }

  void _finish() {
    ref.read(wizardControllerProvider.notifier).finish();
    context.go(HomePlaceholder.path);
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(wizardControllerProvider.select((s) => s.step));
    final notifier = ref.read(wizardControllerProvider.notifier);

    ref.listen<int>(
      wizardControllerProvider.select((s) => s.step),
      (_, next) => _animateTo(next),
    );

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s3),
                child: SizedBox(
                  height: _chromeHeight,
                  child: Row(
                    children: [
                      if (step > 0)
                        PPIconButton(
                          icon: PPIcons.chevronLeft,
                          onPressed: notifier.back,
                          semanticLabel: WizardCopy.back,
                        )
                      else
                        const SizedBox(width: PPSpacing.tapMin),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PPSpacing.s2,
                          ),
                          child: WizardProgress(
                            count: WizardState.lastStep + 1,
                            index: step,
                          ),
                        ),
                      ),
                      const SizedBox(width: PPSpacing.tapMin),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pager,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WizardStepAbout(onContinue: notifier.next),
                    WizardStepUnits(onContinue: notifier.next),
                    WizardStepGoal(onContinue: notifier.next),
                    WizardStepGear(
                      onFinish: _finish,
                      onSkip: _finish,
                      onConnect: _connect,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

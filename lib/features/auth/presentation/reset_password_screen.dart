import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../domain/auth_validators.dart';
import 'reset_password_controller.dart';

const _bannerGap = 10.0;
const _screenBottomPad = 28.0;

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  static const path = '/auth/reset-password';

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        ref.read(resetPasswordControllerProvider.notifier).emailBlurred();
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = ref.read(resetPasswordControllerProvider.notifier);
    if (!controller.validate()) {
      if (ref.read(resetPasswordControllerProvider).emailError != null) {
        _emailFocus.requestFocus();
      }
      return;
    }
    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final state = ref.watch(resetPasswordControllerProvider);
    final controller = ref.read(resetPasswordControllerProvider.notifier);

    return Scaffold(
      appBar: PPAppBar.standard(
        title: AuthCopy.resetTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: PPSpacing.padScreen,
            right: PPSpacing.padScreen,
            top: PPSpacing.s3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AuthCopy.resetBlurb,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: PPSpacing.s4),
                      PPTextField(
                        key: const Key('pp_reset_email'),
                        label: AuthCopy.emailLabel,
                        focusNode: _emailFocus,
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.go,
                        autofillHints: const [AutofillHints.email],
                        onChanged: controller.emailChanged,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (state.sentTo != null) ...[
                        const SizedBox(height: PPSpacing.s4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PPSpacing.s4,
                            vertical: PPSpacing.s3,
                          ),
                          decoration: BoxDecoration(
                            color: pp.successContainer,
                            borderRadius: BorderRadius.circular(PPRadius.md),
                          ),
                          child: Row(
                            children: [
                              PPIcon(
                                PPIcons.check,
                                size: PPIconSize.s20,
                                color: pp.onSuccessContainer,
                              ),
                              const SizedBox(width: _bannerGap),
                              Expanded(
                                child: Text(
                                  AuthCopy.sentTo(state.sentTo!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: pp.onSuccessContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: _screenBottomPad),
                child: switch (state) {
                  ResetPasswordState(sentTo: null) => PPButton(
                    label: AuthCopy.sendResetLink,
                    size: PPButtonSize.lg,
                    fullWidth: true,
                    loading: state.submitting,
                    onPressed: _submit,
                  ),
                  ResetPasswordState(canResend: true) => PPButton(
                    label: AuthCopy.sendResetLink,
                    size: PPButtonSize.lg,
                    variant: PPButtonVariant.ghost,
                    fullWidth: true,
                    // TODO(auth-slice): inert seam — this re-validates
                    onPressed: _submit,
                  ),
                  _ => SizedBox(
                    height: PPSpacing.tapMin,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AuthCopy.resendIn,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: pp.onSurfaceDisabled,
                            ),
                          ),
                          Text(
                            state.cooldownLabel,
                            style: PPTextStyles.monoS.copyWith(
                              color: pp.onSurfaceDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

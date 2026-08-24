import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../home/presentation/home_placeholder.dart';
import '../domain/auth_validators.dart';
import 'reset_password_screen.dart';
import 'sign_in_controller.dart';
import 'widgets/password_visibility_toggle.dart';

const _screenBottomPad = 28.0;

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const path = '/auth/sign-in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        ref.read(signInControllerProvider.notifier).emailBlurred();
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = ref.read(signInControllerProvider.notifier);
    if (!controller.validate()) {
      final state = ref.read(signInControllerProvider);
      if (state.emailError != null) {
        _emailFocus.requestFocus();
      } else if (state.passwordError != null) {
        _passwordFocus.requestFocus();
      }
      return;
    }
    controller.submit();
    // S5: "returning → Home".
    // TODO(auth-slice): move this inside the session call's success handler.
    context.go(HomePlaceholder.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);

    return Scaffold(
      appBar: PPAppBar.standard(
        title: AuthCopy.signInTitle,
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
                      PPTextField(
                        key: const Key('pp_sign_in_email'),
                        label: AuthCopy.emailLabel,
                        focusNode: _emailFocus,
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: controller.emailChanged,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: PPSpacing.s4),
                      PPTextField(
                        key: const Key('pp_sign_in_password'),
                        label: AuthCopy.passwordLabel,
                        focusNode: _passwordFocus,
                        obscureText: !state.passwordVisible,
                        errorText: state.passwordError,
                        textInputAction: TextInputAction.go,
                        autofillHints: const [AutofillHints.password],
                        onChanged: controller.passwordChanged,
                        onSubmitted: (_) => _submit(),
                        trailing: PasswordVisibilityToggle(
                          visible: state.passwordVisible,
                          onToggle: controller.togglePasswordVisible,
                        ),
                      ),
                      const SizedBox(height: PPSpacing.s4),
                      if (state.suggestReset)
                        PPButton(
                          label: AuthCopy.forgotPassword,
                          size: PPButtonSize.lg,
                          variant: PPButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () =>
                              context.push(ResetPasswordScreen.path),
                        )
                      else
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: PPSpacing.tapMin,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(ResetPasswordScreen.path),
                              child: Text(
                                AuthCopy.forgotPassword,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: pp.accentText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: _screenBottomPad),
                child: PPButton(
                  label: AuthCopy.signIn,
                  size: PPButtonSize.lg,
                  fullWidth: true,
                  loading: state.submitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

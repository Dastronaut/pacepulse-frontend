import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../domain/auth_validators.dart';
import 'sign_in_screen.dart';
import 'sign_up_controller.dart';
import 'widgets/password_visibility_toggle.dart';

const _actionGap = 10.0;
const _screenBottomPad = 28.0;

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  static const path = '/auth/sign-up';

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        ref.read(signUpControllerProvider.notifier).emailBlurred();
      }
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        ref.read(signUpControllerProvider.notifier).passwordBlurred();
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
    final controller = ref.read(signUpControllerProvider.notifier);
    if (!controller.validate()) {
      final state = ref.read(signUpControllerProvider);
      if (state.emailError != null) {
        _emailFocus.requestFocus();
      } else if (state.passwordError != null) {
        _passwordFocus.requestFocus();
      }
      return;
    }
    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final state = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);

    return Scaffold(
      appBar: PPAppBar.standard(
        title: AuthCopy.createAccountTitle,
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
                        key: const Key('pp_sign_up_email'),
                        label: AuthCopy.emailLabel,
                        focusNode: _emailFocus,
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: controller.emailChanged,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      if (state.emailError == AuthCopy.emailTaken)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => context.go(SignInScreen.path),
                            child: Text(
                              AuthCopy.signInInstead,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: pp.accentText,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: PPSpacing.s4),
                      PPTextField(
                        key: const Key('pp_sign_up_password'),
                        label: AuthCopy.passwordLabel,
                        focusNode: _passwordFocus,
                        obscureText: !state.passwordVisible,
                        errorText: state.passwordError,
                        helperText: AuthCopy.passwordRule,
                        textInputAction: TextInputAction.go,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: controller.passwordChanged,
                        onSubmitted: (_) => _submit(),
                        trailing: PasswordVisibilityToggle(
                          visible: state.passwordVisible,
                          onToggle: controller.togglePasswordVisible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: _screenBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PPButton(
                      key: const Key('pp_sign_up_submit'),
                      label: AuthCopy.createAccountTitle,
                      size: PPButtonSize.lg,
                      fullWidth: true,
                      loading: state.submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: _actionGap),
                    SizedBox(
                      height: PPSpacing.tapMin,
                      child: TextButton(
                        onPressed: () => context.go(SignInScreen.path),
                        child: Text(
                          AuthCopy.signInInstead,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: pp.accentText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

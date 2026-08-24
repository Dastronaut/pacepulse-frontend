import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_validators.dart';

const kSuggestResetAfter = 5;

class SignInState {
  const SignInState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.passwordVisible = false,
    this.submitting = false,
    this.failedAttempts = 0,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool passwordVisible;
  final bool submitting;
  final int failedAttempts;

  bool get suggestReset => failedAttempts >= kSuggestResetAfter;

  SignInState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool? passwordVisible,
    bool? submitting,
    int? failedAttempts,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      passwordVisible: passwordVisible ?? this.passwordVisible,
      submitting: submitting ?? this.submitting,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

class SignInController extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  void emailChanged(String value) =>
      state = state.copyWith(email: value, clearEmailError: true);

  void passwordChanged(String value) =>
      state = state.copyWith(password: value, clearPasswordError: true);

  void togglePasswordVisible() =>
      state = state.copyWith(passwordVisible: !state.passwordVisible);

  void emailBlurred() {
    final error = validateEmail(state.email);
    state = state.copyWith(emailError: error, clearEmailError: error == null);
  }

  bool validate() {
    final emailError = validateEmail(state.email);
    final passwordError = state.password.isEmpty
        ? AuthCopy.passwordRequired
        : null;
    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      clearEmailError: emailError == null,
      clearPasswordError: passwordError == null,
    );
    return emailError == null && passwordError == null;
  }

  /// TODO(auth-slice): wire the session service here, in this shape:
  void submit() {
    if (!validate()) return;
  }

  void onSignInFailed(String message) => state = state.copyWith(
    passwordError: message,
    submitting: false,
    failedAttempts: state.failedAttempts + 1,
  );
}

final signInControllerProvider =
    NotifierProvider.autoDispose<SignInController, SignInState>(
      SignInController.new,
    );

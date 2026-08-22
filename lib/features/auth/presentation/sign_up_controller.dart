import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_validators.dart';

class SignUpState {
  const SignUpState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.passwordVisible = false,
    this.submitting = false,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool passwordVisible;
  final bool submitting;

  SignUpState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool? passwordVisible,
    bool? submitting,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      passwordVisible: passwordVisible ?? this.passwordVisible,
      submitting: submitting ?? this.submitting,
    );
  }
}

class SignUpController extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

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

  void passwordBlurred() {
    final error = validatePassword(state.password);
    state = state.copyWith(
      passwordError: error,
      clearPasswordError: error == null,
    );
  }

  bool validate() {
    final emailError = validateEmail(state.email);
    final passwordError = validatePassword(state.password);
    state = state.copyWith(
      emailError: emailError,
      clearEmailError: emailError == null,
      passwordError: passwordError,
      clearPasswordError: passwordError == null,
    );
    return emailError == null && passwordError == null;
  }

  /// TODO(auth-slice): wire the account service here, in this shape:
  void submit() {
    if (!validate()) return;
  }

  void onSignUpFailed(String message) =>
      state = state.copyWith(emailError: message, submitting: false);
}

final signUpControllerProvider =
    NotifierProvider.autoDispose<SignUpController, SignUpState>(
      SignUpController.new,
    );

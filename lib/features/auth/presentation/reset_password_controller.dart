import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_validators.dart';

const kResendCooldown = Duration(seconds: 30);

class ResetPasswordState {
  const ResetPasswordState({
    this.email = '',
    this.emailError,
    this.submitting = false,
    this.sentTo,
    this.cooldownRemaining = Duration.zero,
  });

  final String email;
  final String? emailError;
  final bool submitting;

  final String? sentTo;
  final Duration cooldownRemaining;

  bool get canResend => sentTo != null && cooldownRemaining == Duration.zero;

  String get cooldownLabel {
    final s = cooldownRemaining.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  ResetPasswordState copyWith({
    String? email,
    String? emailError,
    bool clearEmailError = false,
    bool? submitting,
    String? sentTo,
    Duration? cooldownRemaining,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      submitting: submitting ?? this.submitting,
      sentTo: sentTo ?? this.sentTo,
      cooldownRemaining: cooldownRemaining ?? this.cooldownRemaining,
    );
  }
}

class ResetPasswordController extends Notifier<ResetPasswordState> {
  Timer? _timer;

  @override
  ResetPasswordState build() {
    ref.onDispose(_cancel);
    return const ResetPasswordState();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void emailChanged(String value) =>
      state = state.copyWith(email: value, clearEmailError: true);

  void emailBlurred() {
    final error = validateEmail(state.email);
    state = state.copyWith(emailError: error, clearEmailError: error == null);
  }

  bool validate() {
    final error = validateEmail(state.email);
    state = state.copyWith(emailError: error, clearEmailError: error == null);
    return error == null;
  }

  void submit() {
    if (!validate()) return;
  }

  void onResetLinkSent(String email) {
    _cancel();
    state = state.copyWith(
      sentTo: email,
      submitting: false,
      cooldownRemaining: kResendCooldown,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.cooldownRemaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _cancel();
        state = state.copyWith(cooldownRemaining: Duration.zero);
      } else {
        state = state.copyWith(cooldownRemaining: next);
      }
    });
  }
}

final resetPasswordControllerProvider =
    NotifierProvider.autoDispose<ResetPasswordController, ResetPasswordState>(
      ResetPasswordController.new,
    );

/// Every user-facing string in the auth flow, verbatim from the Flow 5
/// handoff (S5–S7). Screens and tests read them from here so the copy has
/// exactly one source.
abstract final class AuthCopy {
  // S5 · landing
  static const landingHeadline = 'Beat your best';
  static const landingSubhead = 'Track, race, repeat.';
  static const continueWithApple = 'Continue with Apple';
  static const continueWithGoogle = 'Continue with Google';
  static const signUpWithEmail = 'Sign up with email';
  static const alreadyHaveAccount = 'Already have an account? ';
  static const signIn = 'Sign in';
  static const legal =
      'By continuing you agree to the Terms and Privacy policy';

  // S6 · sign up
  static const createAccountTitle = 'Create account';
  static const signInInstead = 'Sign in instead';
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';

  // S7 · sign in
  static const signInTitle = 'Sign in';
  static const forgotPassword = 'Forgot password?';

  // S7 · reset
  static const resetTitle = 'Reset password';
  static const resetBlurb = "Enter your email and we'll send a reset link.";
  static const sendResetLink = 'Send reset link';
  static String sentTo(String email) => 'Sent — check $email';
  static const resendIn = 'Resend in ';

  // Validation and failure messages
  static const emailRequired = 'Enter your email';
  static const emailInvalid = "That doesn't look like an email address";
  static const passwordRequired = 'Enter your password';
  static const passwordRule = '8+ characters with at least 1 number';
  static const emailTaken = 'That email already has an account';
  static const wrongPassword = 'Wrong password — try again or reset it';

  static const socialSignInFailed = "Couldn't sign in — try again or use email";
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return AuthCopy.emailRequired;
  return _emailPattern.hasMatch(value) ? null : AuthCopy.emailInvalid;
}

String? validatePassword(String value) {
  if (value.length < 8) return AuthCopy.passwordRule;
  return value.contains(RegExp(r'\d')) ? null : AuthCopy.passwordRule;
}

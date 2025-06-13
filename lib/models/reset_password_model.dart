class ResetPasswordModel {
  final String emailOtp;
  final String confirmPassword;

  ResetPasswordModel({required this.emailOtp, required this.confirmPassword});

  Map<String, dynamic> toJson() {
    return {
      'otp': emailOtp,
      'password': confirmPassword,
      'confirm_password': confirmPassword,
    };
  }
}

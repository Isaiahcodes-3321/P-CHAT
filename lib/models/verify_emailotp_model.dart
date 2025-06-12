

class VerifyEmailOtpModel {
  final String otp;

  VerifyEmailOtpModel(
      {required this.otp});

  Map<String, dynamic> toJson() {
    return {
      'password': otp,
    };
  }
}
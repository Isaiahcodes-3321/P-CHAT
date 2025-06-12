

class ResendEmailModel {
  final String email;

  ResendEmailModel(
      {required this.email,});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
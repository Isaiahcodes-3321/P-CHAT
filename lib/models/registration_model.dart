class RegisterModel {
  final String fullName;
  final String email;
  final String password;

  RegisterModel(
      {required this.fullName, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullName,
      'email': email,
      'password': password,
    };
  }
}

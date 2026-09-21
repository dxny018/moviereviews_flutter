class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  // Convierte los datos al formato JSON que pide Fake Store API
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
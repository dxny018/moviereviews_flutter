class RoleManager {
  // Regla de negocio por ID
  static String obtenerRolPorId(int userId) {
    if (userId == 1 || userId == 2) {
      return 'Administrador';
    } else if (userId == 3) {
      return 'Auditor';
    } else {
      return 'Cliente';
    }
  }

  // Regla de negocio por nombre de usuario (utilizada en la autenticación)
  static String getRole(String username) {
    final cleanUser = username.trim().toLowerCase();

    if (cleanUser == 'mor_2314' || cleanUser == 'admin') {
      return 'Administrador';
    } else if (cleanUser == 'johnd' || cleanUser == 'derek') {
      return 'Cliente';
    } else {
      return 'Administrador';
    }
  }
}
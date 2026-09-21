class RoleManager {
  // Regla de negocio: IDs 1 y 2 = Administrador, ID 3 = Auditor, el resto = Cliente
  static String obtenerRolPorId(int userId) {
    if (userId == 1 || userId == 2) {
      return 'Administrador';
    } else if (userId == 3) {
      return 'Auditor';
    } else {
      return 'Cliente';
    }
  }
}
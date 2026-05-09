// ============================================================
//  auth_logic.dart — Persona B
//  Lógica de autenticación y registro de usuarios
// ============================================================

/// Simulated user database (email → name)
/// In a real app this would connect to Firebase or a backend
final Map<String, String> registeredUsers = {};

/// Returns true if the email is already registered
bool isRegisteredUser(String email) {
  return registeredUsers.containsKey(email);
}

/// Registers a new user with their name
void registerUser(String email, String name) {
  registeredUsers[email] = name;
}

/// Returns the name of a registered user, or null if not found
String? getUserName(String email) {
  return registeredUsers[email];
}

/// Basic email format validation
bool isValidEmail(String email) {
  return email.contains('@') && email.contains('.');
}

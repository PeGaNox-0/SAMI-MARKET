/// Custom exceptions for the application
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Database error']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

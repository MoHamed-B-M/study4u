sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class PlatformException extends AppException {
  const PlatformException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

abstract class BaseExceptions implements Exception {
  final String message;
  final dynamic orignalError;
  final StackTrace? stackTrace;

  BaseExceptions(this.message, [this.orignalError, this.stackTrace]);
}

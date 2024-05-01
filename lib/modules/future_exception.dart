class FutureException extends Error {
  FutureException(this.body, {this.statusCode, this.stackTrace});

  final dynamic body;
  int? statusCode;

  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'FutureException: $body';
  }
}

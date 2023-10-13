import 'package:future_server/future_server.dart';

class ServerResponse<T> {
  final int statusCode;
  final T? body;
  final Map<String, String>? headers;
  final Future<void> Function()? onDone;
  final FutureSocket? socket;

  ServerResponse({
    required this.statusCode,
    this.body,
    this.headers,
    this.onDone,
    this.socket,
  });

  static json(Map<String, dynamic> body,
      {Map<String, String>? headers, int? statusCode}) {
    return ServerResponse(
      statusCode: statusCode ?? 200,
      body: body,
      headers: headers ?? {},
    );
  }

  // --------------------------------------------------------------------------------------------------------- //

  factory ServerResponse.socket(
      {required FutureSocket socket, Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 200,
      socket: socket,
      headers: headers,
    );
  }

  factory ServerResponse.ok(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 200, body: body, headers: headers ?? {});
  }

  factory ServerResponse.created(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 201, body: body, headers: headers ?? {});
  }

  factory ServerResponse.notFound(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 404, body: body, headers: headers ?? {});
  }

  factory ServerResponse.internalServerError(T body,
      {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 500, body: body, headers: headers ?? {});
  }

  factory ServerResponse.badRequest(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 400, body: body, headers: headers ?? {});
  }

  factory ServerResponse.unauthorized(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 401, body: body, headers: headers ?? {});
  }

  factory ServerResponse.forbidden(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 403, body: body, headers: headers ?? {});
  }

  factory ServerResponse.noContent(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 204, body: body, headers: headers ?? {});
  }

  factory ServerResponse.movedPermanently(T body,
      {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 301, body: body, headers: headers ?? {});
  }

  factory ServerResponse.found(T body, {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 302, body: body, headers: headers ?? {});
  }

  factory ServerResponse.temporaryRedirect(T body,
      {Map<String, String>? headers}) {
    return ServerResponse(statusCode: 307, body: body, headers: headers ?? {});
  }
}

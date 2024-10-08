import 'dart:io';

import 'package:future_server/future_server.dart';

class ServerResponse<T> {
  final int statusCode;
  final dynamic body;
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
      headers: headers ?? {'Content-Type': 'application/json'},
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

  factory ServerResponse.file(File file, {Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 200,
      body: file,
      headers: headers ?? {},
    );
  }

  factory ServerResponse.redirect(String location,
      {Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 302,
      body: null,
      headers: headers ?? {'Location': location},
    );
  }

  factory ServerResponse.html(String html, {Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 200,
      body: html,
      headers: headers ?? {'Content-Type': 'text/html'},
    );
  }

  factory ServerResponse.text(String text, {Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 200,
      body: text,
      headers: headers ?? {'Content-Type': 'text/plain'},
    );
  }

  factory ServerResponse.m3u8(String m3u8, {Map<String, String>? headers}) {
    return ServerResponse(
      statusCode: 200,
      body: m3u8,
      headers: headers ?? {'Content-Type': 'application/x-mpegURL'},
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:future_server/modules/payload_validation_module.dart';
import 'package:get_server/get_server.dart';

import '../future_server.dart';

abstract class FutureResponse<T> extends GetView<T> {
  Future<ServerResponse> response();

  final _futureContext = _FutureContext();

  ContextRequest get request {
    return _futureContext.request!;
  }

  ContextResponse? get requestResponse => _futureContext.response;

  Future<PayloadWithValidationResponse> payloadWithValidatedKeys(
      List<String> keys) async {
    var validationModule = PayloadWithValidationResponse();
    try {
      var payload = await request.payload();
      validationModule.payload = payload;
      if (payload == null) {
        validationModule.requiredKeys = keys;
        return validationModule;
      }

      List<String> payloadKeys = [];

      fs.log(payload.runtimeType.toString());

      if (payload is Map) {
        fs.log('payload is Map');
        payloadKeys = payload.keys.map((e) => e.toString()).toList();
      } else if (payload is List) {
        for (Map entry in payload) {
          payloadKeys.addAll(entry.keys.map((e) => e.toString()).toList());
        }
      } else {
        throw Exception('Invalid payload type');
      }

      if (payloadKeys.isEmpty) {
        throw Exception('Invalid payload type');
      }

      var requiredKeys = <String>[];

      for (var key in keys) {
        if (!payloadKeys.contains(key)) {
          requiredKeys.add(key);
        }
      }

      if (requiredKeys.isNotEmpty) {
        validationModule.requiredKeys = requiredKeys;
        validationModule.payload = payload;
        return validationModule;
      }

      validationModule.isValid = true;
      validationModule.requiredKeys = [];
      validationModule.payload = payload;

      return validationModule;
    } catch (e) {
      fs.log(e.toString());
      return PayloadWithValidationResponse(isValid: false, requiredKeys: keys);
    }
  }

  String? get berearToken {
    final authorization = request.header('authorization')?[0];
    if (authorization != null) {
      final token = authorization.split(' ');
      if (token.length == 2) {
        return token[1];
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    _futureContext.setContext(context);

    // if (context.request.method == 'OPTIONS') {
    //   context.request.response!.header('Access-Control-Allow-Origin', '*');
    //   context.request.response!.header(
    //       'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');

    //   context.request.response!.sendJson({'msg': 'ok'});

    //   return WidgetEmpty();
    // }

    //  else {
    return _BaseFuturerWidget(response());
    // }
  }
}

class _BaseFuturerWidget extends SenderWidget {
  _BaseFuturerWidget(this.response);
  final Future<ServerResponse> response;

  @override
  Widget build(BuildContext context) {
    response.then(
      (responseValue) {
        responseValue.headers?.forEach((key, value) {
          context.request.response!.header(key, value);
        });

        if (responseValue.body != null) {
          context.request.response!.status(responseValue.statusCode);
          var finalValue = responseValue.body;
          // print('finalValue type: ${finalValue.runtimeType}');

          if (finalValue is String) {
            // context.request.response!.send(finalValue);
            // print('value is String');

            if (responseValue.headers?['Content-Type'] == 'text/html') {
              context.request.response!.sendHtmlText(finalValue);
            } else {
              context.request.response!.send(finalValue);
            }
          } else if (finalValue is Map<dynamic, dynamic>) {
            context.request.response!
                .header('Content-Type', 'application/json');
            context.request.response!.sendJson(finalValue);
          } else if (finalValue is Map<String, dynamic>) {
            context.request.response!
                .header('Content-Type', 'application/json');
            context.request.response!.sendJson(finalValue);
          } else if (finalValue is Future<dynamic>) {
            // print('value is Future<dynamic>');
          } else if (finalValue is File) {
            context.request.response!.sendFile(finalValue.path);
          } else {
            print('value is else');

            return null;
          }
        } else if (responseValue.socket != null) {
          var socketModule = responseValue.socket!;
          var socket = context.getSocket;

          if (socket == null) {
            // socket request method is not a socket
            context.request.response!.status(400);
            context.request.response!.sendJson({
              'status': 'failed',
              'message': 'Please use a socket client',
            });
            return;
          }

          final socketId = socket.id;

          // IMPORTANT TO MAKE SOCKET WORK
          socket.rawSocket.done.then((value) {
            socket = null;
          });

          socket?.onOpen((val) {
            fs.log('Socket oppened $socketId');
            socketModule.id = socketId;
            socketModule._setGetSocket(socket!);
            FutureSocket.sockets.add(socketModule);
            if (socketModule.onOpenSocket == null) return;
            socketModule.onOpenSocket!(socketModule);
          });

          socket?.onMessage((val) {
            if (socketModule.onMessageSocket == null) return;
            if (val == null) return;
            if (val == 'ping') return;
            try {
              var message = socketJsonDecode(val);
              if (message['event'] == 'ping') return;
              socketModule.onMessageSocket!(message, socketModule);
            } catch (e) {
              print('Socket Error OnMessage: $e');
            }
          });

          socket?.onClose((close) {
            FutureSocket.sockets.remove(socketModule);
            if (socketModule.onCloseSocket == null) return;
            socketModule.onCloseSocket!(socketModule);
          });

          socket?.onError((close) {
            if (socketModule.onErrorSocket == null) return;
            socketModule.onErrorSocket!(close);
          });
        } else if (responseValue.body == null &&
            responseValue.headers?['Location'] != null) {
          context.request.response!
              .redirect(responseValue.headers!['Location']!);
        } else {
          // print('responseValue.body is null');
        }

        responseValue.onDone?.call();
      },
    ).onError((error, stackTrace) {
      if (error is FutureException) {
        context.request.response!.status(error.statusCode ?? 500);
        if (error.body is Map) {
          context.request.response!.sendJson(error.body);
          return;
        }
        context.request.response!.sendJson({
          'status': 'Server Error',
          'message': error.body.toString(),
          if (fs.debugMode) 'stackTrace': stackTrace.toString(),
        });
        return;
      }
      context.request.response!.status(500);
      context.request.response!.sendJson({
        'status': 'failed',
        'message': error.toString(),
        if (fs.debugMode) 'stackTrace': stackTrace.toString(),
      });
    });

    return WidgetEmpty();
  }
}

class _FutureContext {
  _FutureContext();
  ContextRequest? request;
  ContextResponse? response;

  void setContext(BuildContext context) {
    request = context.request;
    response = context.request.response;
  }
}

class FutureResponseWidget extends FutureResponse {
  FutureResponseWidget(this.responseModule);

  final Future<ServerResponse> responseModule;
  @override
  Future<ServerResponse> response() => responseModule;
}

class FutureSocket {
  static List<FutureSocket> sockets = <FutureSocket>[];

  int? id;
  GetSocket? _getSocket;

  final void Function(Map<String, dynamic>? message, FutureSocket socket)?
      onMessageSocket;
  final void Function(FutureSocket message)? onOpenSocket;
  final void Function(FutureSocket socket)? onCloseSocket;
  final void Function(Close close)? onErrorSocket;

  FutureSocket({
    this.id,
    this.onMessageSocket,
    this.onOpenSocket,
    this.onCloseSocket,
    this.onErrorSocket,
  });

  void _setGetSocket(GetSocket getSocket) {
    _getSocket = getSocket;
  }

  void send(dynamic message) {
    _getSocket!.send(message);
  }

  void sendJson(Map<String, dynamic> message) {
    try {
      var jsonString = json.encode(message);
      _getSocket!.send(jsonString);
    } catch (e) {
      sockets.remove(this);
    }
  }
}

Map<String, dynamic> socketJsonDecode(dynamic message) {
  try {
    return json.decode(message);
  } catch (e) {
    print('Invalid json $message');
    return {};
  }
}

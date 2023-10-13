import 'dart:convert';

import 'package:get_server/get_server.dart';

import '../future_server.dart';

abstract class FutureResponse<T> extends GetView<T> {
  Future<ServerResponse> response();

  final _futureContext = _FutureContext();

  ContextRequest get request {
    return _futureContext.request!;
  }

  ContextResponse? get requestResponse => _futureContext.response;

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

    if (context.request.method == 'OPTIONS') {
      context.request.response!.header('Access-Control-Allow-Origin', '*');
      context.request.response!.header(
          'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');

      context.request.response!.sendJson({'msg': 'ok'});

      return WidgetEmpty();
    } else {
      return _BaseFuturerWidget(response());
    }
  }
}

class _BaseFuturerWidget extends SenderWidget {
  _BaseFuturerWidget(this.response);
  final Future<ServerResponse> response;

  @override
  Widget build(BuildContext context) {
    response.then(
      (responseValue) {
        if (responseValue.body != null) {
          context.request.response!.status(responseValue.statusCode);
          var finalValue = responseValue.body;
          // print('finalValue type: ${finalValue.runtimeType}');

          if (finalValue is String) {
            // finalValue = {'msg': value};
            // context.request.response!.sendJson(finalValue);
            context.request.response!.send(finalValue);
            // print('value is String');
          } else if (finalValue is Map<dynamic, dynamic>) {
            context.request.response!.sendJson(finalValue);
            // print('value is Map<dynamic, dynamic>');
          } else if (finalValue is Map<String, dynamic>) {
            context.request.response!.sendJson(finalValue);
            // print('value is Map<String, dynamic>');
          } else if (finalValue is Future<dynamic>) {
            // print('value is Future<dynamic>');
          } else {
            // print('value is else');
          }
        } else if (responseValue.socket != null) {
          var socketModule = responseValue.socket!;
          var event = context.getSocket;

          if (event == null) {
            // the request method is not a socket
            context.request.response!.status(400);
            context.request.response!.sendJson({
              'status': 'failed',
              'message': 'Please use a socket client',
            });
            return;
          }

          // IMPORTANT TO MAKE SOCKET WORK
          event.rawSocket.done.then((value) {
            event = null;
          });

          event!.onOpen((val) {
            socketModule.id = val.id.toString();
            socketModule._setGetSocket(event!);
            FutureSocket.sockets.add(socketModule);
            socketModule.onOpenSocket!(socketModule);
          });

          event!.onMessage((val) {
            var message = socketJsonDecode(val);
            socketModule.onMessageSocket!(message, socketModule);
          });

          event!.onClose((val) {
            socketModule.onCloseSocket!(val);
          });

          event!.onError((val) {
            socketModule.onErrorSocket!(val);
          });
        }

        responseValue.onDone?.call();
      },
    ).onError((error, stackTrace) {
      context.request.response!.status(500);
      context.request.response!.sendJson({
        'status': 'failed',
        if (fs.debugMode)
          'message': error.toString()
        else
          'message': 'Internal Server Error',
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

  String? id;
  GetSocket? _getSocket;

  final void Function(Map<String, dynamic>? message, FutureSocket socket)?
      onMessageSocket;
  final void Function(FutureSocket message)? onOpenSocket;
  final void Function(dynamic message)? onCloseSocket;
  final void Function(dynamic message)? onErrorSocket;

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
    var jsonString = json.encode(message);
    _getSocket!.send(jsonString);
  }
}

Map<String, dynamic>? socketJsonDecode(String message) {
  try {
    return json.decode(message);
  } catch (e) {
    print('Invalid json $message');
    return null;
  }
}

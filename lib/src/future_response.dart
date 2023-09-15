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

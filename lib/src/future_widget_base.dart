import 'package:get_server/get_server.dart'
    show SenderWidget, Widget, BuildContext, WidgetEmpty;

class FutureWidget extends SenderWidget {
  FutureWidget(this.future);

  final Future future;

  @override
  Widget build(BuildContext context) {
    if (context.request.method != 'OPTIONS') {
      return _BaseFuturerWidget(future);
    } else {
      return WidgetEmpty();
    }
  }
}

class _BaseFuturerWidget extends SenderWidget {
  _BaseFuturerWidget(this.future);
  final Future future;

  @override
  Widget build(BuildContext context) {
    future.then(
      (value) {
        print(value.runtimeType);
        var finalValue = value;
        if (value is String) {
          finalValue = {'msg': value};
          context.request.response!.sendJson(finalValue);
          return;
        }
        if (value is Map<dynamic, dynamic>) {
          context.request.response!.sendJson(finalValue);
          return;
        }
        if (value is Map<String, dynamic>) {
          context.request.response!.sendJson(finalValue);
          return;
        }

        if (value is Future<dynamic>) {
          return;
        } else {
          return;
        }
      },
    );
    return WidgetEmpty();
  }
}

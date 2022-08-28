import 'package:get_server/get_server.dart'
    show SenderWidget, Widget, BuildContext, WidgetEmpty;

class FutureWidget extends _BaseFuturerWidget {
  FutureWidget(Future<String> future) : super(future);

  @override
  Widget build(BuildContext context) {
    if (context.request.method == 'OPTIONS') return WidgetEmpty();
    return _BaseFuturerWidget(future);
  }
}

class _BaseFuturerWidget extends SenderWidget {
  _BaseFuturerWidget(this.future);
  final Future<String> future;

  @override
  Widget build(BuildContext context) {
    future.then(
      (value) {
        context.request.response!.send(value);
      },
    );
    return WidgetEmpty();
  }
}

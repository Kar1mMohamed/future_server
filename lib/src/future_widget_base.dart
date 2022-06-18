import 'package:get_server/get_server.dart';

class FutureWidget extends SenderWidget {
  FutureWidget(this.future);
  final Future<String> future;

  @override
  Widget build(BuildContext context) {
    future.then(
      (value) {
        context.request.response.send(value);
      },
    );
    return WidgetEmpty();
  }
}

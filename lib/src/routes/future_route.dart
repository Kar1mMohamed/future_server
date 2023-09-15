import 'package:future_server/future_server.dart';

class FutureRoute extends GetPage {
  FutureRoute({
    final Method? method,
    required final String name,
    final List<String?>? keys,
    required final FutureResponse Function() response,
    final Bindings? binding,
    final bool? needAuth,
  }) : super(
          method: method ?? Method.dynamic,
          name: name,
          keys: keys,
          page: response,
          binding: binding,
          needAuth: needAuth ?? false,
        );
}

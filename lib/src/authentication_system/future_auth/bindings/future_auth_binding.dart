import 'package:future_server/future_server.dart';

import '../controllers/future_auth_controller.dart';

class FutureAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FutureAuthController>(
      () => FutureAuthController(),
    );
  }
}

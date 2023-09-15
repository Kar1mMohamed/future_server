import 'package:future_server/future_server.dart';

import '../controllers/future_auth_controller.dart';

class FutureAuthResponse extends FutureResponse<FutureAuthController> {
  @override
  Future<ServerResponse> response() async {
    return ServerResponse.created({
      'status': 'success',
      'token': controller.genereateToken(),
    });
  }
}

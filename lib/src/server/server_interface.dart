import 'package:future_server/future_server.dart';

abstract class ServerInterface {
  FutureServerApp serverConfiguration;
  ServerInterface(this.serverConfiguration);
}

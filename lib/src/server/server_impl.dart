// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:future_server/future_server.dart';
import 'package:future_server/src/server/server_interface.dart';

class Server extends ServerInterface {
  Key? key;
  String host = '0.0.0.0';
  int port = 8080;
  String? certificateChain;
  bool shared = true;
  String? privateKey;
  String? password;
  bool cors = false;
  String corsUrl = '*';
  Widget? onNotFound;
  bool useLog = true;
  bool isLogEnable = true;
  String? jwtKey;
  Widget? home;
  Bindings? initialBinding;
  List<FutureRoute>? futurePages;
  bool? useHive;
  String? hivePath;
  RegisterHives? registerHives;
  OpenBoxex? openBoxex;
  bool? useIntegretedAuthenticationSystem;
  Server({
    this.key,
    this.host = '0.0.0.0',
    this.port = 8080,
    this.certificateChain,
    this.shared = true,
    this.privateKey,
    this.password,
    this.cors = false,
    this.corsUrl = '*',
    this.onNotFound,
    this.useLog = true,
    this.isLogEnable = true,
    this.jwtKey,
    this.home,
    this.initialBinding,
    this.futurePages,
    this.useHive,
    this.hivePath,
    this.registerHives,
    this.openBoxex,
    this.useIntegretedAuthenticationSystem,
  }) : super(
          FutureServerApp(
            key: key,
            host: host,
            port: port,
            certificateChain: certificateChain,
            shared: shared,
            privateKey: privateKey,
            password: password,
            cors: cors,
            corsUrl: corsUrl,
            onNotFound: onNotFound,
            useLog: useLog,
            isLogEnable: isLogEnable,
            jwtKey: jwtKey,
            home: home,
            initialBinding: initialBinding,
            futurePages: futurePages,
            useHive: useHive,
            hivePath: hivePath,
            registerHives: registerHives,
            openBoxex: openBoxex,
            useIntegretedAuthenticationSystem:
                useIntegretedAuthenticationSystem,
          ),
        ) {
    if (futurePages == null || futurePages!.isEmpty) {
      throw Exception('futurePages is null or empty');
    }
  }
}

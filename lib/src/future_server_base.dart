// ignore_for_file: overridden_fields

import 'dart:convert';
import 'dart:io';
import 'package:future_server/src/hive/open_boxes.dart';
import 'package:future_server/src/hive/register_adapter.dart';
import 'package:hive/hive.dart';

import '../future_server.dart';
export 'package:get_server/get_server.dart';
import 'dart:developer' as developer;

class _FSImpl extends FutureServerInterface {}

// ignore: non_constant_identifier_names
final fs = _FSImpl();

abstract class FutureServerInterface {
  SmartManagement smartManagement = SmartManagement.full;
  String? reference;
  bool isLogEnable = true;
  LogWriterCallback log = defaultLogWriterCallback;
  void writeToLog(String text) async {
    File logFile = File('log.txt');
    if (await logFile.exists()) {
      var openwrite = logFile.openWrite(mode: FileMode.append);
      openwrite.writeln("${DateTime.now().toString()} $text");
      await openwrite.flush();
      openwrite.close();
    }
  }
}

void defaultLogWriterCallback(String value, {bool isError = false}) {
  if (isError || Get.isLogEnable) developer.log(value, name: 'FS');
}

class FutureServerApp extends GetServerApp {
  FutureServerApp({
    Key? key,
    host = '0.0.0.0',
    port = 8080,
    certificateChain,
    privateKey,
    password,
    shared = true,
    getPages,
    cors = false,
    corsUrl = '*',
    onNotFound,
    initialBinding,
    useLog = true,
    isLogEnable = true,
    jwtKey,
    home,
    bool? useHive,
    String? hivePath,
    RegisterHives? registerHives,
    OpenBoxex? openBoxex,
  })  : controller = Get.put(FutureServerController(
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
          getPages: getPages,
          useHive: useHive ?? false,
          hivePath: hivePath,
          registerHives: registerHives,
          openBoxex: openBoxex,
        )),
        super(key: key);

  @override
  final GetServerController controller;
}

class FutureServer extends FutureServerApp {
  FutureServer({
    Key? key,
    String host = '0.0.0.0',
    int port = 8080,
    String? certificateChain,
    bool shared = true,
    String? privateKey,
    String? password,
    bool cors = false,
    String corsUrl = '*',
    Widget? onNotFound,
    bool useLog = true,
    bool isLogEnable = true,
    String? jwtKey,
    Widget? home,
    Bindings? initialBinding,
    List<GetPage>? futurePages,
    bool? useHive,
    String? hivePath,
    RegisterHives? registerHives,
    OpenBoxex? openBoxex,
  }) : super(
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
          getPages: futurePages,
          useHive: useHive ?? false,
          hivePath: hivePath,
          registerHives: registerHives,
          openBoxex: openBoxex,
        );
}

class FutureServerController extends GetServerController {
  FutureServerController({
    required this.host,
    required this.port,
    required this.certificateChain,
    required this.shared,
    required this.privateKey,
    required this.password,
    required this.cors,
    required this.corsUrl,
    required this.onNotFound,
    required this.useLog,
    required this.isLogEnable,
    required this.jwtKey,
    required this.home,
    required this.initialBinding,
    required this.getPages,
    required this.useHive,
    this.hivePath,
    this.registerHives,
    this.openBoxex,
  }) : super(
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
            jwtKey: jwtKey,
            home: home,
            initialBinding: initialBinding,
            getPages: getPages);

  @override
  final String host;
  @override
  final int port;
  @override
  final String? certificateChain;
  @override
  final bool shared;
  @override
  final String? privateKey;
  @override
  final String? password;
  @override
  final bool cors;
  @override
  final String corsUrl;
  @override
  final Widget? onNotFound;
  @override
  final bool useLog;
  final bool isLogEnable;
  @override
  final String? jwtKey;
  @override
  final Widget? home;
  @override
  final Bindings? initialBinding;
  @override
  final List<GetPage>? getPages;

  bool useHive;
  String? hivePath;
  RegisterHives? registerHives;
  OpenBoxex? openBoxex;

  List<GetPage>? _getPages;
  HttpServer? _server;
  VirtualDirectory? _virtualDirectory;
  Public? _public;

  @override
  Future<GetServerController> start() async {
    _getPages = getPages ?? List.from([]);
    _homeParser();
    if (isLogEnable) {
      createLogFile();
    }

    initialBinding?.dependencies();
    fs.log('Future Server Started');
    fs.log('Don\'t forget to say thanks to Kar1mMohamed');

    if (_getPages != null) {
      if (jwtKey != null) {
        TokenUtil.saveJwtKey(jwtKey!);
      }

      RouteConfig.i.addRoutes(_getPages!);
    }

    await startServer();

    if (useHive) {
      Hive.init(hivePath ?? Directory.current.path);
      fs.log('Hive initialized');
      registerHives?.registerAdapters();
      openBoxex?.openBoxex();
    }

    return Future.value(this);
  }

  @override
  Future<void> stop() async {
    await Future.delayed(Duration.zero);
    await _server?.close();
  }

  @override
  Future<GetServerController> restart() async {
    await stop();
    await start();
    return this;
  }

  @override
  Future<void> startServer() async {
    fs.log('Server started on: $host:$port');

    _server = await _getHttpServer();

    _server?.listen(
      (req) {
        if (useLog) fs.log('Method ${req.method} on ${req.uri}');
        if (isLogEnable) {
          fs.writeToLog('Method ${req.method} on ${req.uri}');
        }
        final route = RouteConfig.i.findRoute(req);

        route?.binding?.dependencies();
        if (cors) {
          addCorsHeaders(req.response, corsUrl);
          if (req.method.toLowerCase() == 'options') {
            var msg = {'status': 'ok'};
            req.response.write(json.encode(msg));
            req.response.close();
          }
        }
        if (route != null) {
          route.handle(req);
        } else {
          if (_public != null) {
            _virtualDirectory ??= VirtualDirectory(
              _public!.folder,
              // pathPrefix: public.path,
            )
              ..allowDirectoryListing = _public!.allowDirectoryListing
              ..jailRoot = _public!.jailRoot
              ..followLinks = _public!.followLinks
              ..errorPageHandler = (callback) {
                _onNotFound(
                  callback,
                  onNotFound,
                );
              }
              ..directoryHandler = (dir, req) {
                var indexUri = Uri.file(dir.path).resolve('index.html');
                _virtualDirectory!.serveFile(File(indexUri.toFilePath()), req);
              };

            _virtualDirectory!.serveRequest(req);
          } else {
            _onNotFound(
              req,
              onNotFound,
            );
          }
        }
      },
    );
  }

  Future<HttpServer> _getHttpServer() {
    if (privateKey != null) {
      var context = SecurityContext();
      if (certificateChain != null) {
        context.useCertificateChain(File(certificateChain!).path);
      }
      if (privateKey != null) {
        context.usePrivateKey(File(privateKey!).path, password: password);
      }

      return HttpServer.bindSecure(host, port, context, shared: shared);
    } else {
      return HttpServer.bind(host, port, shared: shared);
    }
  }

  void _homeParser() {
    if (home == null) return;
    if (home is FolderWidget) {
      // ignore: no_leading_underscores_for_local_identifiers
      var _home = home as FolderWidget;
      _public = Public(
        _home.folder,
        allowDirectoryListing: _home.allowDirectoryListing,
        followLinks: _home.followLinks,
        jailRoot: _home.jailRoot,
      );
    } else {
      _getPages?.add(GetPage(name: '/', page: () => home));
    }
  }

  @override
  void addCorsHeaders(HttpResponse response, String corsUrl) {
    response.headers.add('Access-Control-Allow-Origin', corsUrl);
    response.headers
        .add('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE');
    response.headers.add('Access-Control-Allow-Headers',
        'access-control-allow-origin,content-type,x-access-token');
  }

  void _onNotFound(HttpRequest req, Widget? onNotFound) {
    if (onNotFound != null) {
      Route(
        Method.get,
        RouteParser.normalize(req.uri.toString()),
        onNotFound,
      ).handle(req, status: HttpStatus.notFound);
    } else {
      pageNotFound(req);
    }
  }

  @override
  void pageNotFound(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.notFound
      ..close();
  }

  void createLogFile() async {
    File logFile = File('log.txt');
    if (!await logFile.exists()) {
      await logFile.create();
      fs.log('Log file created ${logFile.path}');
    }
  }
}

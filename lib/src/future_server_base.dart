// ignore_for_file: overridden_fields

import 'dart:convert';
import 'dart:io';
import 'package:future_server/src/authentication_system/future_auth/bindings/future_auth_binding.dart';
import 'package:future_server/src/authentication_system/future_auth/response/future_auth_response.dart';
import 'package:get_server/get_server.dart';
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

  Server? _server;

  void setServer(Server server) => _setServer(server);

  void runServer() => _runServer(_server);

  bool debugMode = false;
}

void _runServer(Server? server) {
  if (server == null) {
    throw Exception('Server is null');
  }
  runApp(server.serverConfiguration);
}

void _setServer(Server server) {
  fs._server = server;
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
    List<FutureRoute>? futurePages,
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
    bool? useIntegretedAuthenticationSystem,
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
          futurePages: futurePages,
          useHive: useHive ?? false,
          hivePath: hivePath,
          registerHives: registerHives,
          openBoxex: openBoxex,
          useIntegretedAuthenticationSystem:
              useIntegretedAuthenticationSystem ?? false,
        )),
        super(key: key);

  @override
  final GetServerController controller;
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
    required this.futurePages,
    required this.useHive,
    this.hivePath,
    this.registerHives,
    this.openBoxex,
    this.useIntegretedAuthenticationSystem = true,
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
          getPages: null,
        );

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

  final List<GetPage>? futurePages;

  final bool useHive;
  final String? hivePath;
  final RegisterHives? registerHives;
  final OpenBoxex? openBoxex;
  final bool useIntegretedAuthenticationSystem;

  List<GetPage>? _futurePages;
  HttpServer? _server;
  VirtualDirectory? _virtualDirectory;
  Public? _public;

  static final notLicencedString =
      'Not licensed\nPlease contact Kar1mMohamed\nemail: karim@kar1mmohamed.com\nphone: +20 1558233906';

  @override
  Future<GetServerController> start() async {
    _futurePages = (futurePages ?? getPages) ?? List.from([]);

    if (useIntegretedAuthenticationSystem) {
      fs.log('Integreted Authentication System is enabled');
      _futurePages ??= [];

      _futurePages!.add(
        FutureRoute(
          name: '/future-auth',
          response: () => FutureAuthResponse(),
          binding: FutureAuthBinding(),
          method: Method.dynamic,
        ),
      );

      fs.log('Future Auth added to routes');
    }

    _homeParser();
    if (isLogEnable) {
      createLogFile();
    }

    initialBinding?.dependencies();
    fs.log('Future Server Started');
    // fs.log('Don\'t forget to say thanks to Kar1mMohamed');
    print(
        'This system is powered by future_server.. \n Don\'t forget to say thanks to Kar1mMohamed');

    if (_futurePages != null) {
      if (jwtKey != null) {
        TokenUtil.saveJwtKey(jwtKey!);
      }

      RouteConfig.i.addRoutes(_futurePages!);
    }
    // else {
    //   var modulesDirectory = Directory('server/modules');
    //   if (!await modulesDirectory.exists()) {
    //     throw Exception('Modules directory not found');
    //   }
    //   var modules = modulesDirectory.listSync();
    //   for (var module in modules) {
    //     var moduleName = module.path.split('/').last;
    //     var response = File('${module.path}/${moduleName}_response.dart');
    //     var binding = File('${module.path}/${moduleName}_binding.dart');
    //     var controller = File('${module.path}/${moduleName}_controller.dart');

    //     var route = '/$moduleName';
    //   }
    // }

    if (useHive) {
      Hive.init(hivePath ?? Directory.current.path);
      print('Hive initialized');
      registerHives?.registerAdapters();
      await openBoxex?.openBoxex();
      await Future.delayed(const Duration(seconds: 1));
    }

    await startServer();

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
        if (req.method.toLowerCase() == 'options') {
          addCorsHeaders(req.response, corsUrl);
          var msg = {'status': 'ok'};
          req.response.write(json.encode(msg));
          req.response.close();
          return;
        }

        var requestHeaders = req.headers;

        if (useLog) fs.log('Method ${req.method} on ${req.uri}');
        if (isLogEnable) {
          fs.writeToLog('Method ${req.method} on ${req.uri}');
        }
        final route = RouteConfig.i.findRoute(req);

        route?.binding?.dependencies();
        if (cors) {
          addCorsHeaders(req.response, corsUrl);
          //   // if (req.method.toLowerCase() == 'options') {
          //   //   var msg = {'status': 'ok'};
          //   //   req.response.write(json.encode(msg));
          //   //   req.response.close();
          //   // }
        }

        if (route != null) {
          var isNeededAuth = route.needAuth;

          var authHeader = requestHeaders['authorization']?[0];
          if (isNeededAuth && authHeader != null) {
            _authenticatedRouteHandler(req, route, authHeader);
          } else {
            route.handle(req);
          }

          // route.handle(req);
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

  void _authenticatedRouteHandler(
      HttpRequest req, Route route, String authHeader) {
    try {
      var token = authHeader.split(' ')[1];
      var claim = TokenUtil.getClaims(token);
      var scopes = _getScsopes(claim);

      var pathAsString = route.path['pathAsString'] as String;
      // var requestedPath = req.uri.toString();

      // check if string has (:dynamic)
      bool isHasVariable = pathAsString.contains(RegExp(r'\/\:[a-zA-Z]+'));
      fs.log('isHasVariable $isHasVariable');

      //  (/admin/classrooms/:id)
      if (isHasVariable) {
        pathAsString = pathAsString.replaceAll(RegExp(r'\/\:[a-zA-Z]+'), '');
      }

      fs.log('pathAsString $pathAsString');

      if (scopes.contains(pathAsString)) {
        route.handle(req);
      } else {
        fs.log('not allowed');
        _onTokenNotAllowed(req);
      }

      // if (route.path[''] == ) {
      //   route.handle(req);
      // }
    } catch (e) {
      fs.log('[Authentcation] $e');
      _onTokenNotAllowed(req);
    }
  }

  List<String> _getScsopes(JwtClaim claim) {
    var scopes = <String>[];

    if (claim.audience != null) {
      return claim.audience!;
    }

    scopes = claim.payload['scopes'] != null
        ? claim.payload['scopes'] as List<String>
        : [];

    return scopes;
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
      _futurePages?.add(GetPage(name: '/', page: () => home));
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

  void _onTokenNotAllowed(HttpRequest req) {
    Route(
      Method.get,
      RouteParser.normalize(req.uri.toString()),
      Json({
        'status': 'error',
        'message': 'You don\'t have permission to access this route',
      }),
    ).handle(req, status: HttpStatus.unauthorized);
  }

  @override
  void pageNotFound(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.notFound
      ..close();
  }

  void internalServerError(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.internalServerError
      ..close();
  }

  void unauthorized(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.unauthorized
      ..close();
  }

  // void pageNotAllowed(HttpRequest req) {
  //   req.response
  //     ..statusCode = HttpStatus.unauthorized
  //     ..close();
  // }

  void createLogFile() async {
    File logFile = File('log.txt');
    if (!await logFile.exists()) {
      await logFile.create();
      fs.log('Log file created ${logFile.path}');
    }
  }
}

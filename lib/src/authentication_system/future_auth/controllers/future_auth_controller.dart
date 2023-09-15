import 'package:future_server/future_server.dart';

class FutureAuthController extends GetxController {
  String genereateToken() {
    var authModule = FutureAuth(
      email: 'karim@email.com',
      phoneNumber: '123123123',
      scopes: ['/home', '/user'],
    );
    // authModule.addScopes();

    var token = TokenUtil.generateToken(
      claim: JwtClaim(
        issuer: 'future_server',
        subject: authModule.email,
        audience: <String>['future_server'],
        maxAge: const Duration(days: 1),
        expiry: DateTime.now().add(const Duration(days: 1)),
        issuedAt: DateTime.now(),
        payload: authModule.toMap(),
      ),
    );

    return token;
  }
}

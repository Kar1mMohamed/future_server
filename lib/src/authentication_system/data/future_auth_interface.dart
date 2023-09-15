// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../future_server.dart';

abstract class FutureAuthInterface {
  final String? email;
  final String? phoneNumber;
  final String? password;
  String? token;
  String? refreshToken;
  final List<String> scopes;
  FutureAuthInterface({
    this.email,
    this.phoneNumber,
    this.password,
    this.token,
    this.refreshToken,
    this.scopes = const <String>[],
  });

  @override
  String toString();

  @override
  bool operator ==(covariant FutureAuthInterface other);

  @override
  int get hashCode;

  Map<String, dynamic> toMap({bool hidePassword = true});

  String generateToken() {
    var claim = JwtClaim(
      issuer: 'future_server',
      subject: email,
      audience: <String>['future_server'],
      maxAge: const Duration(days: 1),
      expiry: DateTime.now().add(const Duration(days: 1)),
      issuedAt: DateTime.now(),
      payload: toMap(),
    );

    var token = TokenUtil.generateToken(claim: claim);

    return token;
  }
}

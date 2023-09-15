// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:future_server/future_server.dart';
import 'package:future_server/src/authentication_system/data/future_auth_interface.dart';

class FutureAuth extends FutureAuthInterface {
  FutureAuth({
    final String? email,
    final String? phoneNumber,
    final String? password,
    String? token,
    String? refreshToken,

    /// The scopes are used to define the permissions of the user and its registered with paths
    List<String> scopes = const <String>[],
  }) : super(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          token: token,
          refreshToken: refreshToken,
          scopes: scopes,
        );

  factory FutureAuth.fromMap(Map<String, dynamic> json) {
    return FutureAuth(
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      scopes: json['scopes'] != null
          ? List<String>.from(json['scopes'] as List<dynamic>)
          : [],
    );
  }

  @override
  Map<String, dynamic> toMap({bool hidePassword = true}) {
    return {
      'email': email,
      if (hidePassword == false) 'phoneNumber': phoneNumber,
      'password': password,
      'token': token,
      'refreshToken': refreshToken,
      'scopes': scopes,
    };
  }

  @override
  String toString() {
    return 'FutureAuth(email: $email, phoneNumber: $phoneNumber, password: $password, token: $token, refreshToken: $refreshToken, scopes: $scopes)';
  }

  void addScopes(List<FutureRoute> routes) {
    for (var route in routes) {
      scopes.add(route.name);
    }
  }
}

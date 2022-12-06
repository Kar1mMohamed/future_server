// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:future_server/future_server.dart';

void main() async {
  // runApp(GetServer(
  //   home: HomeView(),
  // ));
  runApp(FutureServer(home: HomeView(), auth: {}));
}

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return FutureWidget(controller.getData());
  }
}

class HomeController extends GetxController {
  Future<String> getData() async {
    return Future.delayed(Duration(seconds: 3), () => 'Done');
  }

  Future<String> getProfileData(String id) async {
    var resp = '';
    if (id.isNumericOnly) {
      try {
        var results = await futureMYSQL.futureFetchWhere(
          fields: [],
          whereFields: ['id'],
          table: 'profiles',
          whereFieldsValues: ['1'],
        );

        if (results.isEmpty) {
          resp = 'no results';
          return resp;
        }
        var map = ProfileModule(
          id: results.first['id'],
          name: results.first['name'].toString(),
          email: results.first['email'].toString(),
        ).toMap();

        resp = json.encode(map);
        return resp;
      } catch (err) {
        fs.writeToLog(err.toString());
        resp = 'error';
        return resp;
      } finally {
        // ignore: control_flow_in_finally
        return resp;
      }
    } else {
      return 'invalid';
    }
  }
}

class ProfileModule {
  final int id;
  final String name;
  final String email;
  ProfileModule({
    required this.id,
    required this.name,
    required this.email,
  });

  ProfileModule copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return ProfileModule(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory ProfileModule.fromMap(Map<String, dynamic> map) {
    return ProfileModule(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModule.fromJson(String source) =>
      ProfileModule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProfileModule(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileModule &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}

final dbSettings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'test',
    password: 'testpassowrd',
    db: 'test1');

final futureMYSQL = FutureMYSQL(dbsettings: dbSettings);

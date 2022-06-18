import 'package:galileo_mysql/galileo_mysql.dart';

class FutureMYSQL {
  FutureMYSQL({required this.dbsettings});
  final ConnectionSettings dbsettings;
  Future<Results> _mysqlQuery(
      {required List<String> fields, required String table}) async {
    var fieldsString = '*';
    if (fields.isNotEmpty) {
      fieldsString = fields.join(',');
    }
    var queryString = 'select $fieldsString from $table';
    var mysql = await MySqlConnection.connect(dbsettings);
    var respo = await mysql.query(queryString);
    await mysql.close();
    return respo;
  }

  Future<Results> mysqlQuery(
      {required List<String> fields, required String table}) async {
    return await _mysqlQuery(fields: fields, table: table);
  }
}

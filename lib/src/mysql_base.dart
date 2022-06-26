import 'package:galileo_mysql/galileo_mysql.dart'
    show ConnectionSettings, MySqlConnection, Results;
export 'package:galileo_mysql/galileo_mysql.dart'
    show ConnectionSettings, MySqlConnection, Results;

class FutureMYSQL {
  FutureMYSQL({required this.dbsettings});
  final ConnectionSettings dbsettings;

  Future<Results> _queryNoWhere(
      {required List<Object?> fields, required String table}) async {
    var fieldsString = '*';
    if (fields.isNotEmpty) {
      fieldsString = fields.join(',');
    }
    var queryString = 'select $fieldsString from $table';
    var mysql = await MySqlConnection.connect(dbsettings);
    var respo = await mysql.query(queryString);
    await mysql.close();
    // fs.writeToLog(text: queryString);
    return respo;
  }

  Future<Results> _queryWhere(
      {required List<Object?> fields,
      required List<Object?> whereFields,
      required List<Object?> whereFieldsValues,
      required String table}) async {
    Results respo;

    String fieldsString = '*';
    String whereString = whereFields
        .map((e) => whereFields.last == e ? '$e = ?' : '$e = ? and ')
        .join('');

    if (fields.isNotEmpty) {
      fieldsString = fields.join(',');
    }
    String queryString = 'select $fieldsString from $table where $whereString';
    var mysql = await MySqlConnection.connect(dbsettings);
    respo = await mysql.query(queryString, whereFieldsValues);
    await mysql.close();
    // fs.writeToLog(text: queryString);
    return respo;
  }

  Future<Results> _insert(
      {required List<Object?> fields,
      required List<dynamic> fieldsValues,
      required String table}) async {
    var fieldsString = fields.join(',');

    var queryString =
        'insert into $table ($fieldsString) values ${fields.map((e) => '?').toString()}';

    var mysql = await MySqlConnection.connect(dbsettings);
    var respo = await mysql.query(queryString, fieldsValues);
    await mysql.close();
    // fs.writeToLog(text: queryString);
    return respo;
  }

  Future<Results> futureFetch(
      {required List<Object?> fields, required String table}) async {
    return await _queryNoWhere(fields: fields, table: table);
  }

  Future<Results> futureFetchWhere(
      {required List<Object?> fields,
      required List<Object?> whereFields,
      required List<Object?> whereFieldsValues,
      required String table}) async {
    return await _queryWhere(
        fields: fields,
        whereFields: whereFields,
        whereFieldsValues: whereFieldsValues,
        table: table);
  }

  Future<Results> futureInsert(
      {required List<Object?> fields,
      required List<dynamic> fieldsValues,
      required String table}) async {
    return await _insert(
        fields: fields, fieldsValues: fieldsValues, table: table);
  }

  Future<Results> future(String sqlString, [List<Object?>? values]) async {
    var mysql = await MySqlConnection.connect(dbsettings);
    var respo = await mysql.query(sqlString, values);
    await mysql.close();
    return respo;
  }
}

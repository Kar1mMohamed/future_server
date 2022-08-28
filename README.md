# Future Server

Please note you must read get_server guide to continue

## Getting Started

 Installing

Add Get to your pubspec.yaml file:

run `dart create project` and add to your pubspec:

```yaml
dependencies:
  future_get_server:
```

Import future_server in files that it will be used:

```dart
import 'package:future_get_server/future_server.dart';
```

### Future Server

What if you want to make the server wait untill you get the data from somewhere like firebase or MYSQL ?

Let me show you ..

First define yout Future, But make sure it will return a String


To create a server, and send a plain text:

```dart
void main() {
  runApp(
    FutureServer(
      home: Home(),
    ),
  );
}
```
Let's create a controller

```dart
class HomeController extends GetxController {}
```
and then define yout Future and make sure it will return a String
```dart
Future<String> getData() async {
    return Future.delayed(Duration(seconds: 3), () => 'Done');
}
```
and just put FutureWidget and now you have a perfect server
```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return FutureWidget(controller.getData());
  }
}
```
Now the server will return a 'Done' after 3 seconds.


But what if you want to use MSQL
 first you need to define settings

```dart
final dbSettings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'test',
    password: 'testpassowrd',
    db: 'test1');

final futureMYSQL = FutureMYSQL(dbsettings: dbSettings);
```

if you wonder how to use it .. here is it

```dart
  var fetch = await  futureMYSQL.futureFetch(fields: [], table: 'users');
```

This will fetch a fields in table users

 you can select fields by add them to the list --> futureMYSQL.futureFetch(fields: ['username','email'], table: 'users');

 You can also fetch user where id

 ```dart
   var results = await futureMYSQL.futureFetchWhere(
          fields: [],
          whereFields: ['id'],
          table: 'profiles',
          whereFieldsValues: ['1'],
        );
```


Please read get_server guide to understand what we are talking about
https://pub.dev/packages/get_server#

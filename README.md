# Future Server (get_server)

Please note you must read get_server guide to continue

## Getting Started

 Installing

Add Get to your pubspec.yaml file:

run `dart create project` and add to your pubspec:

```yaml
dependencies:
  future_get_server:
```

Import get in files that it will be used:

```dart
import 'package:future_get_server/future_server.dart';
```

But, what if you want to make the server wait untill you get the data from somewhere like firebase or MYSQL ?

Let me show you ..

First define yout Future, But make sure it will return a String


To create a server, and send a plain text:

```dart
void main() {
  runApp(
    GetServerApp(
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

Please read get_server guide to understand what we are talking about
https://pub.dev/packages/get_server#

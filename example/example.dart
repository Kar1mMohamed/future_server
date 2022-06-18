import 'package:future_server/future_server.dart';
import 'package:get_server/get_server.dart';

void main() async {
  runApp(GetServer(
    home: HomeView(),
  ));
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
}

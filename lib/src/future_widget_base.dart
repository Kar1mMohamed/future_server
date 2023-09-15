// import 'package:future_server/src/future_server_base.dart'
//     show SenderWidget, BuildContext, Widget, WidgetEmpty;

// class FutureWidget extends SenderWidget {
//   FutureWidget(this.future);

//   final Future future;

//   @override
//   Widget build(BuildContext context) {
//     if (context.request.method == 'OPTIONS') {
//       context.request.response!.header('Access-Control-Allow-Origin', '*');
//       context.request.response!.header(
//           'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');

//       context.request.response!.sendJson({'msg': 'ok'});

//       return WidgetEmpty();
//     } else {
//       return _BaseFuturerWidget(future);
//     }
//   }
// }

// class _BaseFuturerWidget extends SenderWidget {
//   _BaseFuturerWidget(this.future);
//   final Future future;

//   @override
//   Widget build(BuildContext context) {
//     future.then(
//       (value) {
//         var finalValue = value;
//         if (value is String) {
//           finalValue = {'msg': value};
//           context.request.response!.sendJson(finalValue);
//           return;
//         }
//         if (value is Map<dynamic, dynamic>) {
//           context.request.response!.sendJson(finalValue);
//           return;
//         }
//         if (value is Map<String, dynamic>) {
//           context.request.response!.sendJson(finalValue);
//           return;
//         }

//         if (value is Future<dynamic>) {
//           return;
//         } else {
//           return;
//         }
//       },
//     );
//     return WidgetEmpty();
//   }
// }

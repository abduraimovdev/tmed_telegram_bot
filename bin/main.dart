import 'dart:async';
import 'dart:isolate';

import 'log_service/log_service.dart';
import 'server/main.dart';
import 'storage/storage.dart';
import 'telegram/telegram.dart';

void main(List args) async {
  await LogService.init();

  await runZonedGuarded(
    () async {
      print(DateTime.now().toLocal().toString());

      Timer.periodic(
        Duration(minutes: 5),
        (timer) {
          print(DateTime.now().toLocal().toString());
        },
      );
      await Storage.initStorage();
      String? host;
      int? port;
      if (args.length >= 2) {
        host = args[0];
        port = int.tryParse(args[1]) ?? 8080;
      }
      mainServer(host, port);
      mainTelegram();
    },
    (error, stack) async {
      print(error);
      print(stack);
      await LogService.writeESLOG(error, stack);
    },
  );
}
//
// class RestartTimer {
//   static final _instance = RestartTimer._();
//
//   RestartTimer._();
//
//   factory RestartTimer() => _instance;
//
//   List<void Function()> functions = [];
//
//   void init() {
//     Timer.periodic(
//       Duration(seconds: 10),
//       (timer) {
//         print("RestartTimer running !");
//         run();
//       },
//     );
//   }
//
//   void run() {
//     for (int i = 0; i < functions.length; i++) {
//       functions[i]();
//     }
//   }
//
//   Future<void> add(Future<void> Function() func) async {
//     await func();
//     functions.add(func);
//   }
// }

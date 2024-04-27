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
      await HiveDB.initHive();
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

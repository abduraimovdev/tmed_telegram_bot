import 'dart:async';

import 'telegram/telegram.dart';
import '../log_service/log_service.dart';

Future<void> mainSQ(List args) async {
  await runZonedGuarded(
    () async {
      Timer.periodic(
        Duration(minutes: 5),
        (timer) {
          LogService.writeLog(DateTime.now().toString());
        },
      );
      await mainTelegram();
    },
    (error, stack) async {
      print(error);
      print(stack);
      await LogService.writeESLOG(error, stack);
    },
  );
}

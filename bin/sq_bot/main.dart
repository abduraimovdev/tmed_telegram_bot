import 'dart:async';

import 'telegram/telegram.dart';

void mainSQ(List args) async {
  await runZonedGuarded(
    () async {
      mainTelegram();
    },
    (error, stack) async {
      print(error);
      print(stack);
      // await LogService.writeESLOG(error, stack);
    },
  );
}

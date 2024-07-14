import 'dart:async';

import 'telegram/telegram.dart';

void mainSQ(List args) async {
  await runZonedGuarded(
    () async {
      Timer.periodic(
        Duration(minutes: 5),
        (timer) {
          print(DateTime.now().toString());
        },
      );
      mainTelegram();
    },
    (error, stack) async {
      print(error);
      print(stack);
      // await LogService.writeESLOG(error, stack);
    },
  );
}

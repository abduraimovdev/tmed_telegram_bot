import 'dart:async';
import 'dart:io';

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class LogService {
  static final File file = File("bin/log_service/log.txt");

  static Future<void> init() async {
    // if (!(await file.exists())) {
    //   await file.create();
    // }
  }

  static Future<String> loadLog() async {
    // final data = await file.readAsString();
    return "data";
  }

  static Future<void> writeLog(String log) async {
    await LogBot.sendMessage(log);
    // await file.writeAsString(await loadLog() + log);
  }

  static Future<void> clearAndWrite(String log) async {
    await LogBot.sendMessage(log);

    // await file.writeAsString(log);
  }

  static Future<void> writeESLOG(Object error, StackTrace stackTrace) async {

    String log = "Error :\n${error.toString()}\n\n StackTrace ${stackTrace.toString()}";
    await LogBot.sendMessage(log);

    // await file.writeAsString(log);
  }
}

class LogBot {
  static late TeleDart bot;
  static bool isInitialized = false;

  static Future<void> init() async {
    var botToken = '7175999350:AAHnib0ioHi37o9iEpq2CUlr4oe2pcCCQ6k';
    bot = TeleDart(botToken, Event((await Telegram(botToken).getMe()).username!));
    isInitialized = true;
  }

  static Future<void> sendMessage(String text) async {
    if (isInitialized) {
      await bot.sendMessage("@lo0gs", text);
    }
  }
}

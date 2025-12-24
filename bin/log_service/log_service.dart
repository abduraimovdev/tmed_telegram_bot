import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();

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
    print(log);
    await LogBot.sendMessage(log);
    // await file.writeAsString(await loadLog() + log);
  }

  static Future<void> clearAndWrite(String log) async {
    print(log);
    await LogBot.sendMessage(log);

    // await file.writeAsString(log);
  }

  static Future<void> writeESLOG(Object error, StackTrace stackTrace) async {
    print(error);
    print(stackTrace);

    String log = "Error :\n${error.toString()}\n\n StackTrace ${stackTrace.toString()}";
    await LogBot.sendMessage(log);

    // await file.writeAsString(log);
  }
}

class LogBot {
  static late TeleDart bot;
  static bool isInitialized = false;

  static Future<void> init() async {
    final token = env['tg_token'] ?? '';
    if (token.isEmpty) {
      print("LogBot: tg_token not set, skipping initialization");
      return;
    }
    bot = TeleDart(token, Event((await Telegram(token).getMe()).username!));
    isInitialized = true;
  }

  static Future<void> sendMessage(String text) async {
    if (isInitialized) {
      try {
        await bot.sendMessage("@lo0gs", text);
      } catch (e) {
        print("LogBot sendMessage error: $e");
      }
    }
  }
}

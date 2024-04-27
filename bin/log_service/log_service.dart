import 'dart:async';
import 'dart:io';

class LogService {
  static  final File file = File("bin/log_service/log.txt");

  static Future<void> init() async {
    if (!(await file.exists())) {
      await file.create();
    }
  }

  static Future<String> loadLog() async {
    final data = await file.readAsString();
    return data;
  }

  static Future<void> writeLog(String log) async {
    await file.writeAsString(await loadLog() + log);
  }

  static Future<void> clearAndWrite(String log) async {
    await file.writeAsString(log);
  }

  static Future<void> writeESLOG(Object error, StackTrace stackTrace) async {
    String log = "${await loadLog()} \n\n\n\n\n${DateTime.now().toString()}\n";
    log += "Error :\n${error.toString()}\n\n StackTrace ${stackTrace.toString()}";
    await file.writeAsString(log);
  }
}

import 'dart:async';
import 'dart:io';

import '../log_service/log_service.dart';
import 'server/main.dart';
import 'storage/storage.dart';
import 'telegram/telegram.dart';

Future<void> mainTmed(List<String> args) async {
  await LogService.init();

  print("📦 TMED Bot modullarini yuklash boshlandi...");

  try {
    print("📅 Vaqt: ${DateTime.now().toLocal()}");

    // Storage ni ishga tushirish (PostgreSQL ulanish)
    print("🗄️ Database ulanmoqda...");
    await Storage.initStorage();
    print("✅ Database ulandi!");

    // Server parametrlarini olish
    String host = '0.0.0.0';  // Railway uchun 0.0.0.0 bo'lishi kerak
    int port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
    
    if (args.length >= 2) {
      host = args[0];
      port = int.tryParse(args[1]) ?? port;
    }

    // HTTP Server ishga tushirish
    print("🌐 HTTP Server ishga tushmoqda...");
    await mainServer(host, port);
    print("✅ HTTP Server ishga tushdi: http://$host:$port");

    // Telegram Bot ishga tushirish
    print("🤖 Telegram Bot ishga tushmoqda...");
    await mainTelegramTmed();
    print("✅ Telegram Bot ishga tushdi!");

  } catch (error, stack) {
    print("❌ TMED Bot xatosi:");
    print(error);
    print(stack);
    await LogService.writeESLOG(error, stack);
    rethrow;  // Xatoni yuqoriga uzatish (retry uchun)
  }
}
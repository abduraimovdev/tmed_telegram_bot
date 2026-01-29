import 'dart:async';

import 'telegram/telegram.dart';
import '../log_service/log_service.dart';

Future<void> mainSQ(List<String> args) async {
  print("📦 SQ Bot modullarini yuklash boshlandi...");

  try {
    print("📅 Vaqt: ${DateTime.now().toLocal()}");

    // Telegram Bot ishga tushirish
    print("🤖 SQ Telegram Bot ishga tushmoqda...");
    await mainTelegram();
    print("✅ SQ Telegram Bot ishga tushdi!");

  } catch (error, stack) {
    print("❌ SQ Bot xatosi:");
    print(error);
    print(stack);
    await LogService.writeESLOG(error, stack);
    rethrow;  // Xatoni yuqoriga uzatish (retry uchun)
  }
}

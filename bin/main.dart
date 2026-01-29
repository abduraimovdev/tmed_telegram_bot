import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import './log_service/log_service.dart';
import './tmed_bot/main.dart';
import './sq_bot/main.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

final env = DotEnv(includePlatformEnvironment: true)..load();

/// Main entry point - Railway uchun long-running process
void main(List<String> args) async {
  // HTTP overrides o'rnatish (SSL sertifikat muammolari uchun)
  HttpOverrides.global = MyHttpOverrides();
  
  print("🚀 Bot ishga tushmoqda...");
  print("⏰ Vaqt: ${DateTime.now().toLocal()}");
  print("📋 Arguments: $args");

  // LogBot ni bir marta ishga tushirish
  await LogBot.init();

  // Har ikkala botni parallel ishga tushirish
  await Future.wait([
    runBot(bot: mainSQ, botName: "SQ", args: args),
    runBot(bot: mainTmed, botName: "TMED", args: args),
  ]);

  // 🔴 MUHIM: Processni yopilishdan saqlash (Railway uchun)
  // Bu cheksiz loop bot ishlashini ta'minlaydi
  await keepAlive();
}

/// Botni ishga tushirish va xatolarni qayta urinish
Future<void> runBot({
  required Future<void> Function(List<String> args) bot,
  required String botName,
  required List<String> args,
}) async {
  int retryCount = 0;
  const maxRetries = 10;
  
  while (true) {
    try {
      print("═══════════════════════════════════════════════════════════════════");
      print("🤖 $botName bot ishga tushmoqda...");
      print("🔗 Database host: ${env['db_host'] ?? 'belgilanmagan'}");
      print("═══════════════════════════════════════════════════════════════════");
      
      await bot(args);
      
      // Agar bot muvaffaqiyatli ishga tushsa, chiqamiz
      print("✅ $botName bot muvaffaqiyatli ishga tushdi!");
      break;
      
    } catch (e, s) {
      retryCount++;
      print("❌ $botName BOT XATOSI [$retryCount/$maxRetries]");
      print("Xato: $e");
      print("Stack: $s");
      
      if (retryCount >= maxRetries) {
        print("⚠️ $botName bot $maxRetries marta urinishdan keyin ishga tushmadi");
        break;
      }
      
      // Eksponensial kutish - har safar uzoqroq kutish
      final waitSeconds = retryCount * 5;
      print("⏳ $waitSeconds soniya kutilmoqda...");
      await Future.delayed(Duration(seconds: waitSeconds));
    }
  }
}

/// Processni tirik saqlash uchun heartbeat
Future<void> keepAlive() async {
  print("💓 Heartbeat ishga tushdi - bot tirik saqlanmoqda");
  
  // Har 30 sekundda signal berish
  Timer.periodic(Duration(seconds: 30), (timer) {
    // Hech narsa qilmaslik - faqat processni tirik saqlash
  });
  
  // Har 5 daqiqada log yozish
  Timer.periodic(Duration(minutes: 5), (timer) {
    print("💓 [${DateTime.now().toLocal()}] Bot faol ishlayapti");
  });
  
  // Cheksiz kutish - process hech qachon tugamaydi
  await Completer<void>().future;
}


import 'dart:io' as io;
import 'package:dotenv/dotenv.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import '../storage/storage.dart';
import 'reply_markup.dart';
import '../storage/sql/sql.dart';
import '../../log_service/log_service.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();

late TeleDart tmedBot;
int a = 0;
bool botStatus = false;

/// TMED Telegram botini ishga tushirish
Future<void> mainTelegramTmed() async {
  print("🤖 TMED Telegram Bot ishga tushmoqda...");

  var botToken = env['tmed_bot_token'] ?? '';
  if (botToken.isEmpty) {
    print("⚠️ TMED Bot: tmed_bot_token topilmadi, o'tkazib yuborilmoqda");
    return;
  }

  try {
    // Bot ma'lumotlarini olish
    final telegram = Telegram(botToken);
    final me = await telegram.getMe();
    final username = me.username;
    
    if (username == null) {
      throw Exception("Bot username olib bo'lmadi");
    }

    print("✅ Bot topildi: @$username");

    // TeleDart yaratish va ishga tushirish
    tmedBot = TeleDart(botToken, Event(username));
    
    // Listenerlarni sozlash
    _setupListeners();
    
    // Botni ishga tushirish
    tmedBot.start();
    botStatus = true;
    
    await LogService.writeLog("✅ TMED Bot ishga tushdi: @$username");
    print("✅ TMED Bot muvaffaqiyatli ishga tushdi!");

  } catch (e, s) {
    print("❌ TMED Bot ishga tushishda xato: $e");
    print(s);
    await LogService.writeESLOG(e, s);
    rethrow;
  }
}

/// Barcha listenerlarni sozlash
void _setupListeners() {

  // /start komandasi
  tmedBot.onMessage(entityType: 'bot_command', keyword: 'start').listen(
    (message) async {
      try {
        if (await Storage.checkUser(message.chat.id)) {
          await tmedBot.sendMessage(
            message.chat.id,
            "O'zbekiston Temir Yo'llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
            replyMarkup: AppReplyMarkUps.myFiles,
          );
        } else {
          await tmedBot.sendMessage(
            message.chat.id,
            "O'zbekiston Temir Yo'llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
            replyMarkup: AppReplyMarkUps.contact,
          );
        }
      } catch (e) {
        print("❌ /start xatosi: $e");
      }
    },
    onError: (e) => print("❌ /start listener xatosi: $e"),
  );

  // "Xulosa olish" tugmasi
  tmedBot.onMessage(keyword: "Xulosa olish").listen(
    (message) async {
      try {
        await getMyConclusion(message);
      } catch (e) {
        print("❌ Xulosa olish xatosi: $e");
      }
    },
    onError: (e) => print("❌ Xulosa olish listener xatosi: $e"),
  );

  // Kontakt xabarlari
  tmedBot.onMessage().listen(
    (message) async {
      try {
        if (message.contact != null) {
          if (await Storage.checkUser(message.chat.id)) {
            await message.reply("Oldin Ro'yhatdan o'tkansiz !");
          } else {
            await message.reply(
              "Ma'lumotlar tekshirilmoqda...",
              replyMarkup: AppReplyMarkUps.myFiles,
            );
            await Storage.saveUser(
              message.chat.id, 
              message.contact!.phoneNumber, 
              message.contact!.firstName, 
              message.contact?.lastName ?? ''
            );
            await getMyConclusion(message);
          }
        }
      } catch (e) {
        print("❌ Kontakt xatosi: $e");
      }
    },
    onError: (e) => print("❌ Message listener xatosi: $e"),
  );

  // /check komandasi (Developer uchun)
  tmedBot.onMessage(entityType: 'bot_command', keyword: 'check').listen(
    (message) async {
      try {
        if (message.chat.id == 475409665) {
          await tmedBot.sendMessage(
            message.chat.id,
            "✅ Telegram Bot ishlayapti!\n📅 Vaqt: ${DateTime.now().toLocal()}",
            replyMarkup: AppReplyMarkUps.myFiles,
          );
          await tmedBot.sendMessage(
            message.chat.id,
            "🗄️ Database holati: ${PostgresSettings().isConnected ? '✅ Ulangan' : '❌ Ulanmagan'}",
            replyMarkup: AppReplyMarkUps.myFiles,
          );
        }
      } catch (e) {
        print("❌ /check xatosi: $e");
      }
    },
    onError: (e) => print("❌ /check listener xatosi: $e"),
  );
  // /users komandasi (Developer uchun)
  tmedBot.onMessage(entityType: 'bot_command', keyword: 'users').listen(
    (message) async {
      try {
        if (message.chat.id == 475409665) {
          await tmedBot.sendMessage(
            message.chat.id,
            "📋 Foydalanuvchilar olinmoqda...",
          );
          int index = 0;
          for (var user in (await Storage.getUsers())) {
            index++;
            await tmedBot.sendMessage(
              message.chat.id,
              "Index : $index\nIsmi : ${user.firstName} ${user.lastName}\nTelefon Raqami : ${user.phone}",
            );
            await Future.delayed(Duration(milliseconds: 100));
          }
        }
      } catch (e) {
        print("❌ /users xatosi: $e");
      }
    },
    onError: (e) => print("❌ /users listener xatosi: $e"),
  );
}

/// Foydalanuvchi xulosalarini olish
Future<void> getMyConclusion(TeleDartMessage message) async {
  try {
    if (await Storage.checkUser(message.chat.id)) {
      final files = await Storage.getUserFiles(message.chat.id);
      if (files.isEmpty) {
        await message.reply("Xulosa yo'q");
      } else {
        await message.reply("📄 ${files.length} ta xulosa topildi, yuklanmoqda...");
        
        for (int i = 0; i < files.length; i++) {
          try {
            // PDF ni yuklab olish
            final pdfFile = await _downloadPdf(files[i].fileUrl, i);
            
            if (pdfFile != null) {
              // Fayl sifatida yuborish
              await tmedBot.sendDocument(
                message.chat.id, 
                pdfFile,
                caption: "${i + 1}-xulosa"
              );
              
              // Vaqtinchalik faylni o'chirish
              try {
                await pdfFile.delete();
              } catch (_) {}
            } else {
              await message.reply("❌ ${i + 1}-xulosani yuklab bo'lmadi");
            }
            
            await Future.delayed(Duration(milliseconds: 500));
          } catch (e) {
            print("❌ Fayl yuborishda xato [$i]: $e");
            await message.reply("❌ ${i + 1}-xulosani yuborishda xatolik");
          }
        }
      }
    } else {
      await message.reply("Iltimos Oldin tizimga nomeringizni jo'nating !");
    }
  } catch (e) {
    print("❌ getMyConclusion xatosi: $e");
    await message.reply("Xatolik yuz berdi, iltimos qayta urinib ko'ring.");
  }
}

/// URL dan PDF yuklab olish
Future<io.File?> _downloadPdf(String url, int index) async {
  try {
    print("📥 PDF yuklanmoqda: $url");
    
    final httpClient = io.HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;  // SSL muammolarini o'tkazish
    
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      // Vaqtinchalik fayl yaratish
      final tempDir = io.Directory.systemTemp;
      final fileName = 'xulosa_${DateTime.now().millisecondsSinceEpoch}_$index.pdf';
      final file = io.File('${tempDir.path}/$fileName');
      
      // Faylga yozish
      final bytes = await response.fold<List<int>>(
        <int>[],
        (List<int> previous, List<int> element) => previous..addAll(element),
      );
      
      await file.writeAsBytes(bytes);
      print("✅ PDF yuklandi: ${file.path} (${bytes.length} bytes)");
      
      return file;
    } else {
      print("❌ PDF yuklab bo'lmadi: HTTP ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("❌ PDF yuklash xatosi: $e");
    return null;
  }
}

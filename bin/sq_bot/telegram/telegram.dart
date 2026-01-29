import 'package:dotenv/dotenv.dart';
import 'package:image/image.dart';
import 'package:qr_image/qr_image.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'dart:io' as io;
import 'reply_markup.dart';
import './models/user_steps.dart';
import '../../log_service/log_service.dart';

part './utils.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();

late TeleDart bot;
bool botStatus = false;
Map<int, UserSteps> users = {};
Map<num, String> admins = {
  7013088721: "Tizim Administrator",
  179975021: "Farxod aka",
  386490112: "SQ ADMIN",
  364790033: "SQ ADMIN",
  475409665: "OWNER",
  1619314211: "Farrux aka",
};

Future<void> mainTelegram() async {
  for (var item in admins.entries) {
    await LogBot.sendMessage("User Id : ${item.key} : \nName : ${item.value}");
  }
  await start(
    onStart: () {
      // Command : START
      bot.onMessage(entityType: 'bot_command', keyword: 'start').listen((message) async {
        final name = getUser(message.text ?? '');
        if (name != null) {
          // if (!users.containsKey(message.chat.id)) {
          users[message.chat.id] = UserSteps(name: name.$1, lastName: name.$2, step: 1);
          // }
          bot.sendMessage(
            message.chat.id,
            "Xabar qoldirish uchun telefon raqamingizni yuboring!",
            replyMarkup: AppReplyMarkUps.contact,
          );
        } else {
          bot.sendPhoto(
            message.chat.id,
            "https://t.me/server_picture/546",
            caption: """Assalomu alaykum HI TECH LAB Klinikasi botiga xush kelibsiz!
Ushbu bot orqali klinikamizda ko’rsatilayotgan xizmatlardan yo’ki xodimlar ish vaqtida sizga bo’lgan munosabatdan taklif va etirozingiz bo’lsa fikr mulohazalaringizni yuborishingiz mumkin!
Sizning xabaringiz tez ko’rib chiqiladi va javobini beramiz.

Sog’ligingizni extiyot qiling! 
Klinikamiz xizmatlaridan foydalanganingiz uchun tashakkur!

Xabar qoldirish uchun telefon raqamingizni yuboring!""",
            replyMarkup: AppReplyMarkUps.none,
          );
        }
      });

      // STEPS
      bot.onMessage().listen((message) async {
        secondStep(
          message,
          onContactSend: (String name, String lastName) {
            message.reply(
              'Iltimos ushbu ($name $lastName) xodim uchun fikringizni qoldiring!',
              replyMarkup: AppReplyMarkUps.none,
            );
          },
          onFinished: () {
            message.reply(
              'Sizning xabaringiz tez ko’rib chiqiladi va javobini beramiz.\n\nSog’ligingizni extiyot qiling!\nKlinikamiz xizmatlaridan foydalanganingiz uchun tashakkur!',
              replyMarkup: AppReplyMarkUps.none,
            );
          },
          other: () {
            bot.sendPhoto(
              message.chat.id,
              "https://t.me/server_picture/546",
              caption: "Yangi xabar qoldirmoqchi bo’lsangiz, mutaxxassis QR kodini qayta skanerlang!",
              replyMarkup: AppReplyMarkUps.none,
            );
            // bot.sendMessage(
            //   message.chat.id,
            //   "Botdan foydalanish uchun shifokorning QR kodini kameraga yo'natiring",
            //   replyMarkup: AppReplyMarkUps.none,
            // );
          },
        );
      });

      // QR CODE
      bot.onMessage().listen((event) async {
        print(event.chat.id);
        if (admins.containsKey(event.chat.id)) {
          final name = event.text?.split(' ');
          if (name != null && name.length == 2) {
            final image = await textQrImage(name[0], name[1]);
            bot.sendDocument(
              event.chat.id,
              image,
            );
          }
        }
      });
    },
    onError: () {},
  );
}

Future<void> start({required void Function() onStart, required void Function() onError}) async {
  try {
    print("🤖 SQ Telegram Bot ishga tushmoqda...");

    var botToken = env['sq_bot_token'] ?? '';
    if (botToken.isEmpty) {
      print("⚠️ SQ Bot: sq_bot_token topilmadi, o'tkazib yuborilmoqda");
      return;
    }
    
    final telegram = Telegram(botToken);
    final me = await telegram.getMe();
    final username = me.username;
    
    if (username == null) {
      throw Exception("Bot username olib bo'lmadi");
    }
    
    print("✅ SQ Bot topildi: @$username");
    
    bot = TeleDart(botToken, Event(username));
    bot.start();
    
    await LogService.writeLog("✅ SQ Bot ishga tushdi: @$username");
    print("✅ SQ Bot muvaffaqiyatli ishga tushdi!");
    
    onStart();
  } catch (e, s) {
    print("❌ SQ Bot ishga tushishda xato: $e");
    print(s);
    await LogService.writeLog("❌ SQ botdan xato: $e");
    await LogService.writeESLOG(e, s);
    onError();
    rethrow;
  }
}

void secondStep(
  TeleDartMessage message, {
  required void Function(String name, String lastName) onContactSend,
  required void Function() onFinished,
  required void Function() other,
}) {
  if (message.contact != null) {
    if (users.containsKey(message.chat.id)) {
      final doctor = users[message.chat.id];
      if (doctor!.step == 1) {
        users[message.chat.id] = users[message.chat.id]!.copyWith(
          step: 2,
          phone: message.contact!.phoneNumber,
        );
        onContactSend(doctor.name, doctor.lastName);
      }
    }
  } else {
    if (users.containsKey(message.chat.id)) {
      final doctor = users[message.chat.id];
      if (doctor!.step == 2) {
        sendData(users[message.chat.id]!.copyWith(step: 3, text: message.text));
        users.remove(message.chat.id);
        onFinished();
      }
    } else {
      other();
    }
  }
}

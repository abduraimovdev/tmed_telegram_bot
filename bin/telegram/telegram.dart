import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import '../storage/storage.dart';
import 'reply_markup.dart';

late final TeleDart teledart;

void mainTelegram() async {
  print("Running Telegram Bot...");
  var botToken = '7160370195:AAG2H4soUx2ZaOpSjNOkb7bARdqFXhfTLUY';
  final username = (await Telegram(botToken).getMe()).username;
  teledart = TeleDart(botToken, Event(username!));

  teledart.start();

  teledart.onMessage(entityType: 'bot_command', keyword: 'start').listen(
    (message) async {
      if (await HiveDB.checkUser(message.chat.id.toString())) {
        teledart.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.myFiles,
        );
      } else {
        teledart.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.contact,
        );
      }
    },
  );

  teledart.onMessage(keyword: "Xulosa olish").listen((message) async {
    await getMyConclusion(message);
  });

  teledart.onMessage().listen((message) async {
    if (message.contact != null) {
      if (await HiveDB.checkUser(message.chat.id.toString())) {
        message.reply("Oldin Ro'yhatdan o'tkansiz !");
      } else {
        message.reply(
          "Ma'lumotlar tekshirilmoqda...",
          replyMarkup: AppReplyMarkUps.myFiles,
        ).whenComplete(() {
          HiveDB.saveUser(message.chat.id.toString(), message.contact!.phoneNumber, message.contact!.firstName, message.contact?.lastName ?? '').whenComplete(() {
            getMyConclusion(message);
          });
        });

      }
    }
  });
}

Future<void> getMyConclusion(TeleDartMessage message) async {
  if (await HiveDB.checkUser(message.chat.id.toString())) {
    final files = await HiveDB.getUserFiles(message.chat.id.toString());
    if (files.isEmpty) {
      message.reply("Xulosa yo’q");
    } else {
      for (int i = 0; i < files.length; i++) {
        teledart.sendDocument(message.chat.id, files[i].fileUrl, caption: "${i+1} : Xulosa");
      }
    }
  } else {
    message.reply("Iltimos Oldin tizimga nomeringizni jo'nating !");
  }
}


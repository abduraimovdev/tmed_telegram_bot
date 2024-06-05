import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import '../storage/storage.dart';
import '../main.dart';
import 'reply_markup.dart';

late TeleDart bot;
int a = 0;
bool botStatus = false;

void mainTelegram() async {
  print("Running Telegram Bot...");

  var botToken = '7160370195:AAG2H4soUx2ZaOpSjNOkb7bARdqFXhfTLUY';
  final username = (await Telegram(botToken).getMe()).username;
  bot = TeleDart(botToken, Event(username!));
  bot.start();
  print("Starting bot");

  bot.onMessage(entityType: 'bot_command', keyword: 'start').listen(
    (message) async {
      if (await Storage.checkUser(message.chat.id)) {
        bot.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.myFiles,
        );
      } else {
        bot.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.contact,
        );
      }
    },
  );

  bot.onMessage(keyword: "Xulosa olish").listen((message) async {
    await getMyConclusion(message);
  });

  bot.onMessage().listen((message) async {
    if (message.contact != null) {
      if (await Storage.checkUser(message.chat.id)) {
        message.reply("Oldin Ro'yhatdan o'tkansiz !");
      } else {
        message
            .reply(
          "Ma'lumotlar tekshirilmoqda...",
          replyMarkup: AppReplyMarkUps.myFiles,
        )
            .whenComplete(() {
          Storage.saveUser(message.chat.id, message.contact!.phoneNumber, message.contact!.firstName, message.contact?.lastName ?? '').whenComplete(() {
            getMyConclusion(message);
          });
        });
      }
    }
  });
}

Future<void> getMyConclusion(TeleDartMessage message) async {
  if (await Storage.checkUser(message.chat.id)) {
    final files = await Storage.getUserFiles(message.chat.id);
    if (files.isEmpty) {
      message.reply("Xulosa yo’q");
    } else {
      for (int i = 0; i < files.length; i++) {
        bot.sendDocument(message.chat.id, files[i].fileUrl, caption: "${i + 1} : Xulosa");
      }
    }
  } else {
    message.reply("Iltimos Oldin tizimga nomeringizni jo'nating !");
  }
}

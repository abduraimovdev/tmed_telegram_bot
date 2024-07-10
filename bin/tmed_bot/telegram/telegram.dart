import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import '../storage/storage.dart';
import 'reply_markup.dart';
import '../storage/sql/sql.dart';

late TeleDart tmedBot;
int a = 0;
bool botStatus = false;

void mainTelegramTmed() async {
  print("Running Telegram Bot...");

  var botToken = '7160370195:AAG2H4soUx2ZaOpSjNOkb7bARdqFXhfTLUY';
  final username = (await Telegram(botToken).getMe()).username;
  tmedBot = TeleDart(botToken, Event(username!));
  tmedBot.start();
  print("Starting bot TMED");

  tmedBot.onMessage(entityType: 'bot_command', keyword: 'start').listen(
    (message) async {
      if (await Storage.checkUser(message.chat.id)) {
        tmedBot.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.myFiles,
        );
      } else {
        tmedBot.sendPhoto(
          message.chat.id,
          "https://t.me/t_med_log/3330",
          caption: "O’zbekiston Temir Yo’llari Ijtimoiy Xizmatlar Muassasasi \nTMED botiga xush kelibsiz\n\nXulosangizni olish uchun iltimos telefon raqamingizni yuboring",
          replyMarkup: AppReplyMarkUps.contact,
        );
      }
    },
  );

  tmedBot.onMessage(keyword: "Xulosa olish").listen((message) async {
    await getMyConclusion(message);
  });

  tmedBot.onMessage().listen((message) async {
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

  // For Developer
  tmedBot.onMessage(entityType: 'bot_command', keyword: 'check').listen(
    (message) async {
      if (message.chat.id == 475409665) {
        tmedBot.sendMessage(
          message.chat.id,
          "Telegram Bot is Working !!!",
          replyMarkup: AppReplyMarkUps.myFiles,
        );
        tmedBot.sendMessage(
          message.chat.id,
          "Sql is Working : ${PostgresSettings().isConnected}",
          replyMarkup: AppReplyMarkUps.myFiles,
        );
      }
    },
  );
  tmedBot.onMessage(entityType: 'bot_command', keyword: 'users').listen(
    (message) async {
      if (message.chat.id == 475409665) {
        tmedBot.sendMessage(
          message.chat.id,
          "Foydalanuvchilar olinmoqda...",
        );
        int index = 0;
        for (var user in (await Storage.getUsers())) {
          index++;
          tmedBot.sendMessage(
            message.chat.id,
            "Index : $index\nIsmi : ${user.firstName} ${user.lastName}\nTelefon Raqami : ${user.phone}",
          );
        }
      }
    },
  );
}

Future<void> getMyConclusion(TeleDartMessage message) async {
  if (await Storage.checkUser(message.chat.id)) {
    final files = await Storage.getUserFiles(message.chat.id);
    if (files.isEmpty) {
      message.reply("Xulosa yo’q");
    } else {
      for (int i = 0; i < files.length; i++) {
        tmedBot.sendDocument(message.chat.id, files[i].fileUrl, caption: "${i + 1} : Xulosa");
      }
    }
  } else {
    message.reply("Iltimos Oldin tizimga nomeringizni jo'nating !");
  }
}

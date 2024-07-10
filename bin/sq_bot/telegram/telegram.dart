import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'reply_markup.dart';

late TeleDart bot;
int a = 0;
bool botStatus = false;
Map<int, UserSteps> users = {};

void mainTelegram() async {
  print("Running Telegram Bot...");

  var botToken = '7050031910:AAEQUt7SD8xfrs6hljJkbBhCUW6_N3htSkU';
  final username = (await Telegram(botToken).getMe()).username;
  bot = TeleDart(botToken, Event(username!));
  bot.start();
  print("Starting bot SQ");

  bot
      .onMessage(
    entityType: 'bot_command',
    keyword: 'start',
  )
      .listen((message) async {
    final name = getUser(message.text ?? '');
    if (name != null) {
      // if (!users.containsKey(message.chat.id)) {
      users[message.chat.id] = UserSteps(name: name.$1, lastName: name.$2, step: 1);
      // }
      bot.sendMessage(
        message.chat.id,
        "Iltimos Telefon raqamingizni yozing",
        replyMarkup: AppReplyMarkUps.contact,
      );
    } else {
      bot.sendMessage(
        message.chat.id,
        "Assalomu Aleykum botga xush kelibsiz botdan foydalanish uchun shifokorning QR kodini kameraga yo'natiring",
      );
    }
  });

  bot.onMessage().listen((message) async {
    if (message.contact != null) {
      if (users.containsKey(message.chat.id)) {
        final doctor = users[message.chat.id];
        if (doctor!.step == 1) {
          users[message.chat.id] = users[message.chat.id]!.copyWith(
            step: 2,
            phone: message.contact!.phoneNumber,
          );
          message.reply(
            'Iltimos bu (${doctor.name} ${doctor.lastName}) shifokor uchun fikringizni qoldiring !',

          );
        }
      }
    } else {
      if (users.containsKey(message.chat.id)) {
        final doctor = users[message.chat.id];
        if (doctor!.step == 2) {
          sendData(users[message.chat.id]!.copyWith(step: 3, text: message.text));
          users.remove(message.chat.id);
          message.reply('Xulosangiz admin uchun yuborildi');
        }
      }
    }
  });
}

(String name, String lastName)? getUser(String text) {
  if (text.contains("0") && text.contains('1')) {
    final startIndex = text.indexOf('0');
    final name = (text.substring(startIndex + 1, text.length - 1)).split('1');
    if (name.length == 2) {
      print("Success");
      return (name[1], name[0]);
    } else {
      return null;
    }
  } else {
    return null;
  }
}

class UserSteps {
  final String name;
  final String lastName;
  final int step;
  final String text;
  final String phone;

  const UserSteps({
    this.name = '',
    this.lastName = '',
    this.step = 0,
    this.text = '',
    this.phone = '',
  });

  UserSteps copyWith({
    String? name,
    String? lastName,
    int? step,
    String? text,
    String? phone,
  }) {
    return UserSteps(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      step: step ?? this.step,
      text: text ?? this.text,
      phone: phone ?? this.phone,
    );
  }
}

void sendData(UserSteps data) {
  bot.sendMessage('@sq_logs', """
Shifokor : ${data.lastName} ${data.lastName}
Jo'natuvchining raqami : ${data.phone}
Shikoyati : ${data.text}
""");
}

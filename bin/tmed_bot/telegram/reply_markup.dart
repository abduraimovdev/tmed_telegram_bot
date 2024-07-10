import 'package:teledart/model.dart';

sealed class AppReplyMarkUps {
  static final myFiles = ReplyKeyboardMarkup(
    resizeKeyboard: true,
    keyboard: [
      [
        KeyboardButton(text: 'Xulosa olish'),
      ]
    ],
  );

  static final contact = ReplyKeyboardMarkup(
    resizeKeyboard: true,
    keyboard: [
      [
        KeyboardButton(text: "Telefon raqam yuborish", requestContact: true),
      ]
    ],
  );
}


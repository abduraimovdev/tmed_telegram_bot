import 'package:teledart/model.dart';

sealed class AppReplyMarkUps {
  static final none = ReplyKeyboardRemove(removeKeyboard: true);

  static final contact = ReplyKeyboardMarkup(
    oneTimeKeyboard: true,
    resizeKeyboard: true,
    keyboard: [
      [
        KeyboardButton(text: "Telefon raqam yuborish", requestContact: true),
      ]
    ],
  );

  static final start = ReplyKeyboardMarkup(
    oneTimeKeyboard: true,
    resizeKeyboard: true,
    keyboard: [
      [
        KeyboardButton(text: "start"),
      ]
    ],
  );
}

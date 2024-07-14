part of './telegram.dart';

void sendData(UserSteps data) {
  bot.sendMessage('@hitechlabchannel', """
Shifokor : ${data.name} ${data.lastName}
Jo'natuvchining raqami : ${data.phone}
Shikoyati : ${data.text}
""");
}

Future<io.File> textQrImage(String name, lastName) async {
  var img1 = QRImage(
    "https://t.me/Hitechlab_support_bot?start=0${lastName}1${name}0",
    size: 300,
    backgroundColor: ColorUint8.rgb(255, 255, 255),
  ).generate();
  final file = io.File("./images/img.png");
  await file.writeAsBytes(encodePng(img1));
  return file;
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

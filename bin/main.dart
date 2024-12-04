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
void main(List args) async {
  while(true) {
    runBot(args);
  }
}



void runBot(List args) async{
  try {
    print(args);
    print("--------------------------------------------");
    print(env['host']);
    print("--------------------------------------------");
    await LogBot.init();
    mainTmed(args);
    mainSQ(args);
  } catch (e, s) {
    print(
        "-----------------------------ERROR---------------------------------");
    print(e);
    print(s);
    print(
        "-----------------------------ERROR END---------------------------------");
    main(args);
  }
}
import 'package:dotenv/dotenv.dart';
import './log_service/log_service.dart';
import './tmed_bot/main.dart';
import './sq_bot/main.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();
void main(List args) async {
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

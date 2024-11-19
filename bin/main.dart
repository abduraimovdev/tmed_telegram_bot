import 'package:dotenv/dotenv.dart';

import './tmed_bot/main.dart';
import './sq_bot/main.dart';
import './log_service/log_service.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();
void main(List args) async {
  await LogBot.init();
  mainTmed(args);
  mainSQ(args);
}

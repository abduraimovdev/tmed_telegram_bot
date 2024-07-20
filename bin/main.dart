import './tmed_bot/main.dart';
import './sq_bot/main.dart';
import './log_service/log_service.dart';

void main(List args) async {
  await LogBot.init();
  mainTmed(args);
  mainSQ(args);
}

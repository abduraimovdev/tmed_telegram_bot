
import 'server/server.dart';
import 'storage/storage.dart';
import 'telegram/telegram.dart';

void main(List args) async{
  await HiveDB.initHive();
  String? host;
  int? port;
  if(args.length >= 2) {
    host = args[0];
    port = int.tryParse(args[1]) ?? 8080;
  }
  print(host);
  print(port);
  mainServer(host, port);
  mainTelegram();
}
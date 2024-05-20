import 'package:shelf/shelf_io.dart' as shelf_io;
import '../log_service/log_service.dart';
import 'service.dart';

/// Similar with the previous example but here we create the routing in our new class 'Service' and we call its handler.
void mainServer(String? host, int? port) async {
  print("Running Server...");

  final service = Service();

  final server = await shelf_io.serve(service.handler,  port ?? 8080);

  await LogService.writeLog("Serving at http://${server.address.host}:${server.port}");

  print('Serving at http://${server.address.host}:${server.port}');
}

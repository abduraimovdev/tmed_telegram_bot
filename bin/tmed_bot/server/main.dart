import 'package:shelf/shelf_io.dart' as shelf_io;
import '../../log_service/log_service.dart';
import 'service.dart';

/// HTTP Server ishga tushirish
Future<void> mainServer(String? host, int? port) async {
  final serverHost = host ?? '0.0.0.0';  // Railway uchun 0.0.0.0 kerak
  final serverPort = port ?? 8080;
  
  await LogService.writeLog("🌐 HTTP Server ishga tushmoqda...");

  try {
    final service = Service();
    final server = await shelf_io.serve(
      service.handler, 
      serverHost, 
      serverPort,
    );

    await LogService.writeLog("✅ Server ishga tushdi: http://${server.address.host}:${server.port}");
    print('✅ HTTP Server: http://${server.address.host}:${server.port}');
    
  } catch (e, s) {
    print("❌ HTTP Server ishga tushishda xato: $e");
    print(s);
    await LogService.writeESLOG(e, s);
    rethrow;
  }
}

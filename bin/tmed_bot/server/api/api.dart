import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'api_response.dart';
import '../../storage/sql/sql.dart';

class Api {

  final response = ApiResponse();

  Future<Response> _route(Request request) async {
    String route = "";
    route += "Get : /send-telegram/\n";
    route += "Get : /health\n";
    return Response.ok(route);
  }

  /// Health check endpoint - Railway uchun
  Future<Response> _healthCheck(Request request) async {
    final dbStatus = PostgresSettings().isConnected;
    final status = {
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'database': dbStatus ? 'connected' : 'disconnected',
      'uptime': 'running',
    };
    
    return Response.ok(
      jsonEncode(status),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Router get router {
    final router = Router();

    router.get('/', _route);
    router.get('/health', _healthCheck);  // Health check endpoint
    router.get('/send-telegram/', response.sendTelegram);
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}



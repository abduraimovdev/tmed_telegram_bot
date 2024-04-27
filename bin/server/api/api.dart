import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'api_response.dart';

class Api {

  final response = ApiResponse();

  Future<Response> _route(Request request) async {
     String route = "";
    route += "Get : /send-telegram/\n";
    return Response.ok(route);
  }
  Router get router {
    final router = Router();

    router.get('/', _route);
    router.get('/send-telegram/',  response.sendTelegram);
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}

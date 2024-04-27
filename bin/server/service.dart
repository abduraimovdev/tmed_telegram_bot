import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'api/api.dart';

/// Class used to set up all the routing for your server
class Service {
  final _swagger = SwaggerUI('swagger.yaml', title: 'Swagger Test');
  Handler get handler {
    // Router
    final router = Router();

    router.mount('/swagger', _swagger.call);
    router.mount('/api/', Api().router.call);
    // router.get('/swagger/', _swagger.call);
    // Other End point block
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found');
    });


    return router.call;
  }
}

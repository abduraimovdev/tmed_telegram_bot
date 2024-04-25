import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../storage/storage.dart';

void mainServer(String? host, int? port) async {
  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  var server = await shelf_io.serve(handler, host ?? '0.0.0.0', port ?? 8080);

  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _echoRequest(Request request) async {
  try {
    final body = jsonDecode(await request.readAsString()) as Map;
    if (request.headers.containsKey("code") && request.headers["code"] == "0000" && body.containsKey("phone") && body.containsKey("file_url")) {
      HiveDB.saveFile(body["file_url"], body["phone"]);
      return Response.ok('Successfully Saved');
    } else {
      return Response.badRequest(body: "Data is failed ");
    }
  } catch (e) {
    return Response.badRequest(body: "Data is failed !");
  }
}

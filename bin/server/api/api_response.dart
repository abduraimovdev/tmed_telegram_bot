import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../storage/storage.dart';

class ApiResponse {
  Future<Response> sendTelegram(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map;
      if (request.headers.containsKey("code") && request.headers["code"] == "0000" && body.containsKey("phone") && body.containsKey("file_url")) {
        Storage.saveFile(body["file_url"], body["phone"]);
        return Response.ok('Successfully Saved');
      } else {
        return Response.badRequest(body: "Data is failed ");
      }
    } catch (e) {
      return Response.badRequest(body: "Data is failed !");
    }
  }
}
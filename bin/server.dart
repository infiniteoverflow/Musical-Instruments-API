import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:path/path.dart' as path;

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler);

Future<Response> _rootHandler(Request req) async {
  final targetFile =
    File(path.join(path.dirname(Platform.script.toFilePath()), 'Musical_Instruments_5.json'));
  if (await targetFile.exists()) {
    print('Serving data from $targetFile');
    String fileContent = await targetFile.readAsString();
    return Response.ok(fileContent);
  } else {
    print("$targetFile doesn't exists, stopping");
    return Response.ok(jsonEncode({'Error':'file not found'}));
  }
}

Response _echoHandler(Request request) {
  final message = params(request, 'message');
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}

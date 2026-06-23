// Servidor estático simples para visualizar build/web localmente.
// Usado porque o Smart App Control impede o flutter de spawnar processos,
// mas um HttpServer em Dart só abre um socket (não cria processo-filho).
import 'dart:io';

const root = 'build/web';
const port = 8080;

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json',
};

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Servindo $root em http://localhost:$port');
  await for (final req in server) {
    try {
      var path = req.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';
      var file = File('$root$path');
      if (!await file.exists()) {
        // SPA fallback para rotas do app
        file = File('$root/index.html');
      }
      final ext = path.contains('.') ? path.substring(path.lastIndexOf('.')) : '';
      req.response.headers.contentType =
          ContentType.parse(mime[ext] ?? 'application/octet-stream');
      // Headers necessários p/ CanvasKit (cross-origin isolation)
      req.response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      req.response.headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
      await req.response.addStream(file.openRead());
      await req.response.close();
    } catch (e) {
      req.response.statusCode = HttpStatus.internalServerError;
      await req.response.close();
    }
  }
}

import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  // Create a handler for serving static files
  final staticHandler = createStaticHandler('public', defaultDocument: 'index.html');

  // Create a handler for processing form submissions
  final formHandler = shelf.Pipeline().addMiddleware(shelf.logRequests())
      .addHandler(_handleRequest);

  // Cascade the handlers
  final cascade = shelf.Cascade()
      .add(staticHandler)
      .add(formHandler);

  // Start the server
  final server = await io.serve(cascade.handler, InternetAddress.anyIPv4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _handleRequest(shelf.Request request) async {
  if (request.method == 'POST' && request.url.path == 'submit-form') {
    final payload = await request.readAsString();
    final params = Uri.splitQueryString(payload);

    final name = params['name'] ?? '';
    final email = params['email'] ?? '';
    final message = params['message'] ?? '';

    try {
      await _sendEmail(name, email, message);
      return shelf.Response.ok('Thank you for your message. We\'ll get back to you soon!');
    } catch (e) {
      print('Error sending email: $e');
      return shelf.Response.internalServerError(body: 'Oops! Something went wrong. Please try again later.');
    }
  }

  return shelf.Response.notFound('Not found');
}

Future<void> _sendEmail(String name, String email, String message) async {
  final smtpServer = gmail('papasmerf916@gmail.com', 'mgma uvhc kobp ljxz');

  final emailMessage = Message()
    ..from = Address('papasmerf916@gmail.com', 'Skrzat')
    ..recipients.add('news@dreamweb.space')
    ..subject = 'New Contact Form Submission'
    ..text = 'Name: $name\nEmail: $email\n\nMessage:\n$message';

  try {
    final sendReport = await send(emailMessage, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } catch (e) {
    print('Error sending email: $e');
    throw e;
  }
}

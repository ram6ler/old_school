import "package:web/web.dart" as web;
import 'package:old_school/old_school.dart';

main() async {
  final terminal = Terminal(
    rows: 25,
    columns: 40,
    container: web.document.getElementById("hello")! as web.HTMLElement,
  );
  terminal.output("Hello, world!");
  final response = await terminal.input(
    prompt: "What is your name? ",
    length: 20,
  );
  terminal.output("Hello, $response!");
}

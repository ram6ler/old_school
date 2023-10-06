import "dart:html";
import "package:old_school/src/terminal.dart";

void main() async {
  final terminal = Terminal(
      rows: 24,
      columns: 40,
      container: document.getElementById("terminal")! as DivElement);

  terminal
    ..output("Hello, world!")
    ..output("Goodbye, world!");
  final name = await terminal.input(prompt: "What is your name? ", length: 10);
  terminal.output("Hello, $name!");
  while (true) {
    final click = await terminal.inputMouseClick();
    print(click);
    terminal.screen.setPixelOn(
        pixelRow: click.pixelRow,
        pixelColumn: click.pixelColumn,
        color: "pink");
  }
}

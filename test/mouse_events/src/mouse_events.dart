import "dart:html";
import "dart:math" show Random;
import "package:web/web.dart" as web;
import "package:old_school/old_school.dart";

void main() {
  final rand = Random(),
      container = document.getElementById("mouse_events")! as web.HTMLElement,
      display = document.getElementById("mouse_events_data")!,
      showInfo = (Terminal t, MouseData d) {
        display..innerHtml = d.toString().replaceAll("\n", "<br>");
      },
      t = Terminal(
        rows: 5,
        columns: 5,
        container: container,
        whenMouseEntersTerminal: (t, d) {
          display.children.add(ParagraphElement()..innerHtml = "Enter!");

          showInfo(t, d);
        },
        whenMouseIsClicked: (t, d) {
          display.children.add((ParagraphElement())..innerHtml = "Click!");
          showInfo(t, d);
        },
        whenMouseIsMoved: (t, d) {
          display.children.add((ParagraphElement())..innerHtml = "Move!");
          showInfo(t, d);
        },
        whenMouseLeavesTerminal: (t, d) {
          display.children.add((ParagraphElement())..innerHtml = "Exit!");
          showInfo(t, d);
        },
        scrolls: false,
        pixelWidth: 5,
        pixelHeight: 5,
      );
  for (var r = 0; r < 5; r++)
    for (var c = 0; c < 5; c++)
      t
        ..setCharacter(
          row: r,
          column: c,
          character: String.fromCharCode(32 + rand.nextInt(50)),
        )
        ..setColor(
            row: r,
            column: c,
            color: [
              "red",
              "lime",
              "yellow",
              "skyblue",
              "lightgray",
              "purple",
              "orange",
              "white"
            ][rand.nextInt(8)]);
}

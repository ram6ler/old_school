import "dart:math" show Random;
import "package:web/web.dart" as web;
import "package:old_school/old_school.dart" as os;
import "package:old_school/special_characters.dart" as osc;

Future<void> main() async {
  final container = (web.document.querySelector("#multiple")
      as web.HTMLDivElement)
    ..style.width = "fit-content";
  container.style
    ..display = "grid"
    ..gap = "1em"
    ..gridTemplateColumns = "auto auto auto"
    ..gridTemplateColumns = "auto auto auto";

  final terminals = <List<os.Terminal>>[];
  for (var r = 0; r < 3; r++) {
    terminals.add(<os.Terminal>[]);
    for (var c = 0; c < 3; c++) {
      final div = (web.document.createElement("div") as web.HTMLDivElement)
        ..style.width = "fit-content";
      terminals[r].add(os.Terminal(
        rows: 10,
        columns: 10,
        container: div,
        isInteractive: false,
      ));
      container.appendChild(div);
    }
  }
  final random = Random(),
      character = osc.musicalNote,
      colors = ["pink", "skyblue", "white", "limegreen", "purple"];

  while (true) {
    final row = random.nextInt(3),
        column = random.nextInt(3),
        x = random.nextInt(10),
        y = random.nextInt(10),
        color = colors[random.nextInt(colors.length)];

    terminals[row][column]
      ..setColor(row: y, column: x, color: color)
      ..setCharacter(row: y, column: x, character: character);
    await Future.delayed(Duration(milliseconds: 250));
  }
}

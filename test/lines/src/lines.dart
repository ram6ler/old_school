import "dart:math" show sin, cos, pi;
import "package:web/web.dart" as web;
import "package:old_school/old_school.dart";

void main() {
  final terminal = Terminal(
        rows: 20,
        columns: 20,
        container: web.document.getElementById("lines")! as web.HTMLElement,
        rowGap: 0,
      ),
      n = 12;
  (int pixelRow, int pixelColumn) vertex(int pr, int pc, int r, int k) => (
        (pr + r * sin(k * 2 * pi / n)).toInt(),
        (pr + r * cos(k * 2 * pi / n)).toInt(),
      );
  for (var i = 0; i < n; i++) {
    final p1 = vertex(80, 80, 78, i);
    for (var j = 0; j < n; j++) {
      if (j == i) continue;
      final p2 = vertex(80, 80, 78, j);
      terminal.screen.line(from: p1, to: p2);
    }
  }
}

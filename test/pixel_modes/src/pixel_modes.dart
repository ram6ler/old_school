import "dart:html";
import "package:old_school/old_school.dart";

void main() async {
  print("hello");
  final terminal = Terminal(
        rows: 28,
        columns: 24,
        container: document.getElementById("pixel_modes")!,
        isInteractive: true,
        whenMouseIsClicked: (t, d) {
          print(d);
          final pixelRow = d.pixelRow ~/ t.screen.pixelHeight,
              pixelColumn = d.pixelColumn ~/ t.screen.pixelWidth;
          print(t.screen.getPixelColor(pixelRow, pixelColumn));
          print(
              t.screen.pixelIsOn(pixelRow: pixelRow, pixelColumn: pixelColumn));
        },
      ),
      source = [
        0x07E0, // .....******.....
        0x1818, // ...**......**...
        0x2004, // ..*..........*..
        0x4002, // .*............*.
        0x4002, // .*............*.
        0x8811, // *...*......*...*
        0x8811, // *...*......*...*
        0x8001, // *..............*
        0x8001, // *..............*
        0x8FF1, // *...********...*
        0x8FF1, // *...********...*
        0x47E2, // .*...******...*.
        0x43C2, // .*....****....*.
        0x2004, // ..*..........*..
        0x1818, // ...**......**...
        0x07E0, // .....******.....
      ],
      sourceColor = "lightblue",
      destination = [
        ...[for (var _ = 0; _ < 8; _++) 0x00FF],
        ...[for (var _ = 0; _ < 8; _++) 0xFF00],
      ],
      destinationColor = "white";

  terminal
    ..output(" source     destination")
    ..screen.poke16Bit(
      position: (8, 8),
      data: source,
      mode: Mode.replace,
      color: sourceColor,
    )
    ..screen.poke16Bit(
      position: (8, 96),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..output(" replace    over", row: 4)
    ..screen.poke16Bit(
      position: (48, 8),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (48, 96),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (48, 8),
      data: source,
      mode: Mode.replace,
      color: sourceColor,
    )
    ..screen.poke16Bit(
      position: (48, 96),
      data: source,
      mode: Mode.over,
      color: sourceColor,
    )
    ..output(" under      stain", row: 8)
    ..screen.poke16Bit(
      position: (88, 8),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (88, 96),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (88, 8),
      data: source,
      mode: Mode.under,
      color: sourceColor,
    )
    ..screen.poke16Bit(
      position: (88, 96),
      data: source,
      mode: Mode.stain,
      color: sourceColor,
    )
    ..output(" delete     maskS", row: 12)
    ..screen.poke16Bit(
      position: (128, 8),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (128, 96),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (128, 8),
      data: source,
      mode: Mode.delete,
      color: sourceColor,
    )
    ..screen.poke16Bit(
      position: (128, 96),
      data: source,
      mode: Mode.maskSource,
      color: sourceColor,
    )
    ..output(" maskD      inverse", row: 16)
    ..screen.poke16Bit(
      position: (168, 8),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (168, 96),
      data: destination,
      mode: Mode.replace,
      color: destinationColor,
    )
    ..screen.poke16Bit(
      position: (168, 8),
      data: source,
      mode: Mode.maskDestination,
      color: sourceColor,
    )
    ..screen.poke16Bit(
      position: (168, 96),
      data: source,
      mode: Mode.inverse,
      color: sourceColor,
    );
}

import "dart:math" show Random;
import "package:web/web.dart" as web;
import "package:old_school/old_school.dart";

void main() {
  final rand = Random(),
      container = web.document.getElementById("screen")! as web.HTMLDivElement,
      width = 250,
      height = 250,
      screen = Screen(
        isInteractive: false,
        widthInPixels: width,
        heightInPixels: height,
        backgroundColor: "black",
        defaultColor: "lime",
        pixelWidth: 3,
        pixelHeight: 3,
        container: container,
      );

  for (var _ = 0; _ < 10000; _++) {
    screen.setPixelOn(
        pixelRow: rand.nextInt(height), pixelColumn: rand.nextInt(width));
  }

  screen.clear(pixelTop: 100, pixelLeft: 50, pixelWidth: 75, pixelHeight: 25);

  final sprites8 = [
    [
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
    ],
    [
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
    ],
    [
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
    ],
    [
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
    ],
    [
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
    ],
    [
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
    ],
    [
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
    ],
    [
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
    ],
    [
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
    ],
    [
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
    ],
    [
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
    ],
    [
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
    ],
    [
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0x00, // ........
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
    ],
    [
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0x0F, // ....****
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
    ],
    [
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xF0, // ****....
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
    ],
    [
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
      0xFF, // ********
    ],
  ];
  for (var i = 0; i < sprites8.length; i++) {
    final r = i ~/ 4, c = i % 4, sprite = sprites8[i];
    screen.poke8Bit(
      position: (50 + r * (8 + 2), 50 + c * (8 + 2)),
      data: sprite,
    );
  }

  final face = [
    0x07E0, // .....******.....
    0x1818, // ...**......**...
    0x2004, // ..*..........*..
    0x4002, // .*............*.
    0x4812, // .*..*......*..*.
    0x8811, // *...*......*...*
    0x8001, // *..............*
    0x8001, // *..............*
    0x8811, // *...*......*...*
    0x8811, // *...*......*...*
    0x8421, // *....*....*....*
    0x43C2, // .*....****....*.
    0x4002, // .*............*.
    0x2004, // ..*..........*..
    0x1818, // ...**......**...
    0x07E0, // .....******.....
  ];

  for (var _ = 0; _ < 100; _++) {
    screen.poke16Bit(
      position: (rand.nextInt(height), rand.nextInt(width)),
      data: face,
      color: ["yellow", "white", "pink", "orange"][rand.nextInt(4)],
      mode: Mode.replace,
    );
  }

  for (var _ = 0; _ < 100; _++) {
    screen.circle(
        center: (rand.nextInt(height), rand.nextInt(width)),
        radius: rand.nextInt(20) + 10);
  }
}

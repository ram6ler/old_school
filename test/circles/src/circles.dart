import "dart:async" show Timer;
import "dart:math" show Random, sin, cos, pi;
import "package:web/web.dart" as web;
import "package:old_school/old_school.dart";

final rand = Random();

class Bubble {
  Bubble(Screen s) {
    radius = rand.nextInt(20) + 10;
    pixelRow = rand.nextInt(s.heightInPixels);
    pixelColumn = rand.nextInt(s.widthInPixels);
    theta = (2 * rand.nextDouble() - 1.0) * pi;
    speed = rand.nextDouble() * 3.0 + 1.0;
    color = ["yellow", "white", "purple", "lime", "skyblue"][rand.nextInt(5)];
  }
  late int pixelRow, pixelColumn, radius;
  late double theta, speed;
  late String color;

  void update(Screen s) {
    s.deleteCircle(
      center: (pixelRow, pixelColumn),
      radius: radius,
      wrap: true,
    );

    pixelRow += (speed * sin(theta)).round();
    pixelRow %= s.heightInPixels;
    pixelColumn += (speed * cos(theta)).round();
    pixelColumn %= s.widthInPixels;

    s.circle(
      center: (pixelRow, pixelColumn),
      radius: radius,
      color: color,
      wrap: true,
    );
  }
}

void main() {
  final screen = Screen(
        heightInPixels: 250,
        widthInPixels: 250,
        pixelWidth: 2,
        pixelHeight: 2,
        backgroundColor: "darkgray",
        defaultColor: "white",
        container: web.document.getElementById("circles")! as web.HTMLElement,
      ),
      bubbles = [for (var _ = 0; _ < 10; _++) Bubble(screen)];
  Timer.periodic(Duration(milliseconds: 100), (_) {
    for (final bubble in bubbles) bubble.update(screen);
  });
}

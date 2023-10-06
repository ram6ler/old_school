import "dart:html";
import "package:old_school/old_school.dart";

void main() {
  final wizard = Sprite(
        layers: [
          Layer(
            data: [
              0x0000,
              0x0000,
              0x0F00,
              0x17C0,
              0x07E0,
              0x1FF8,
              0x1818,
              0x1008,
              0x0000,
              0x0000,
              0x0810,
              0x0C10,
              0x0C10,
              0x340C,
              0x362C,
              0x0C60,
            ],
            color: "rgb(155,76,164)",
          ),
          Layer(
            data: [
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x07E0,
              0x0000,
              0x0360,
            ],
            color: "#333",
          ),
          Layer(
            data: [
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0810,
              0x0800,
              0x01C0,
              0x0220,
              0x03E0,
              0x03E0,
              0x03E0,
              0x01C0,
              0x0380,
            ],
            color: "#999",
          ),
          Layer(
            data: [
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x0000,
              0x07E0,
              0x0490,
              0x0620,
              0x05C0,
              0x300C,
              0x300C,
            ],
            color: "rgb(247,194,130)",
          )
        ],
        spriteSize: SpriteSize.b16,
      ),
      screen = Screen(
        heightInPixels: 160,
        widthInPixels: 160,
        pixelWidth: 3,
        pixelHeight: 3,
        backgroundColor: "black",
        defaultColor: "white",
        container: document.getElementById("sprites")!,
      );

  for (var i = 0; i < 25; i++) {
    screen.drawSprite(
      position: (
        (i ~/ 5) * 32 + 8,
        (i % 5) * 32 + 8,
      ),
      sprite: wizard,
      reflected: i % 2 == 0,
    );
  }
}

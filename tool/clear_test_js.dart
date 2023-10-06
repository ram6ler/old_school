import "dart:io";

main() async {
  for (final test in [
    "mouse_events",
    "pixel_modes",
    "screen",
    "terminal",
    "lines",
    "circles",
    "sprites",
  ]) {
    print("Clearing $test...");
    for (final end in [
      "js",
      "js.deps",
      "js.map",
    ]) {
      final file = File("test/$test/js/$test.$end");
      if (await file.exists()) file.delete();
    }
  }
}

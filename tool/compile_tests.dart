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
    print("Compiling $test...");
    final result = await Process.run("dart", [
      "compile",
      "js",
      "test/$test/src/$test.dart",
      "-o",
      "test/$test/js/$test.js",
    ]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }
}

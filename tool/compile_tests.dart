import "dart:io";

main() async {
  for (final test in [
    "circles",
    "hello",
    "lines",
    "mouse_events",
    "pixel_modes",
    "screen",
    "smile",
    "sprites",
    "terminal",
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

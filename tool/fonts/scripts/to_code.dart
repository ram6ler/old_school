import 'dart:io' show File;

void main(List<String> args) {
  if (args.isEmpty) {
    print("Example use:");
    print("  dart tools/fonts/scripts/to_code.dart ati");
    print("where ati.txt is stored in tools/fonts/data.\n");
    return;
  }

  final input = File("tools/fonts/data/${args.first}.txt"),
      extended = File("tools/fonts/ibm_extended_ascii.txt"),
      output = File("lib/pixel_fonts/${args.first}.dart"),
      inputLines = input.readAsLinesSync(),
      extendedLines = extended.readAsLinesSync();
  if (inputLines.length != extendedLines.length) {
    print(
        "Lines in ${args.first}.txt do not match lines in ibm_extended_ascii.txt.");
    return;
  }
  final buffer = StringBuffer("const data = {\n");
  for (var i = 0; i < inputLines.length; i++) {
    final key = extendedLines[i],
        data = [
          for (final hex in inputLines[i].split(","))
            (
              hex.trim(),
              int.tryParse(hex.trim().substring(2), radix: 16)!
                  .toRadixString(2)
                  .padLeft(8, "0")
                  .replaceAll("0", ".")
                  .replaceAll("1", "*")
            )
        ];
    if (key == "\\" || key == "\"" || key == "\$") {
      buffer.writeln('  "\\$key": [');
    } else {
      buffer.writeln('  "$key": [');
    }
    for (final (hex, pic) in data) {
      buffer.writeln("    $hex, // $pic");
    }
    buffer.writeln("  ],");
  }
  buffer.writeln("};");
  output.writeAsString(buffer.toString());
}

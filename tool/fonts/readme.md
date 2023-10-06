# Fonts

This directory contains font data used in old roms (e.g. see [this GitHub repository](https://github.com/spacerace/romfont)) and a simple script that writes a corresponding dart file with rough images added as comments.

**To add a font:**

* Store the character data in a text file such that each character is represented by a line of eight hex values separated by commas.
* Remove characters indexed 0 and 255.
* Save the file to `tools/fonts/data`.

**To run the script:**

```text
dart tools/fonts/scripts/to_code.dart [name of font]
```

Example:

```text
dart tools/fonts/scripts/to_code.dart ati 
```

The script expects to find `tools/fonts/data/ati.txt`; expect the script to overwrite `lib/pixel_fonts/ati.dart`.

# Fonts

This directory contains font data used in old roms (e.g. see [this GitHub repository](https://github.com/spacerace/romfont)) and a simple script that writes a corresponding dart file with rough images added as comments.

## To add a font

(Assumes the font is 8x8 and supports IBM extended ASCII.)

* Store the character data in a text file such that each character is represented by a line of eight hex values separated by commas.
* Remove characters indexed 0 and 255.
* Save the file to `tools/fonts/data`.
* To run the script:

  ```text
  dart tools/fonts/scripts/to_code.dart [name of font]
  ```

  Example:

  ```text
  dart tools/fonts/scripts/to_code.dart ati 
  ```

  For this example, the script expects to find `tools/fonts/data/ati.txt` and will overwrite `lib/pixel_fonts/ati.dart`.

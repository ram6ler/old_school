import "dart:js_interop";
import "dart:typed_data" show Uint32List;
import "dart:math" show min, max;
import "package:web/web.dart" as web;
import "sprite.dart" show Sprite, Mode, SpriteSize;

/// A screen class that maps pixels to a wrapped canvas element, keeps track
/// of which pixels have been set, and defines procedures for drawing shapes,
/// bit patterns and sprites.
class Screen {
  Screen({
    required this.isInteractive,
    required this.heightInPixels,
    required this.widthInPixels,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.backgroundColor,
    required this.defaultColor,
    required web.HTMLElement container,
  })  : _canvas = web.HTMLCanvasElement()
          ..width = widthInPixels * pixelWidth
          ..height = heightInPixels * pixelHeight,
        _buffer = web.HTMLCanvasElement()
          ..width = widthInPixels * pixelWidth
          ..height = heightInPixels * pixelHeight,
        _data = [
          for (var _ = 0; _ < heightInPixels; _++)
            Uint32List(widthInPixels ~/ 32 + 1)
        ],
        _documentHasFocus = true {
    web.document
      ..onfocus = (() {
        _documentHasFocus = true;
      }).toJS
      ..onblur = (() {
        _documentHasFocus = false;
      }).toJS;

    _canvas
      ..tabIndex = -1
      ..style.display = "block"
      ..style.outline = "none"
      ..context2D.imageSmoothingEnabled = false
      ..onfocus = (() {
        focus();
      }).toJS
      ..onblur = (() {
        blur();
      }).toJS;

    container
      ..style.display = "flex"
      ..style.alignItems = "flex-start"
      ..style.padding = "0"
      ..style.margin = "0"
      ..style.width = "fit-content"
      ..style.height = "fit-content"
      ..style.background = "gray"
      ..appendChild(_canvas);

    clear();
  }

  /// Whether the screen is interactive.
  final bool isInteractive;

  /// The height of the screen in screen pixels.
  final int heightInPixels;

  /// The width of the screen in screen pixels.
  final int widthInPixels;

  /// The width of a screen pixel in actual pixels.
  final int pixelWidth;

  /// The height of a screen pixel in actual pixels.
  final int pixelHeight;

  /// The default screen pixel color.
  final String defaultColor;

  /// The background color.
  final String backgroundColor;

  /// The canvas used to draw the screen.
  final web.HTMLCanvasElement _canvas;

  /// A buffer canvas for poking sprites.
  final web.HTMLCanvasElement _buffer;

  /// A record of which bits are currently set.
  final List<Uint32List> _data;

  /// A helper that finds the bit index and shift
  static (int index, int shift) _findBit(int pixelColumn) =>
      (pixelColumn ~/ 32, 31 - pixelColumn % 32);

  /// A helper that returns wrapped row column coordinates.
  (int wrappedRow, int wrappedColumn) _wrapped(int pixelRow, int pixelColumn) =>
      (pixelRow % heightInPixels, pixelColumn % widthInPixels);

  /// Clears the buffer for drawing.
  void _clearBuffer() => _buffer.context2D
    ..save()
    ..beginPath()
    ..clearRect(0, 0, _buffer.width, _buffer.height)
    ..restore();

  /// Copies the buffer to the canvas.
  void _copyBufferToCanvas() => _canvas.context2D
    ..save()
    ..beginPath()
    ..drawImage(_buffer, 0, 0)
    ..restore();

  /// Helper for turning the pixel at row `pixelRow` column `pixelColumn` off.
  void _setPixelOff(
    int pixelRow,
    int pixelColumn,
    web.HTMLCanvasElement destination,
    bool wrap,
  ) {
    if (!wrap &&
        (pixelRow < 0 ||
            pixelRow >= heightInPixels ||
            pixelColumn < 0 ||
            pixelColumn >= widthInPixels)) {
      return;
    }
    (pixelRow, pixelColumn) = _wrapped(pixelRow, pixelColumn);
    final (index, shift) = _findBit(pixelColumn);
    final bit = 1 << shift;
    _data[pixelRow][index] |= bit;
    _data[pixelRow][index] ^= bit;

    destination.context2D
      ..save()
      ..beginPath()
      ..fillStyle = backgroundColor.toJS
      ..fillRect(
        pixelColumn * pixelWidth,
        pixelRow * pixelHeight,
        pixelWidth,
        pixelHeight,
      )
      ..restore();
  }

  /// Turns the pixel at row `pixelRow` column `pixelColumn` off.
  void setPixelOff({
    required int pixelRow,
    required int pixelColumn,
    bool wrap = false,
  }) =>
      _setPixelOff(pixelRow, pixelColumn, _canvas, wrap);

  /// Helper for turning the pixel at row `pixelRow` column `pixelColumn` on.
  void _setPixelOn(
    int pixelRow,
    int pixelColumn,
    String color,
    web.HTMLCanvasElement destination,
    bool wrap,
  ) {
    if (!wrap &&
        (pixelRow < 0 ||
            pixelRow >= heightInPixels ||
            pixelColumn < 0 ||
            pixelColumn >= widthInPixels)) {
      return;
    }
    (pixelRow, pixelColumn) = _wrapped(pixelRow, pixelColumn);
    final (index, shift) = _findBit(pixelColumn);
    final bit = 1 << shift;
    _data[pixelRow][index] |= bit;
    destination.context2D
      ..save()
      ..beginPath()
      ..fillStyle = color.toJS
      ..fillRect(
        pixelColumn * pixelWidth,
        pixelRow * pixelHeight,
        pixelWidth,
        pixelHeight,
      )
      ..restore();
  }

  /// Turns the pixel at row `pixelRow` column `pixelColumn` on.
  void setPixelOn({
    required int pixelRow,
    required int pixelColumn,
    String? color,
    bool wrap = false,
  }) =>
      _setPixelOn(pixelRow, pixelColumn, color ?? defaultColor, _canvas, wrap);

  /// Returns whether the pixel at row `pixelRow` column `pixelColumn` is on.
  bool pixelIsOn({
    required int pixelRow,
    required int pixelColumn,
  }) {
    (pixelRow, pixelColumn) = _wrapped(pixelRow, pixelColumn);
    final (index, shift) = _findBit(pixelColumn);
    final bit = 1 << shift;
    return _data[pixelRow][index] & bit > 0;
  }

  /// Clears rectangular region of pixels.
  void clear(
      {int pixelTop = 0,
      int pixelLeft = 0,
      int? pixelWidth,
      int? pixelHeight}) {
    pixelWidth = pixelWidth ?? widthInPixels - pixelLeft;
    pixelHeight = pixelHeight ?? heightInPixels - pixelTop;
    _clearBuffer();
    if (pixelLeft == 0 &&
        pixelTop == 0 &&
        pixelWidth == widthInPixels &&
        pixelHeight == heightInPixels) {
      for (var r = 0; r < _data.length; r++) {
        for (var c = 0; c < _data[r].length; c++) {
          _data[r][c] = 0;
        }
      }
      _buffer.context2D
        ..save()
        ..fillStyle = backgroundColor.toJS
        ..fillRect(0, 0, _buffer.width, _buffer.height)
        ..restore();
    } else {
      pixelTop %= heightInPixels;
      pixelLeft %= widthInPixels;
      final bottom = min(pixelTop + pixelHeight.abs(), heightInPixels),
          right = min(pixelLeft + pixelHeight.abs(), widthInPixels);
      for (var r = pixelTop; r < bottom; r++) {
        final pixelRow = r % heightInPixels;
        for (var c = pixelLeft; c < right; c++) {
          final pixelColumn = c % widthInPixels;
          _setPixelOff(pixelRow, pixelColumn, _buffer, false);
        }
      }
    }
    _copyBufferToCanvas();
  }

  /// Returns the color of the pixel at row `pixelRow` column `pixelColumn`.
  String getPixelColor(int pixelRow, int pixelColumn) =>
      "#" +
      [
        for (final value in _canvas.context2D
            .getImageData(
                pixelColumn * pixelWidth, pixelRow * pixelHeight, 1, 1)
            .data
            .toDart)
          value.toRadixString(16).padLeft(2, "0")
      ].join("");

  /// A horizontal reflection of the bits in `datum`.
  int _reflect(int datum, int bits) {
    var result = 0;
    for (var i = 0; i < bits; i++) {
      final bit = (datum & (1 << i)) >> i;
      result |= bit << (bits - i - 1);
    }
    return result;
  }

  /// Helper for poking data into the screen memory.
  void _poke(
    int pixelRow,
    int pixelColumn,
    List<int> data,
    String color,
    int bits,
    Mode mode,
    bool updateBuffer,
    bool reflected,
    bool wrap,
  ) {
    if (updateBuffer) _clearBuffer();
    (pixelRow, pixelColumn) = _wrapped(pixelRow, pixelColumn);
    final bitRegion = (1 << bits) - 1;

    for (var r = 0; r < data.length; r++) {
      final source =
              (reflected ? _reflect(data[r], bits) : data[r]) & bitRegion,
          destination = [
            for (var c = 0; c < bits; c++)
              (pixelIsOn(pixelRow: pixelRow + r, pixelColumn: pixelColumn + c)
                      ? 1
                      : 0) <<
                  (bits - 1 - c)
          ].fold(0, (a, b) => a | b);

      switch (mode) {
        case Mode.replace:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c;
            if ((source >> shift) & 1 > 0) {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            } else {
              _setPixelOff(pixelRow + r, pixelColumn + c, _buffer, wrap);
            }
          }
        case Mode.inverse:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c;
            if ((source >> shift) & 1 > 0) {
              _setPixelOff(pixelRow + r, pixelColumn + c, _buffer, wrap);
            } else {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            }
          }
        case Mode.under:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c;
            if ((source >> shift) & 1 > 0 && (destination >> shift) & 1 == 0) {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            }
          }
        case Mode.over:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c;
            if ((source >> shift) & 1 > 0) {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            }
          }
        case Mode.stain:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c, conjunction = source & destination;
            if ((conjunction >> shift) & 1 > 0) {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            }
          }
        case Mode.delete:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c, conjunction = source & destination;
            if ((conjunction >> shift) & 1 > 0) {
              _setPixelOff(pixelRow + r, pixelColumn + c, _buffer, wrap);
            }
          }
        case Mode.maskDestination:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c, conjunction = source & destination;
            if ((conjunction >> shift) & 1 == 0) {
              _setPixelOff(pixelRow + r, pixelColumn + c, _buffer, wrap);
            }
          }
        case Mode.maskSource:
          for (var c = 0; c < bits; c++) {
            final shift = bits - 1 - c, conjunction = source & destination;
            if ((conjunction >> shift) & 1 == 0) {
              _setPixelOff(pixelRow + r, pixelColumn + c, _buffer, wrap);
            } else {
              _setPixelOn(pixelRow + r, pixelColumn + c, color, _buffer, wrap);
            }
          }
      }
    }
    if (updateBuffer) _copyBufferToCanvas();
  }

  /// Pokes the data in `data` into the pixel memory of the screen.
  void poke8Bit({
    required (int pixelRow, int pixelColumn) position,
    required List<int> data,
    Mode mode = Mode.replace,
    String? color,
    bool reflected = false,
    bool wrap = false,
  }) {
    color = color ?? defaultColor;
    final (pixelRow, pixelColumn) = position;
    _poke(pixelRow, pixelColumn, data, color, 8, mode, true, reflected, wrap);
  }

  /// Pokes the data in `data` into the pixel memory of the screen.
  void poke16Bit({
    required (int pixelRow, int pixelColumn) position,
    required List<int> data,
    Mode mode = Mode.replace,
    String? color,
    bool reflected = false,
    bool wrap = false,
  }) {
    color = color ?? defaultColor;
    final (pixelRow, pixelColumn) = position;
    _poke(pixelRow, pixelColumn, data, color, 16, mode, true, reflected, wrap);
  }

  /// Pokes the data in `data` into the pixel memory of the screen.
  void poke32Bit({
    required (int pixelRow, int pixelColumn) position,
    required List<int> data,
    Mode mode = Mode.replace,
    String? color,
    bool reflected = false,
    bool wrap = false,
  }) {
    color = color ?? defaultColor;
    final (pixelRow, pixelColumn) = position;
    _poke(pixelRow, pixelColumn, data, color, 32, mode, true, reflected, wrap);
  }

  /// Draws a `Sprite` instance to the screen.
  void drawSprite({
    required (int pixelRow, int pixelColumn) position,
    required Sprite sprite,
    bool reflected = false,
    bool wrap = false,
  }) {
    _clearBuffer();
    final (pixelRow, pixelColumn) = position;
    final bits = switch (sprite.spriteSize) {
      SpriteSize.b8 => 8,
      SpriteSize.b16 => 16,
      SpriteSize.b32 => 32,
    };
    for (final layer in sprite.layers) {
      _poke(
        pixelRow,
        pixelColumn,
        layer.data,
        layer.color ?? defaultColor,
        bits,
        layer.mode,
        false,
        reflected,
        wrap,
      );
    }
    _copyBufferToCanvas();
  }

  /// Scrolls all pixels up by `pixels` pixels.
  void shiftUp(int pixels) {
    pixels = pixels % heightInPixels;
    var r = 0;
    for (; r < heightInPixels - pixels; r++) {
      for (var c = 0; c < _data[r].length; c++) {
        _data[r][c] = _data[r + pixels][c];
      }
    }
    for (; r < heightInPixels; r++) {
      for (var c = 0; c < _data[r].length; c++) {
        _data[r][c] = 0;
      }
    }

    _clearBuffer();
    _buffer.context2D
      ..save()
      ..beginPath()
      ..drawImage(_canvas, 0, -pixels * pixelHeight)
      ..fillStyle = backgroundColor.toJS
      ..fillRect(
        0,
        (heightInPixels - pixels) * pixelHeight,
        _buffer.width,
        pixels * pixelHeight,
      )
      ..restore();
    _copyBufferToCanvas();
  }

  /// Draws a line between using *Bresenham's algorithm*.
  void _line(
    (int pixelRow, int pixelColumn) from,
    (int pixelRow, int pixelColumn) to,
    String color,
    Mode mode,
    bool wrap,
  ) {
    _clearBuffer();
    final (y0, x0) = from;
    final (y1, x1) = to;

    final dx = (x1 - x0).abs(),
        dy = -(y1 - y0).abs(),
        sx = x0 < x1 ? 1 : -1,
        sy = y0 < y1 ? 1 : -1;
    var x = x0, y = y0, error = dx + dy;
    while (true) {
      switch (mode) {
        case Mode.delete:
          _setPixelOff(y, x, _buffer, wrap);
        case _:
          _setPixelOn(y, x, color, _buffer, wrap);
      }

      if (x == x1 && y == y1) break;
      final e = 2 * error;
      if (e >= dy) {
        if (x == x1) break;
        error += dy;
        x += sx;
      }
      if (e <= dx) {
        if (y == y1) break;
        error += dx;
        y += sy;
      }
    }

    _copyBufferToCanvas();
  }

  /// Draws a line to the screen.
  void line({
    required (int pixelRow, int pixelColumn) from,
    required (int pixelRow, int pixelColumn) to,
    String? color,
    bool wrap = false,
  }) {
    color = color ?? defaultColor;
    _line(from, to, color, Mode.over, wrap);
  }

  /// Removes a line from the screen.
  void deleteLine({
    required (int pixelRow, int pixelColumn) from,
    required (int pixelRow, int pixelColumn) to,
    bool wrap = false,
  }) {
    _line(from, to, defaultColor, Mode.delete, wrap);
  }

  /// Draws a circle between using *Bresenham's algorithm*.
  void _circle(
    (int pixelRow, int pixelColumn) center,
    int radius,
    String color,
    Mode mode,
    bool wrap,
  ) {
    _clearBuffer();
    final (ym, xm) = center;
    var x = -radius, y = 0, e = 2 - 2 * radius;
    do {
      switch (mode) {
        case Mode.delete:
          _setPixelOff(ym + y, xm - x, _buffer, wrap);
          _setPixelOff(ym - x, xm - y, _buffer, wrap);
          _setPixelOff(ym - y, xm + x, _buffer, wrap);
          _setPixelOff(ym + x, xm + y, _buffer, wrap);
        case _:
          _setPixelOn(ym + y, xm - x, color, _buffer, wrap);
          _setPixelOn(ym - x, xm - y, color, _buffer, wrap);
          _setPixelOn(ym - y, xm + x, color, _buffer, wrap);
          _setPixelOn(ym + x, xm + y, color, _buffer, wrap);
      }
      radius = e;
      if (radius <= y) e += (++y * 2 + 1);
      if (radius > x || e > y) e += (++x * 2 + 1);
    } while (x < 0);
    _copyBufferToCanvas();
  }

  /// Draws a circle to the screen.
  void circle({
    required (int pixelRow, int pixelColumn) center,
    required int radius,
    String? color,
    bool wrap = false,
  }) {
    color = color ?? defaultColor;
    _circle(center, radius, color, Mode.over, wrap);
  }

  /// Removes a circle from the screen.
  void deleteCircle({
    required (int pixelRow, int pixelColumn) center,
    required int radius,
    bool wrap = false,
  }) {
    _circle(center, radius, defaultColor, Mode.delete, wrap);
  }

  /// Maps an offset (e.g. from a mouse event) to the corresponding pixel.
  (int pixelRow, int pixelColumn) offsetToPixel((int x, int y) offset) {
    final (x, y) = offset;
    final pixelRow = max(min((y - 1) ~/ pixelHeight, heightInPixels - 1), 0),
        pixelColumn = max(min((x - 1) ~/ pixelWidth, widthInPixels - 1), 0);
    return (pixelRow, pixelColumn);
  }

  /// Whether the screen has focus.
  bool _documentHasFocus;
  bool get hasFocus =>
      _documentHasFocus && web.document.activeElement == _canvas;

  /// Gives focus to the screen.
  void focus() {
    _canvas
      ..style.opacity = "1.0"
      ..focus();
  }

  /// Removes focus from the screen.
  void blur() {
    if (isInteractive) {
      _canvas
        ..style.opacity = "0.5"
        ..blur();
    }
  }
}

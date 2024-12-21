import "dart:async" show StreamController, Timer;
import "dart:math" show Rectangle;
import "package:web/web.dart" as web;
import "package:old_school/pixel_fonts/oak.dart" as Font;
import "screen.dart";
import "position.dart";
import "cell.dart";
import "key_data.dart";
import "mouse_data.dart";

/// The state of a terminal.
///
/// Possible states:
///
/// ```text
/// ready
/// awaitingKey
/// awaitingString
/// awaitingMouseClick
///
/// ```
///
enum State {
  ready,
  awaitingKey,
  awaitingString,
  awaitingMouseClick;
}

/// An old school terminal that can be displayed in an html document.
class Terminal {
  Terminal({
    required this.rows,
    required this.columns,
    required this.container,
    this.rowGap = 2,
    this.scrolls = true,
    this.defaultColor = "white",
    this.backgroundColor = "black",
    this.isInteractive = true,
    int pixelWidth = 2,
    int pixelHeight = 2,
    Map<String, List<int>>? fontData,
    void Function(Terminal, MouseData)? whenMouseIsClicked,
    void Function(Terminal, MouseData)? whenMouseIsMoved,
    void Function(Terminal, MouseData)? whenMouseEntersTerminal,
    void Function(Terminal, MouseData)? whenMouseLeavesTerminal,
    void Function(Terminal, KeyboardData)? whenKeyIsPressed,
    void Function(Terminal, KeyboardData)? whenKeyIsReleased,
  })  : screen = Screen(
          heightInPixels: rows * (8 + rowGap),
          widthInPixels: columns * 8,
          pixelWidth: pixelWidth,
          pixelHeight: pixelHeight,
          backgroundColor: backgroundColor,
          defaultColor: defaultColor,
          container: container,
        ),
        _fontData = fontData ?? Font.data,
        _cells = [
          for (var r = 0; r < rows; r++)
            [
              for (var c = 0; c < columns; c++)
                Cell(
                  row: r,
                  column: c,
                  color: defaultColor,
                  character: " ",
                )
            ]
        ],
        _cellsToBeUpdated = <Cell>{},
        currentPosition = Position(rows, columns),
        _startPosition = Position(rows, columns),
        _endPosition = Position(rows, columns),
        _inputBroadcaster = StreamController<String>.broadcast(),
        _keyBroadcaster = StreamController<KeyboardData>.broadcast(),
        _mouseBroadcaster = StreamController<MouseData>.broadcast(),
        _state = State.ready {
    if (isInteractive) {
      MouseData getMouseData(web.MouseEvent event) {
        final (pixelRow, pixelColumn) = screen
            .offsetToPixel((event.offsetX.toInt(), event.offsetY.toInt()));
        final row = pixelRow ~/ (8 + rowGap),
            column = pixelColumn ~/ 8,
            character = getCharacter(
              row: row,
              column: column,
            ),
            color = getColor(
              row: row,
              column: column,
            ),
            pixelIsOn = screen.pixelIsOn(
              pixelRow: pixelRow,
              pixelColumn: pixelColumn,
            );

        return MouseData(
          row: row,
          column: column,
          pixelRow: pixelRow,
          pixelColumn: pixelColumn,
          character: character,
          color: color,
          pixelIsOn: pixelIsOn,
        );
      }

      KeyboardData getKeyboardData(web.KeyboardEvent event) {
        final keyCode = event.keyCode, character = event.key;
        return KeyboardData(
          keyCode: keyCode,
          key: character.length > 1 ? "" : character,
        );
      }

      String getInputString() {
        final position = Position(rows, columns)..index = _startPosition.index;
        return [
          for (; position.index < _endPosition.index; position.index++)
            getCharacter(
              row: position.row,
              column: position.column,
            )
        ].join("");
      }

      container
        ..tabIndex = -1
        ..onFocus.listen((_) {
          screen.focus();
        })
        ..onBlur.listen((_) {
          screen.blur();
        })
        ..onKeyDown.listen((event) {
          event.preventDefault();
          switch (_state) {
            case State.ready:
              if (whenKeyIsPressed != null) {
                whenKeyIsPressed(
                  this,
                  getKeyboardData(event),
                );
              }
            case State.awaitingKey:
              if (_keyBroadcaster.hasListener) {
                _keyBroadcaster.add(getKeyboardData(event));
                _state = State.ready;
              }
            case State.awaitingString:
              _hideCursor();
              switch (event.keyCode) {
                case web.KeyCode.ENTER:
                  if (_inputBroadcaster.hasListener) {
                    _inputBroadcaster.add(getInputString().trim());
                    newLine();
                    _state = State.ready;
                  }
                case web.KeyCode.BACKSPACE:
                  if (currentPosition.index > _startPosition.index) {
                    currentPosition.index--;
                    output(" ", newLineAfter: false);
                    currentPosition.index--;
                  }
                case _:
                  final key = event.key;
                  if (key.length == 1 &&
                      currentPosition.index < _endPosition.index) {
                    output(key, newLineAfter: false);
                  }
              }
            case State.awaitingMouseClick:
              break;
          }
        })
        ..onClick.listen((event) {
          event.preventDefault();
          if (_state == State.awaitingMouseClick &&
              _mouseBroadcaster.hasListener) {
            _mouseBroadcaster.add(getMouseData(event));
            _state = State.ready;
          } else if (whenMouseIsClicked != null) {
            whenMouseIsClicked(this, getMouseData(event));
          }
        });

      if (whenMouseIsMoved != null) {
        container.onMouseMove.listen((event) {
          event.preventDefault();
          whenMouseIsMoved(this, getMouseData(event));
        });
      }

      if (whenMouseEntersTerminal != null) {
        container.onMouseEnter.listen((event) {
          event.preventDefault();
          whenMouseEntersTerminal(this, getMouseData(event));
        });
      }

      if (whenMouseLeavesTerminal != null) {
        container.onMouseLeave.listen((event) {
          event.preventDefault();
          whenMouseLeavesTerminal(this, getMouseData(event));
        });
      }

      if (whenKeyIsReleased != null) {
        container.onKeyUp.listen((event) {
          event.preventDefault();
          whenKeyIsReleased(this, getKeyboardData(event));
        });
      }

      Timer.periodic(Duration(milliseconds: 300), (_) {
        if (hasFocus && _state == State.awaitingString) {
          if (_cursorIsShowing) {
            _hideCursor();
          } else {
            _showCursor();
          }
        }
      });

      blur();
    }
    clear();
  }

  /// The number of rows in the terminal.
  final int rows;

  /// The number of columns in the terminal.
  final int columns;

  /// The number of pixels between rows.
  final int rowGap;

  /// The default color of terminal display.
  final String defaultColor;

  /// The background color of the terminal.
  final String backgroundColor;

  /// The DOM element that will contain the terminal.
  final web.HTMLElement container;

  /// Whether the terminal is interactive.
  final bool isInteractive;

  /// The terminal screen.
  final Screen screen;

  /// The current position of the terminal's cursor.
  final Position currentPosition;

  /// Cursor constraints for when the user inputs strings.
  final Position _startPosition, _endPosition;

  /// Whether the terminal scrolls when output is sent to the last row.
  final bool scrolls;

  /// A broadcaster for string input from the user.
  final StreamController<String> _inputBroadcaster;

  /// A broadcaster for key input from the user.
  final StreamController<KeyboardData> _keyBroadcaster;

  /// A broadcaster for mouse input from the user.
  final StreamController<MouseData> _mouseBroadcaster;

  /// The input state of the terminal.
  State _state;

  /// The data for each cell in the terminal.
  List<List<Cell>> _cells;

  /// Whether the terminal has focus.
  bool get hasFocus => screen.hasFocus;

  /// Gives the terminal focus.
  void Function() get focus => screen.focus;

  /// Removes focus from the terminal.
  void Function() get blur => screen.blur;

  /// Wraps row and column to be within index bounds.
  (int wrappedRow, int wrappedColumn) _wrapped(int row, int column) =>
      (row % rows, column % columns);

  /// The cells that are scheduled for updating.
  final Set<Cell> _cellsToBeUpdated;

  /// The pixel data for the font.
  final Map<String, List<int>> _fontData;

  /// The data to be used for a missing character.
  static final _missingCharacter = List<int>.filled(8, 0x00);

  /// The data to be used for the blinking cursor.
  static final _cursorCharacter = List<int>.filled(8, 0xFF);

  /// Whether the blinking cursor is currently showing.
  bool _cursorIsShowing = false;

  /// Shows the blinking cursor.
  void _showCursor() {
    pokeCharacter(
      row: currentPosition.row,
      column: currentPosition.column,
      data: _cursorCharacter,
    );
    _cursorIsShowing = true;
  }

  /// Hides the blinking cursor.
  void _hideCursor() {
    _cellsToBeUpdated.add(
      Cell(
        row: currentPosition.row,
        column: currentPosition.column,
      ),
    );
    _updateCells();
    _cursorIsShowing = false;
  }

  /// Updates the scheduled cells.
  void _updateCells() {
    for (final cell in _cellsToBeUpdated) {
      final pixelRow = cell.row * (8 + rowGap),
          pixelColumn = cell.column * 8,
          data = _fontData.containsKey(cell.character)
              ? _fontData[cell.character]!
              : _missingCharacter;

      screen.poke8Bit(
        position: (pixelRow, pixelColumn),
        data: data,
        color: cell.color,
      );
    }
    _cellsToBeUpdated.clear();
  }

  /// Returns the character at row `row`, column `column`.
  String getCharacter({
    required int row,
    required int column,
  }) {
    (row, column) = _wrapped(row, column);
    return _cells[row][column].character;
  }

  /// Updates the character data at row `row`, column `column`.
  void _setCharacter({
    required int row,
    required int column,
    required String character,
  }) {
    (row, column) = _wrapped(row, column);
    _cells[row][column].character = character;
    _cellsToBeUpdated.add(_cells[row][column]);
  }

  /// Updates the character data at row `row`, column `column`.
  void setCharacter({
    required int row,
    required int column,
    required String character,
  }) {
    _setCharacter(row: row, column: column, character: character);
    _updateCells();
  }

  /// Returns the color at row `row`, column `column`.
  String getColor({
    required int row,
    required int column,
  }) {
    (row, column) = _wrapped(row, column);
    return _cells[row][column].color;
  }

  /// Updates the color data at row `row`, column `column`.
  void _setColor({
    required int row,
    required int column,
    required String color,
  }) {
    (row, column) = _wrapped(row, column);
    _cells[row][column].color = color;
    _cellsToBeUpdated.add(_cells[row][column]);
  }

  /// Updates the color data at row `row`, column `column`.
  void setColor({
    required int row,
    required int column,
    required String color,
  }) {
    _setColor(row: row, column: column, color: color);
    _updateCells();
  }

  /// Moves the cursor to the beginning of the next row.
  void newLine() {
    currentPosition.column = 0;
    if (scrolls && currentPosition.row == rows - 1) {
      scroll();
    } else {
      currentPosition.row++;
    }
  }

  /// Scrolls the terminal data up by a row.
  void scroll([int n = 1]) {
    for (var r = 0; r < rows - 1; r++) {
      for (var c = 0; c < columns; c++) {
        _cells[r][c].copyValuesOf(_cells[r + 1][c]);
      }
    }
    for (var c = 0; c < columns; c++) {
      _cells[rows - 1][c]
        ..character = " "
        ..color = defaultColor;
    }
    screen.shiftUp(8 + rowGap);
  }

  /// Outputs text to the terminal.
  void output(
    String text, {
    int? row,
    int? column,
    String? color,
    bool newLineAfter = true,
  }) {
    (row, column) = _wrapped(
      row ?? currentPosition.row,
      column ?? currentPosition.column,
    );
    currentPosition
      ..row = row
      ..column = column;
    color = color ?? defaultColor;
    for (final character in text.split("")) {
      (row, column) = (currentPosition.row, currentPosition.column);
      final cell = _cells[row][column];
      cell
        ..character = character
        ..color = color; // ?? cell.color;
      _cellsToBeUpdated.add(cell);
      if (scrolls && row == rows - 1 && column == columns - 1) {
        scroll();
        currentPosition.row--;
      }
      currentPosition.column++;
    }
    _updateCells();
    if (newLineAfter) {
      newLine();
    }
  }

  /// Clears the terminal over the region defined by `rectangle` if set;
  /// otherwise clears the whole terminal.
  void clear([Rectangle<int>? rectangle]) {
    rectangle = rectangle ?? Rectangle(0, 0, columns, rows);
    for (var r = rectangle.top; r < rectangle.bottom; r++) {
      for (var c = rectangle.left; c < rectangle.right; c++) {
        _cells[r][c]
          ..character = " "
          ..color = defaultColor;
      }
    }
    screen.clear(Rectangle(
      rectangle.left * 8,
      rectangle.top * (8 + rowGap),
      rectangle.width * 8,
      rectangle.height * (8 + rowGap),
    ));

    currentPosition
      ..row = rectangle.top
      ..column = rectangle.left;
  }

  /// Pokes a character defined by `data` to the terminal.
  void pokeCharacter({
    required int row,
    required int column,
    required List<int> data,
    String? color,
  }) {
    if (data.length != 8) {
      throw Exception("Character data must be of length 8.");
    }
    color = color ?? defaultColor;
    screen.poke8Bit(
      position: (row * (8 + rowGap), column * 8),
      data: data,
      color: color,
    );
  }

  /// Throws an exception if the terminal is not ready for input.
  void _throwIfNotOkay() {
    if (!isInteractive) {
      throw Exception("Terminal not interactive.");
    }
    if (_state != State.ready) {
      throw Exception("Terminal already awaiting input.");
    }
  }

  /// Waits for the user to input a key and then returns the result.
  Future<KeyboardData> inputKey() {
    _throwIfNotOkay();
    _state = State.awaitingKey;
    return _keyBroadcaster.stream.first;
  }

  /// Waits for the user to input a mouse click and then returns the result.
  Future<MouseData> inputMouseClick() {
    _throwIfNotOkay();
    _state = State.awaitingMouseClick;
    return _mouseBroadcaster.stream.first;
  }

  /// Waits for the user to input a string and then returns the result.
  Future<String> input({
    String? prompt,
    int? row,
    int? column,
    String? color,
    int length = 1,
  }) {
    _throwIfNotOkay();
    prompt = prompt ?? "";
    color = color ?? defaultColor;
    (row, column) = _wrapped(
      row ?? currentPosition.row,
      column ?? currentPosition.column,
    );
    currentPosition
      ..row = row
      ..column = column;

    output(
      " " * (prompt.length + length),
      newLineAfter: false,
    );

    if (prompt.isNotEmpty) {
      output(
        prompt,
        row: row,
        column: column,
        color: color,
        newLineAfter: false,
      );
    }

    currentPosition
      ..row = row
      ..column = column + prompt.length;

    if (scrolls && currentPosition.row == rows - 1) {
      scroll();
      currentPosition.row--;
    }
    _startPosition.index = currentPosition.index;
    _endPosition.index = _startPosition.index + length;
    _state = State.awaitingString;
    return _inputBroadcaster.stream.first;
  }
}

/// A class for terminal positions and position arithmetic.
class Position {
  Position(this.rows, this.columns);

  /// The number of rows in the containing terminal.
  final int rows;

  /// The number of columns in the containing terminal.
  final int columns;

  /// The internal position data.
  int _row = 0, _column = 0;

  /// The current row position.
  int get row => _row;
  void set row(int value) => _row = value % rows;

  /// The current column position.
  int get column => _column;
  void set column(int value) {
    if (value < 0) {
      _column = value;
      while (_column < 0) {
        _column += columns;
        row -= 1;
      }
    } else {
      row += value ~/ columns;
      _column = value % columns;
    }
  }

  /// The character index starting from the top left corner.
  int get index => _row * columns + _column;
  void set index(int value) {
    _row = (value ~/ columns) % rows;
    _column = value % columns;
  }
}

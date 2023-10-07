/// A data class for terminal cells.
class Cell {
  Cell({
    required this.row,
    required this.column,
    this.character = " ",
    this.color = "white",
  });

  /// The row the cell maps to in the terminal.
  final int row;

  /// The row the cell maps to in the terminal.
  final int column;

  /// The current character stored in the cell.
  String character;

  /// The current color of the cell's display.
  String color;

  /// Copies data from another cell.
  void copyValuesOf(Cell that) {
    character = that.character;
    color = that.color;
  }

  // Overriding hashCode and == so that a cell may potentially be added
  // multiple times to a scheduling set and only the most recent edit
  // will be made.

  @override
  int get hashCode => (row, column).hashCode;

  @override
  bool operator ==(Object other) => other is Cell && other.hashCode == hashCode;

  @override
  String toString() => "($row $column) => '$character' $color";
}

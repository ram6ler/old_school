/// A data class associated with a mouse event.
class MouseData {
  MouseData({
    required this.row,
    required this.column,
    required this.character,
    required this.color,
    required this.pixelRow,
    required this.pixelColumn,
    required this.pixelIsOn,
  });

  /// The row of the cell associated with the keyboard event.
  final int row;

  /// The column of the cell associated with the keyboard event.
  final int column;

  /// The character of the cell associated with the keyboard event.
  final String character;

  /// The color of the cell associated with the keyboard event.
  final String color;

  /// The row of the terminal pixel associated with the keyboard event.
  final int pixelRow;

  /// The column of the terminal pixel associated with the keyboard event.
  final int pixelColumn;

  /// Whether the pixel associated with the keyboard event is set.
  final bool pixelIsOn;

  @override
  String toString() => """
               row: $row
            column: $column
         character: '$character'
    characterColor: $color

          pixelRow: $pixelRow
       pixelColumn: $pixelColumn
         pixelIsOn: $pixelIsOn
    """;
}

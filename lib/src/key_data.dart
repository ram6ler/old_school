/// A data class for associated with a keyboard event.
class KeyboardData {
  KeyboardData({
    required this.keyCode,
    required this.key,
  });

  /// The key code of the key associated with a keyboard event.
  final int keyCode;

  /// A string representation of the key associated with a keyboard event.
  final String key;
}

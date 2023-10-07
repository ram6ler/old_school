/// Mode for poking data to a `PixelTerminal`.
enum Mode {
  /// Clears destination and writes source.
  replace,

  /// Clears destination and writes negated source.
  inverse,

  /// Writes source over destination without clearing.
  over,

  /// Only writes source where destination is clear.
  under,

  /// Only writes source where destination is not clear.
  stain,

  /// Deletes destination where source and destination are both set.
  delete,

  /// Keeps destination where source is set and clears the rest. (Involves
  /// looking up color data from the canvas and may thus be slower than
  /// other modes.)
  maskDestination,

  /// Writes source where destination is set and clears the rest.
  maskSource;
}

/// A sprite layer containing data, color and mode information.
class Layer {
  Layer({
    required this.data,
    this.color,
    this.mode = Mode.over,
  });

  /// The pixel data for the image contained in the layer.
  /// (Can be shared between layers.)
  final List<int> data;

  /// The color that should be used for the layer. (If not set, the default
  /// screen color is used.)
  final String? color;

  /// The mode to be used when poking the data to the screen memory.
  /// (Default: `Mode.over`)
  final Mode mode;
}

/// The number of pixel columns a sprite should occupy.
///
/// ```dart
/// enum SpriteSize {
///   b8,
///   b16,
///   b32;
/// }
/// ```
enum SpriteSize {
  b8,
  b16,
  b32;
}

/// A sprite class.
///
/// Each layer can have a different color and mode.
class Sprite {
  Sprite({
    required this.layers,
    this.spriteSize = SpriteSize.b8,
  });

  /// The layers comprising the sprite.
  final List<Layer> layers;

  /// The sprite size.
  final SpriteSize spriteSize;
}

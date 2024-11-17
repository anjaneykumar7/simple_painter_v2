import 'dart:typed_data';

class PainterBackground {
  PainterBackground({this.image, this.width = 0, this.height = 0});

  final double width;
  final double height;
  Uint8List? image;
}

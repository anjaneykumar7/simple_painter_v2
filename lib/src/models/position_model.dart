import 'package:equatable/equatable.dart';

class PositionModel extends Equatable {
  const PositionModel({this.x = 0, this.y = 0});

  final double y;
  final double x;

  PositionModel copyWith({double? x, double? y}) {
    return PositionModel(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  List<Object?> get props => [x, y];
}

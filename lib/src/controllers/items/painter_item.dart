import 'package:equatable/equatable.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class PainterItem extends Equatable {
  const PainterItem({
    required this.position,
    this.size,
    this.enabled = true,
  });

  final bool enabled;
  final PositionModel position;
  final SizeModel? size;

  PainterItem copyWith({
    bool? enabled,
    PositionModel? position,
    SizeModel? size,
  }) {
    return PainterItem(
      enabled: enabled ?? this.enabled,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [enabled, position, size];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_painter/src/helpers/random_service.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class PainterItem extends Equatable {
  PainterItem({
    required this.position,
    this.size,
    this.enabled = true,
    this.rotation = 0,
    String? id,
  }) : id = id ?? RandomService.generateRandomId();

  final String id;
  final bool enabled;
  final PositionModel position;
  final SizeModel? size;
  final double rotation;

  PainterItem copyWith({
    bool? enabled,
    PositionModel? position,
    SizeModel? size,
    double? rotation,
  }) {
    return PainterItem(
      id: id,
      enabled: enabled ?? this.enabled,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  List<Object?> get props => [id, enabled, position, size, rotation];
}

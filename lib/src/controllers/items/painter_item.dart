import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/helpers/random_service.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class PainterItem extends Equatable {
  PainterItem({
    required this.position,
    required this.layer,
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
  final LayerSettings layer;

  PainterItem copyWith({
    bool? enabled,
    PositionModel? position,
    LayerSettings? layer,
    SizeModel? size,
    double? rotation,
  }) {
    return PainterItem(
      id: id,
      enabled: enabled ?? this.enabled,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  List<Object?> get props => [id, enabled, position, size, rotation];
}

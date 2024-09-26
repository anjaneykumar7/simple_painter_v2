import 'package:equatable/equatable.dart';
import 'package:flutter_painter/src/controllers/paint_actions/action_type_enum.dart';

class PaintAction extends Equatable {
  const PaintAction({
    required this.actionType,
    required this.timestamp,
  });
  final ActionType actionType;
  final DateTime timestamp;

  void undo() {}
  void redo() {}

  @override
  List<Object> get props => [actionType, timestamp];
}

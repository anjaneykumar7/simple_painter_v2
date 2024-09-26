import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class PaintActions {
  List<PaintAction> changeList = <PaintAction>[];
  int index = -1;

  PaintActions copyWith({
    List<PaintAction>? changeList,
    int? index,
  }) {
    return PaintActions()
      ..changeList = changeList ?? this.changeList
      ..index = index ?? this.index;
  }
}

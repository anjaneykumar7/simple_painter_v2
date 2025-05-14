import 'package:simple_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:simple_painter/src/models/import_painter_snapshot_model.dart';

class ActionImportPainter extends PaintAction {
  const ActionImportPainter({
    required this.newSnapshot,
    required this.oldSnapshot,
    required super.timestamp,
    required super.actionType,
  });

  final ImportPainterSnapshotModel newSnapshot;
  final ImportPainterSnapshotModel oldSnapshot;
}

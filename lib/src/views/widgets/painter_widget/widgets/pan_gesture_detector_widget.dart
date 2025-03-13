part of '../painter_widget.dart';

// A simple stateless widget that detects pan gestures on its child.
class PanGestureDetector extends StatelessWidget {
  const PanGestureDetector({
    super.key,
    this.child,
    this.behavior,
    this.excludeFromSemantics = false,
    this.semantics,
    this.touchSlop,
    this.onPanCancel,
    this.onPanDown,
    this.onPanEnd,
    this.onPanStart,
    this.onPanUpdate,
  });

  final Widget? child;

  // Determines how hit tests behave.
  final HitTestBehavior? behavior;

  // Exclude the descendant widgets from the semantics tree if true.
  final bool excludeFromSemantics;

  // Custom semantics gesture logic.
  final SemanticsGestureDelegate? semantics;

  // The touch slop (distance the pointer must move to be recognized as a drag).
  final double? touchSlop;

  // Callbacks for handling various pan gesture states.
  final GestureDragCancelCallback? onPanCancel;
  final GestureDragDownCallback? onPanDown;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      semantics: semantics,
      gestures: {
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
          // Create a PanGestureRecognizer with optional custom touch slop.
          () => PanGestureRecognizer()
            ..gestureSettings = DeviceGestureSettings(touchSlop: touchSlop),

          // Set up the recognizer's callbacks.
          (PanGestureRecognizer detector) {
            detector
              ..onDown = onPanDown
              ..onStart = onPanStart
              ..onUpdate = onPanUpdate
              ..onEnd = onPanEnd
              ..onCancel = onPanCancel;
          },
        )
      },
      child: child,
    );
  }
}

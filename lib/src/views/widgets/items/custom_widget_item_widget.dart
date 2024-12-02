import 'package:flutter/material.dart';
import 'package:simple_painter/simple_painter.dart';
import 'package:simple_painter/src/controllers/items/custom_widget_item.dart';
import 'package:simple_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:simple_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:simple_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:simple_painter/src/models/position_model.dart';
import 'package:simple_painter/src/models/size_model.dart';
import 'package:simple_painter/src/views/widgets/measure_size.dart';
import 'package:simple_painter/src/views/widgets/painter_container/painter_container.dart';

// StatefulWidget that manages the display and interaction with an image item
class CustomWidgetItemWidget extends StatefulWidget {
  const CustomWidgetItemWidget({
    required this.item,
    required this.height,
    required this.painterController,
    super.key,
    this.onPositionChange,
    this.onSizeChange,
    this.onRotationChange,
    this.onTapItem,
  });

  // The image item being displayed and interacted with
  final CustomWidgetItem item;
  // The height of the widget
  final double height;
  // Optional callback when the position of the item changes
  final void Function(PositionModel)? onPositionChange;
  // Optional callback when the size of the item changes
  final void Function(PositionModel, SizeModel)? onSizeChange;
  // Optional callback when the rotation of the item changes
  final void Function(double)? onRotationChange;
  // Optional callback when the item is tapped
  final void Function()? onTapItem;

  // The painter controller that controls the drawing behavior
  final PainterController painterController;

  @override
  State<CustomWidgetItemWidget> createState() => _CustomWidgetItemWidgetState();
}

// State class for CustomWidgetItemWidget, which handles the widget's state
class _CustomWidgetItemWidgetState extends State<CustomWidgetItemWidget> {
  // Variable to store the widget's height
  double? widgetHeight;

  // A ValueNotifier to track the position of the item
  ValueNotifier<PositionModel> position =
      ValueNotifier(const PositionModel(x: 50, y: 50));

  // Flag to trigger a refresh for the widget
  bool refreshValue = false; // The image widget might return height
  //as 0 if the image hasn't been processed yet,
  // hence we are manually triggering a refresh in
  //the MeasureSize widget's onChange method.

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      // Listening to position changes
      valueListenable: position,
      builder: (context, value, child) {
        return PainterContainer(
          // Determines if the current item is selected
          // based on the painterController's value
          selectedItem: widget.painterController.value.selectedItem != null &&
              widget.painterController.value.selectedItem?.id == widget.item.id,

          // Height of the painter container
          height: widget.height,
          minimumContainerHeight: 10,
          minimumContainerWidth: 10,

          // Position of the image item
          position: widget.item.position,

          // Rotation angle of the item
          rotateAngle: widget.item.rotation,

          // Size of the item
          size: widget.item.size,

          // Callback to handle item selection
          selectedItemChange: () {
            widget.painterController.value = widget.painterController.value
                .copyWith(selectedItem: widget.item);
          },

          // Callback to handle position change
          onPositionChange: (oldPosition, newPosition) {
            position.value = newPosition;
            widget.onPositionChange?.call(newPosition);
          },

          // Callback to handle rotation change
          onRotateAngleChange: (oldRotateAngle, newRotateAngle) {
            widget.onRotationChange?.call(newRotateAngle);
          },

          // Callback to handle size change
          onSizeChange: (newPosition, oldSize, newSize) {
            widget.onSizeChange?.call(newPosition, newSize);
          },

          // When position change ends, record the action
          onPositionChangeEnd: (
            oldPosition,
            newPosition,
          ) {
            widget.painterController.addAction(
              ActionPosition(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                timestamp: DateTime.now(),
                actionType: ActionType.positionItem,
              ),
            );
          },

          // When rotation change ends, record the action
          onRotateAngleChangeEnd: (oldRotateAngle, newRotateAngle) {
            widget.painterController.addAction(
              ActionRotation(
                item: widget.item,
                oldRotateAngle: oldRotateAngle,
                newRotateAngle: newRotateAngle,
                timestamp: DateTime.now(),
                actionType: ActionType.rotationItem,
              ),
            );
          },

          // When size change ends, record the action
          onSizeChangeEnd: (oldPosition, oldSize, newPosition, newSize) {
            widget.painterController.addAction(
              ActionSize(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                oldSize: oldSize,
                newSize: newSize,
                timestamp: DateTime.now(),
                actionType: ActionType.sizeItem,
              ),
            );
          },

          // Callback to handle tap on the item
          onTapItem: ({bool? tapItem}) {
            if (tapItem != null && !tapItem && widget.onTapItem != null) {
              widget.onTapItem!.call();
            }
          },

          // Only enable the painter container if the widgetHeight is available
          enabled: widgetHeight != null,

          // Color of the drag handle for the item
          dragHandleColor:
              widget.painterController.value.settings.itemDragHandleColor,

          // Checks if the item should be rendered
          renderItem: widget.painterController.itemRender.copyWith(
            containerItemId: widget.item.id,
          ),
          // Assigns the rendered image to the painterController
          onRenderImage: (item) {
            widget.painterController.itemRender = item;
          },
          // Child widget that wraps the image
          child: MeasureSize(
            // Measure the size of the child and
            // update widgetHeight if necessary
            onChange: (size) {
              if (widgetHeight != null) return;
              setState(() {
                widgetHeight = size.height;
              });
            },
            child: SizedBox(
              width: double.infinity,
              child: imageBody, // The body of the image widget
            ),
          ),
        );
      },
    );
  }

  // Builds the body of the image widget, which consists of layers
  Widget get imageBody => Stack(
        children: [
          // Positioned image as the background
          Positioned.fill(child: childWidget),
          // Positioned container with a border around the image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.item.borderRadius,
                border: Border.all(
                  color: widget.item.borderColor,
                  width: widget.item.borderWidth,
                ),
              ),
            ),
          ),
          // Apply gradient overlay if enabled
          if (widget.item.gradientOpacity > 0 &&
              widget.item.enableGradientColor)
            Positioned.fill(
              child: Opacity(
                opacity: widget.item.gradientOpacity,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: widget.item.gradientBegin,
                      end: widget.item.gradientEnd,
                      colors: [
                        widget.item.gradientStartColor,
                        widget.item.gradientEndColor,
                      ],
                      stops: const [0.0, 1.0],
                    ).createShader(bounds);
                  },
                  child: childWidget,
                ),
              ),
            ),
        ],
      );

  // Builds the widget, wrapped in a ClipRRect to apply border radius
  Widget get childWidget => ClipRRect(
        borderRadius: widget.item.borderRadius,
        child: widget.item.widget,
      );
}

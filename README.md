
# Painter Widget

**Flutter Painter** is a Flutter package that lets users create and manipulate a drawing canvas with layers. It supports adding and styling text, images, and shapes, along with freehand drawing tools, customizable brush sizes, and colors. The package also includes undo/redo functionality and custom background support.


![simple_painter_ps](https://github.com/user-attachments/assets/f4bba725-2b8f-4431-9762-11ef65a97354)

<img src="https://github.com/user-attachments/assets/fff50318-1383-4edc-98c1-5fab99cb6cd7" height="500" style="display: inline-block; margin-right: 10px;">
<img src="https://github.com/user-attachments/assets/dec54c47-97df-42c9-a380-9907f1e760be" height="500" style="display: inline-block;">


### Features

- **Drawing Tools**
  - Freehand drawing with customizable brush size and color.
  - Eraser tool for removing strokes.

- **State Management**
  - Undo and redo functionality for actions.
  - Export final design as an image.
    
- **Interactive Elements**
  - Add, move, resize, rotate, and delete text, images, or shapes.
  - Edit styles of added elements, such as font size, color, or shape properties.
  - Layer-based organization of elements.

- **Custom Background**
  - Load custom images as the background.
  - Preserve aspect ratio for responsive designs.


---

## Installation

To start using **Painter Widget**, add it to your project's `pubspec.yaml` file:

```yaml
dependencies:
  simple_painter: ^1.2.0
```

Then, run the following command in your terminal:

```bash
flutter pub get
```


### Getting Started

1. Import the package in your Dart file:

```dart
import 'package:painter_widget/simple_painter.dart';
```

2. Create a `PainterController` to manage the drawing and interactions:

```dart
final PainterController controller = PainterController();
```

3. Add the `PainterWidget` to your widget tree:

```dart
PainterWidget(controller: controller);
```

---

## Usage Examples

### Basic Implementation

Here’s how to set up a basic painting widget with a simple controller:

```dart
import 'package:flutter/material.dart';
import 'package:painter_widget/simple_painter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = PainterController();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Painter Widget Example')),
        body: PainterWidget(controller: controller),
      ),
    );
  }
}
```

### Drawing and Erasing

Enable drawing and erasing with these configurations:

```dart
controller.toggleDrawing();;  // Enable freehand drawing

controller.changeBrushValues( // Edit brush options
size: 15
color: Color(0xFFFFFF),
;

controller.toggleErasing();  // Enable eraser mode
```

### Rendering Canvas And Items As Images

```dart
controller.renderImage(); // Render canvas as image

controller.renderItem(item, enableRotation: true); // Render items as image
```

### Adding Interactive Items

Add text, shapes, or images dynamically:

```dart
await controller.addText(text); // Add text item

controller.changeTextValues( // Change text style
item,
textStyle: TextStyle(),
textAlign: TextAlign.center,
enableGradientColor: false,
...
)

controller.addImage(imageUint8List); // Add image item

controller.changeImageValues(  // Change image style
item,
boxFit: BoxFit.fill,
borderRadius: BorderRadius.circular(intValue.toDouble()),
borderColr: Color(0xFFFFFF),
...
)

controller.addShape(shape); // Add shape item

controller.addCustomWidget(widget); // Add custom widget item

```

### Set Items Properties

Modify the position, size, and rotation of any item dynamically using the changeItemProperties function:

```dart
ontroller.changeItemProperties(
  item,
  position: PositionModel(
    x: item.position.x + 10,
    y: item.position.y + 10,
  ),
  size: SizeModel(
    width: item.size!.width + 100,
    height: item.size!.height + 100,
  ),
  rotation: 0,
);
```

### Custom Background Image

Set a background image while maintaining aspect ratio:

```dart
await controller.setBackgroundImage(imageUint8List);

// or

controller = PainterController(
backgroundImage: imageUint8List,
);
```

**NOTE:** For more detailed information and to test features like layer management, state handling, and element styling, please visit the [Painter Full Stack Example](https://github.com/CanArslanDev/simple_painter/tree/main/example/fullstack_example).

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add feature'`).
4. Push to your branch (`git push origin feature-name`).
5. Open a pull request.

---

## License

This package is distributed under the MIT License. See [LICENSE](LICENSE) for more information.


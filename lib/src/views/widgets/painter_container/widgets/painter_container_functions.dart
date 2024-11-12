// ignore_for_file: library_private_types_in_public_api

part of '../painter_container.dart';

double _getHandleWidgetWidth(
  _HandlePosition handlePosition,
  double handleWidgetWidth,
  SizeModel containerSize,
) {
  switch (handlePosition) {
    case _HandlePosition.top:
    case _HandlePosition.bottom:
      final size = containerSize.width / 7;
      return size < 15 ? 15 : size;
    case _HandlePosition.left:
    case _HandlePosition.right:
      return handleWidgetWidth;
  }
}

double _getHandleWidgetHeight(
  _HandlePosition handlePosition,
  double handleWidgetHeight,
  SizeModel containerSize,
) {
  switch (handlePosition) {
    case _HandlePosition.top:
    case _HandlePosition.bottom:
      return handleWidgetHeight;
    case _HandlePosition.left:
    case _HandlePosition.right:
      final size = containerSize.height / 7;
      return size < 15 ? 15 : size;
  }
}

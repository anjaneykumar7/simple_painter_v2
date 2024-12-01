part of '../../painter_controller.dart';

extension PainterControllerItemValues on PainterController {
  // applies changes to a specific item and updates the state
  void _changeItemValues(PainterItem item) {
    ChangeItemValuesService().changeItemValues(
      item,
      value.items.toList(),
      (action, items, selectedItem) {
        value = value.copyWith(
          items: items,
          selectedItem: selectedItem as PainterItem,
        );
        addAction(action);
      },
    );
  }
}

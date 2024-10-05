class LayerSettings {
  const LayerSettings({
    required this.title,
    required this.index,
  });

  final String title;
  final int index;

  LayerSettings copyWith({
    String? title,
    int? index,
  }) {
    return LayerSettings(
      title: title ?? this.title,
      index: index ?? this.index,
    );
  }
}

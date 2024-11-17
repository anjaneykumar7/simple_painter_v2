class EraseSettings {
  const EraseSettings({
    required this.size,
  });

  final double size;

  EraseSettings copyWith({
    double? size,
  }) {
    return EraseSettings(
      size: size ?? this.size,
    );
  }
}

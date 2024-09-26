import 'package:equatable/equatable.dart';

class SizeModel extends Equatable {
  const SizeModel({this.width = 0, this.height = 0});

  final double height;
  final double width;

  SizeModel copyWith({double? width, double? height}) {
    return SizeModel(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [width, height];
}

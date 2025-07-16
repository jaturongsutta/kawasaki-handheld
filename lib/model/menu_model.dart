import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuModel {
  final String menuNo;
  final String menuNameTH;
  final String url;

  MenuModel({
    required this.menuNo,
    required this.menuNameTH,
    required this.url,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => _$MenuModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuModelToJson(this);
}

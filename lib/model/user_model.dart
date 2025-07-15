import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  @JsonKey(name: 'userId')
  final int? userId;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  // @JsonKey(name: 'Role_ID')
  // final int? RoleID;

  // @JsonKey(name: 'Is_Active')
  // final String IsActive;

  @JsonKey(name: 'lineOptions')
  final List<String>? lineOptions;

  UserModel({
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    // required this.RoleID,
    // required this.IsActive,
    this.lineOptions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

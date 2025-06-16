import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  @JsonKey(name: 'User_ID')
  final int? UserID;
  @JsonKey(name: 'Username')
  final String Username;
  @JsonKey(name: 'First_Name')
  final String? FirstName;
  @JsonKey(name: 'Last_Name')
  final String? LastName;
  @JsonKey(name: 'Role_ID')
  final int? RoleID;
  @JsonKey(name: 'Is_Active')
  final String IsActive;

  UserModel({
    required this.UserID,
    required this.Username,
    this.FirstName,
    this.LastName,
    required this.RoleID,
    required this.IsActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

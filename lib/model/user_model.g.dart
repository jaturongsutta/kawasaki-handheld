// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      UserID: (json['User_ID'] as num?)?.toInt(),
      Username: json['Username'] as String,
      FirstName: json['First_Name'] as String?,
      LastName: json['Last_Name'] as String?,
      RoleID: (json['Role_ID'] as num?)?.toInt(),
      IsActive: json['Is_Active'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'User_ID': instance.UserID,
      'Username': instance.Username,
      'First_Name': instance.FirstName,
      'Last_Name': instance.LastName,
      'Role_ID': instance.RoleID,
      'Is_Active': instance.IsActive,
    };

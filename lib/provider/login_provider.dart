import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kmt/model/user_model.dart';
import 'package:kmt/util/local_storage_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  String? _token;
  UserModel? _user;
  // List<MenuPermissionModel>? _menuPermissionList;

  String? get token => _token;
  UserModel? get user => _user;
  // List<MenuPermissionModel>? get menuPermissionList => _menuPermissionList;

  LoginProvider() {
    _loadToken();
    getUser();
  }

  Future<void> _saveUser(UserModel userJson) async {}

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      Map<String, dynamic> userJson = jsonDecode(userData);
      return User.fromJson(userJson);
    } else {
      return null;
    }
  }

  Future<void> _deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  // Future<void> _saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('token', token);
  // }

  Future<void> _saveToken(String token) async {
    await LocalStorage.setLocalStorage(key: 'token', object: token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> savelogin(dynamic data) async {
    if (data != null) {
      _token = data['token'];

      await LocalStorage.setLocalStorage(key: 'token', object: _token);
      await LocalStorage.setLocalStorage(key: 'user', object: data['user']);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    await LocalStorage.removeLocalStorage(key: 'token');
    await LocalStorage.removeLocalStorage(key: 'user');
    await LocalStorage.removeLocalStorage(key: 'menuPermissionList');
    notifyListeners();
  }
}

class User {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final int roleId;
  final String isActive;

  User({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    required this.roleId,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['User_ID'],
      username: json['Username'],
      firstName: json['First_Name'],
      lastName: json['Last_Name'],
      roleId: json['Role_ID'],
      isActive: json['Is_Active'],
    );
  }
}

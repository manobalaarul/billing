import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  final GetStorage _storage = GetStorage();

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(AppConfig.tokenKey, token);
  }

  String? getToken() {
    return _storage.read(AppConfig.tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.remove(AppConfig.tokenKey);
  }

  // User management
  Future<void> saveUser(UserModel user) async {
    await _storage.write(AppConfig.userKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userJson = _storage.read(AppConfig.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> removeUser() async {
    await _storage.remove(AppConfig.userKey);
  }

  // Login status
  Future<void> setLoggedIn(bool value) async {
    await _storage.write(AppConfig.isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _storage.read(AppConfig.isLoggedInKey) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.erase();
  }

  // Generic key-value storage
  Future<void> save(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _storage.remove(key);
  }
}

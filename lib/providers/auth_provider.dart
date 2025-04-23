import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> register(String name, String email, String password) async {
    final db = await DBService.db;

    await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<bool> login(String email, String password) async {
    final db = await DBService.db;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      _user = UserModel.fromMap(result.first);
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _user!.id!);

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final db = await DBService.db;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        _user = UserModel.fromMap(result.first);
        _isAuthenticated = true;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

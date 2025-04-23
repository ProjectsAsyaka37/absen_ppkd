import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';

class UserProvider with ChangeNotifier {
  Future<void> updateUser(UserModel user) async {
    final db = await DBService.db;

    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    notifyListeners();
  }
}

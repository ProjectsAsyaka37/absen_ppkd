import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/db_service.dart';

class AbsensiProvider with ChangeNotifier {
  /// Simpan data absensi masuk atau pulang
  Future<void> absen({
    required int userId,
    required String type, // "masuk" atau "pulang"
  }) async {
    final db = await DBService.db;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final now = DateTime.now().toIso8601String();

    await db.insert('absensi', {
      'user_id': userId,
      'type': type,
      'datetime': now,
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    notifyListeners();
  }

  /// Cek apakah user sudah absen tipe tertentu pada hari ini
  Future<bool> hasAbsensiToday(int userId, String type) async {
    final db = await DBService.db;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT * FROM absensi
      WHERE user_id = ? AND type = ? AND datetime >= ?
    ''',
      [userId, type, todayStart],
    );

    return result.isNotEmpty;
  }
}

class AbsensiModel {
  final int? id;
  final int userId;
  final String type; // masuk / pulang
  final DateTime datetime;
  final double latitude;
  final double longitude;

  AbsensiModel({
    this.id,
    required this.userId,
    required this.type,
    required this.datetime,
    required this.latitude,
    required this.longitude,
  });

  factory AbsensiModel.fromMap(Map<String, dynamic> map) {
    return AbsensiModel(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      datetime: DateTime.parse(map['datetime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

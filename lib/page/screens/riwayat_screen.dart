import 'package:absen_ujk/models/absensi_model.dart';
import 'package:absen_ujk/providers/auth_provider.dart';
import 'package:absen_ujk/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RiwayatScreen extends StatefulWidget {
  static const routeName = '/riwayat';

  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<AbsensiModel> _riwayat = [];
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() async {
    final db = await DBService.db;
    final userId = Provider.of<AuthProvider>(context, listen: false).user!.id!;

    final start = DateTime(_selectedYear, _selectedMonth, 1);
    final end = DateTime(_selectedYear, _selectedMonth + 1, 1);

    final result = await db.query(
      'absensi',
      where: 'user_id = ? AND datetime >= ? AND datetime < ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'datetime DESC',
    );

    setState(() {
      _riwayat = result.map((e) => AbsensiModel.fromMap(e)).toList();
    });
  }

  String _formatTanggal(DateTime dt) {
    return DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Absensi")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          DateFormat.MMMM('id_ID').format(DateTime(0, month)),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                        _loadRiwayat();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                        _loadRiwayat();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _riwayat.isEmpty
                    ? Center(child: Text("Tidak ada data absensi."))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _riwayat.length,
                      itemBuilder: (context, index) {
                        final item = _riwayat[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              item.type == 'masuk' ? Icons.login : Icons.logout,
                              color:
                                  item.type == 'masuk'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            title: Text(
                              "${item.type.toUpperCase()} - ${_formatTanggal(item.datetime)}",
                            ),
                            subtitle: Text(
                              "Lat: ${item.latitude.toStringAsFixed(5)}\nLng: ${item.longitude.toStringAsFixed(5)}",
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

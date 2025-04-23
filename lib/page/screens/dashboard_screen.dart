import 'package:absen_ujk/providers/absensi_provider.dart';
import 'package:absen_ujk/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied)
        return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
  }

  String _getFormattedDate(DateTime now) {
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final absensiProvider = Provider.of<AbsensiProvider>(
      context,
      listen: false,
    );
    final user = authProvider.user;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat datang, ${user?.name ?? '-'}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 6),
            Text(
              _getFormattedDate(now),
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              _currentPosition != null
                  ? "Lokasi: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}"
                  : "Mengambil lokasi...",
              style: TextStyle(color: Colors.grey[800]),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DashboardButton(
                  title: "Absen Masuk",
                  color: Colors.green,
                  icon: Icons.login,
                  onPressed: () async {
                    if (user != null) {
                      await absensiProvider.absen(
                        userId: user.id!,
                        type: 'masuk',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Absen masuk berhasil")),
                      );
                    }
                  },
                ),
                SizedBox(width: 16),
                _DashboardButton(
                  title: "Absen Pulang",
                  color: Colors.red,
                  icon: Icons.logout,
                  onPressed: () async {
                    if (user != null) {
                      await absensiProvider.absen(
                        userId: user.id!,
                        type: 'pulang',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Absen pulang berhasil")),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.history),
                label: Text("Lihat Riwayat Absensi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/riwayat');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _DashboardButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

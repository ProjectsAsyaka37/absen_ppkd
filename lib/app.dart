import 'package:flutter/material.dart';
import 'utils/app_routes.dart';
import 'page/screens/login_screen.dart';
import 'page/screens/register_screen.dart';
import 'page/screens/dashboard_screen.dart'; // nanti kita buat ini
import 'page/screens/riwayat_screen.dart'; // import screen riwayat
import 'page/screens/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABSENSI PPKD',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.register: (context) => RegisterScreen(),
        AppRoutes.dashboard: (context) => DashboardScreen(), // placeholder
        AppRoutes.riwayat: (context) => RiwayatScreen(),
        AppRoutes.profile: (context) => ProfileScreen(),
      },
    );
  }
}

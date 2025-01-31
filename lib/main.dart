// File: main.dart

import 'package:flutter/material.dart';
import 'Widget/HomePage.dart';
import 'Widget/MapPage.dart';
import 'Widget/ProfilePage.dart';
import 'Widget/DiagnosticToolsPage.dart';
import 'config/supabase_config.dart';
import 'pages/login.dart';

export 'main.dart' show BottomNavBar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  
  // Add this test
  try {
    final response = await supabase.from('profiles').select().limit(1);
    print('Supabase connection successful: $response');
  } catch (e) {
    print('Supabase connection error: $e');
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E225A),
        scaffoldBackgroundColor: const Color(0xFFE4E4EC),
      ),
      home: const LoginPage(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    DiagnosticToolsPage(),
    const MapPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set background to white
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E225A),
        unselectedItemColor: const Color(0xFF86829F),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye_rounded),
            label: 'Diagnostic Tool',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.maps_home_work),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

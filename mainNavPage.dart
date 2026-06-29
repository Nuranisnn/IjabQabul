import 'package:flutter/material.dart';
import 'package:my_app/homepage.dart';
import 'package:my_app/timelineviewscreen.dart';
import 'package:my_app/Profile.dart';
import 'package:my_app/screens/packages/package_browse_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // The source uses a Serif-style font for titles
        primarySwatch: Colors.pink,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 1. Track the current index of the bottom navigation bar
  int _selectedIndex = 0; // Defaulting to 'Profile' as seen in the source [1]

  // Custom colors from the image
  final Color primaryPink = const Color(0xFFF3D5D5);
  final Color backgroundColor = const Color(0xFFFFF9E5);

  // 2. Define the different pages for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // The UI from the source image [1]
      const TimelineViewScreen(), // The timeline view screen
      const PackageBrowseScreen(),
      const ProfilePage(), // The UI from the source image [1]
      // The onboarding screen for user input
    ];
  }

  // 3. Method to handle tab switching
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryPink,
        elevation: 0,
        leading: null,
        title: const Text(
          'IjabQabul',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif', // Matching the source style [1]
          ),
        ),
        centerTitle: true,
      ),
      // 4. Display the page based on the selected index
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryPink,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handles the state change
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Timeline'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Package'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
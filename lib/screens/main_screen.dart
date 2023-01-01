import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import './homepage.dart';
import './about.dart';
import './downloads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List pages = [
    HomePage(),
    DownloadsPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        animationDuration: const Duration(milliseconds: 300),
        color: Color.fromARGB(255, 255, 245, 245),
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.white,
        onTap: ((value) {
          setState(() {
            _currentIndex = value;
          });
        }),
        items: [
          Image.asset(
            'assets/icons/home.png',
            width: 24,
            color: Color.fromARGB(255, 89, 0, 0),
          ),
          Image.asset(
            'assets/icons/download.png',
            width: 24,
            color: Color.fromARGB(255, 89, 0, 0),
          ),
          Image.asset(
            'assets/icons/info.png',
            width: 24,
            color: Color.fromARGB(255, 89, 0, 0),
          )
        ],
      ),
    );
  }
}

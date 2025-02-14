import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:synny_space/screens/tab_bar_holder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final List<Text> _tabsTitles = [
    const Text('Sunny Base'),
    const Text('Мій профіль'),
  ];

  final List<Widget> _tabs = [
    const TabBarHolder(),
     ProfileScreen(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(2),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/images/gerb.png'),
          ),
        )
      ],
    ),
  ];

  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: _tabsTitles[selectedIndex],
      ),

      body: _tabs[selectedIndex], //BODY
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 27, 160, 95),
        selectedFontSize: 17,
        selectedIconTheme: const IconThemeData(
            color: Color.fromARGB(255, 27, 160, 95), size: 32),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Сховище',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Профіль',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}

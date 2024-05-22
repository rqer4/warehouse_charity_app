// import 'package:flutter/material.dart';

// class BottomBar extends StatefulWidget {
//   const BottomBar({super.key});
//   @override
//   State<BottomBar> createState() {
//     return _BottomBarClass();
//   }
// }

// class _BottomBarClass extends State<BottomBar> {
  
//   int selectedIndex = 0;

//     void onItemTapped(int index) {
//       setState(() {
//         selectedIndex = index;
//       });
//     }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       selectedItemColor: const Color.fromARGB(255, 27, 160, 95),
//       selectedFontSize: 17,
//       selectedIconTheme: const IconThemeData(color: Color.fromARGB(255, 27, 160, 95), size: 32),
//       selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.list_alt_rounded),
//           label: 'List',
          
//         ),
        
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_rounded),
//           label: 'Account',

//         ),
        
//       ],
//       currentIndex: selectedIndex, 
//       onTap: onItemTapped,
//     );
//   }
// }

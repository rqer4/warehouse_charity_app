import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
        children: [
          SubmenuButton(
            
            menuChildren: [
              Text('child1'),
              Text('Child2'),
            ],
            child: Text('button'),
          )
        ],
      );

  }
}

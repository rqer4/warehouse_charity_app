import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:synny_space/firebase_options.dart';
import 'package:synny_space/screens/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
    ),
  );
}

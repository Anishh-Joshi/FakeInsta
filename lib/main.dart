import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minigram',
      theme: ThemeData(
        primaryColor: Colors.pink,
        accentColor: Colors.redAccent
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

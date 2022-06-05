import 'package:flutter/material.dart';
import 'package:STTC_NOTEPAD/screens/SplashScreen.dart';
import 'package:STTC_NOTEPAD/screens/note_detail.dart';
import 'package:STTC_NOTEPAD/screens/note_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STTC_NOTEPAD',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreen(),
    );
  }
}

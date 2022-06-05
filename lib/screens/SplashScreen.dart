import 'dart:async';
import 'package:flutter/material.dart';
import 'package:STTC_NOTEPAD/screens/InstructionScreen.dart';
import 'note_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new NoteList()));
    } else {
      prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => InsScreen(buttonname: "Lets Begin")));
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () => /*Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => InsScreen()))*/
          checkFirstSeen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Image.asset('graphics/splash.png'),
      ),
    );
  }
}

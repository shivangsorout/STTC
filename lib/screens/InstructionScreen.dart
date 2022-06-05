import 'package:flutter/material.dart';
import 'package:STTC_NOTEPAD/screens/note_detail.dart';
import 'note_list.dart';

class InsScreen extends StatefulWidget {
  final String buttonname;
  InsScreen(this.buttonname);
  @override
  State<StatefulWidget> createState() {
    return InsScreenState(this.buttonname);
  }
}

class InsScreenState extends State<InsScreen> {
  String buttonname;
  static String m;
  InsScreenState(this.buttonname);
  @override
  Widget build(BuildContext context) {
    m = buttonname;
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructions'),
      ),
      body: instructionText(context),
      backgroundColor: Colors.black,
    );
  }
}

Widget instructionText(context) {
  return SingleChildScrollView(
    child: Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 30, right: 15, left: 15),
        child: Text(
            '1. Tap on "+" button on the right bottom of the Screen. \n2. Now on the Add Note screen tap on the red color mic button. Now another screen appears which is "Transcription" Screen.\n3. Now tap on the mic button and say something like "hello".\n4. Now tap on update button. Now all the textfields and buttons on the Add/Edit note screen are enabled.\n5. Now select the priority of note Low or High and fill the title.\n6. Now for description to be updated tap on Update Description Button and then tap on Save button your note will be saved.\n\n You can edit the note by tapping on the note and there you can update the textfield by typing or transcription and tap on save button.Your note will be updated.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
      ),
      Padding(
          padding: EdgeInsets.only(top: 100, bottom: 30, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                textColor: Colors.white,
                child: Text(
                  InsScreenState.m,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return NoteList();
                  }));
                },
              ),
            ],
          )),
    ]),
  );
}

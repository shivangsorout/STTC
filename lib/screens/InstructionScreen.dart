import 'package:flutter/material.dart';
import 'package:STTC_NOTEPAD/screens/note_detail.dart';
import 'note_list.dart';

class InsScreen extends StatelessWidget {
  final String buttonname;
  final TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.white,
  );
  final List<String> _instructions = [
    'Tap on "+" button on the right bottom of the Screen.',
    'Now on the Add Note screen tap on priority to select priority of the note.',
    'Now fill the title in title field.',
    'Now fill the description field either by typing or by speaking.',
    'For speech to text tap on microphone button and after it starts listening then speak.',
    'Now after creating a note you can save it by tapping on save button.',
  ];

  InsScreen({@required this.buttonname});

  static String m;
  @override
  Widget build(BuildContext context) {
    m = buttonname;
    return Scaffold(
      appBar: AppBar(
        leading: InsScreen.m == 'Go Back'
            ? IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            : false,
        automaticallyImplyLeading: false,
        title: Text('Instructions'),
      ),
      body: instructionText(context),
      backgroundColor: Colors.black,
    );
  }

  Widget instructionText(context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '${index + 1}. ',
                        style: _textStyle,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: _instructions[index],
                          style: _textStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: _instructions.length,
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, right: 15, left: 15),
            child: Text(
              'You can edit the note by tapping on the note and there you can update the textfield by typing or transcription and tap on save button. Your note will be updated.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
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
                      InsScreen.m,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: InsScreen.m == 'Go Back'
                        ? () {
                            Navigator.pop(context);
                          }
                        : () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return NoteList();
                                },
                              ),
                              (_) => false,
                            );
                          },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

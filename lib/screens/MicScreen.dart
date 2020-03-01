import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:STTC_NOTEPAD/screens/note_detail.dart';

class MicScreen extends StatefulWidget {
  MicScreen();
  @override
  State<StatefulWidget> createState() {
    return MicScreenState();
  }
}

class MicScreenState extends State<MicScreen> {
  static String a;
  TextEditingController descriptionController = TextEditingController();
  Note note;
  String result;
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  static String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );
    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );
    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );
    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech To Text Converter'),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 15.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 17.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: 'btn1.2',
                  child: Icon(Icons.mic),
                  backgroundColor: Colors.pink,
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "en_US")
                          .then((result) => print('$result'));
                  },
                ),
              ],
            ),
          ),
          new RaisedButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text(
                "Update",
                textScaleFactor: 1.5,
              ),
              onPressed: () {
                debugPrint("Update pressed");
                a = "$resultText";
                Navigator.pop(context, true);
              })
        ],
      )),
    );
  }
}

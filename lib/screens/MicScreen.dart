import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:app_settings/app_settings.dart';

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
  Map<Permission, PermissionStatus> permissions = {};

  static String resultText = "";

  @override
  void initState() {
    super.initState();
    getPermission();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler((bool result) => setState(() => _isAvailable = result));
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

  Future askForPermissions() async {
    permissions = await [Permission.microphone, Permission.speech].request();
  }

  getPermission() async {
    await askForPermissions();
    if (permissions[Permission.microphone].isDenied || permissions[Permission.speech].isDenied) {
      askForPermissions();
    }
    if (permissions[Permission.speech].isPermanentlyDenied || permissions[Permission.microphone].isPermanentlyDenied) {
      AppSettings.openAppSettings();
    }
    if (permissions[Permission.speech].isGranted && permissions[Permission.microphone].isGranted) {
      return true;
    } else {
      await getPermission();
      return false;
    }
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
                    if (_isAvailable && !_isListening) _speechRecognition.listen(locale: "en_US").then((result) => print('RESULT: $result'));
                  },
                ),
              ],
            ),
          ),
          new MaterialButton(
              color: Theme.of(context).colorScheme.secondary,
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

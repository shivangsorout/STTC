import 'package:STTC_NOTEPAD/components/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:app_settings/app_settings.dart';

class MicScreen extends StatefulWidget {
  final String lastTimeText;

  MicScreen({@required this.lastTimeText});
  @override
  State<StatefulWidget> createState() {
    return MicScreenState();
  }
}

class MicScreenState extends State<MicScreen> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  Map<Permission, PermissionStatus> permissions = {};

  String resultText = "";
  String previousText = '';
  String recordedText = '';

  @override
  void initState() {
    super.initState();
    if (widget.lastTimeText != null && widget.lastTimeText != "") {
      setState(() {
        resultText = widget.lastTimeText;
      });
    }
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
      (String speech) => setState(() {
        recordedText = speech;
        resultText = previousText + (previousText != '' ? " " : "") + recordedText;
      }),
    );
    _speechRecognition.setRecognitionCompleteHandler(
      (_) => setState(() => _isListening = false),
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
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                resultText == '' ? 'Press button and say something...' : resultText,
                style: TextStyle(fontSize: 17.0, color: Colors.black),
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
                    setState(() {
                      previousText = resultText;
                    });
                    if (_isAvailable && !_isListening) _speechRecognition.listen(locale: "en_US").then((result) => print('RESULT: $result'));
                  },
                ),
              ],
            ),
          ),
          if (resultText != '')
            Row(
              children: [
                Expanded(
                  child: NormalButton(
                    title: 'Clear',
                    onPressed: () {
                      setState(() {
                        recordedText = '';
                        resultText = '';
                        previousText = '';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: NormalButton(
                    title: 'Update',
                    onPressed: () {
                      Navigator.pop(context, resultText);
                    },
                  ),
                ),
              ],
            ),
        ],
      )),
    );
  }
}

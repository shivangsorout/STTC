import 'package:STTC_NOTEPAD/components/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:STTC_NOTEPAD/utils/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'MicScreen.dart';
import 'package:app_settings/app_settings.dart';

class NoteDetail extends StatefulWidget {
  final String AppBarTitle;
  final Note note;

  NoteDetail(this.note, this.AppBarTitle);

  @override
  State<StatefulWidget> createState() {
    return _NoteDetailState(this.note, this.AppBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail> {
  var _formKey = GlobalKey<FormState>();

  String AppBarTitle;
  Note note;

  DatabaseHelper databaseHelper = DatabaseHelper();

  static var _priorities = ["Low", "High"];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  OutlineInputBorder borderStyle = OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple), borderRadius: BorderRadius.circular(15.0));

  // Variables for microphone
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  Map<Permission, PermissionStatus> permissions = {};

  String resultText = "";
  String previousText = '';
  String recordedText = '';
  // End

  _NoteDetailState(this.note, this.AppBarTitle);

  @override
  void initState() {
    setState(() {
      titleController.text = note.title;
      descriptionController.text = note.description;
    });
    getPermission();
    initSpeechRecognizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;

    return Scaffold(
        appBar: AppBar(
          title: Text(AppBarTitle),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: getBody(textStyle),
            )));
  }

  ListView getBody(TextStyle textStyle) {
    return ListView(
      children: <Widget>[
        //First element
        Container(
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: DropdownButton(
            dropdownColor: Colors.grey[900],
            borderRadius: BorderRadius.all(Radius.circular(10)),
            isExpanded: true,
            underline: SizedBox(),
            items: _priorities.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
            onChanged: (valueSelectedByUser) {
              setState(() {
                debugPrint("User selected $valueSelectedByUser");
                getIntPriority(valueSelectedByUser);
              });
            },
            value: getStringPriority(note.priority),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),

        //Second element
        Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextFormField(
              enabled: true,
              controller: titleController,
              style: TextStyle(color: Colors.white, fontSize: 18),
              validator: getValidator('Title'),
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
                enabledBorder: borderStyle,
                focusedBorder: borderStyle,
                border: borderStyle,
              ),
            )),

        //Third element
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            enabled: true,
            validator: getValidator('Description'),
            controller: descriptionController,
            style: TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              alignLabelWithHint: true,
              labelText: "Description",
              labelStyle: TextStyle(color: Colors.white, fontSize: 20),
              errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
              enabledBorder: borderStyle,
              border: borderStyle,
              focusedBorder: borderStyle,
            ),
          ),
        ),

        //Fourth element
        Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
              FloatingActionButton(
                heroTag: 'btn2',
                child: Icon(Icons.mic),
                backgroundColor: Colors.red,
                onPressed: () {
                  if (permissions[Permission.speech].isGranted && permissions[Permission.speech].isGranted) {
                    setState(() {
                      previousText = descriptionController.text;
                    });
                    if (_isAvailable && !_isListening) _speechRecognition.listen(locale: "en_US").then((result) => print('RESULT: $result'));
                  } else {
                    getPermission();
                    initSpeechRecognizer();
                  }
                },
              ),
            ])),

        //Fifth element

        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: NormalButton(
            title: 'Clear',
            onPressed: descriptionController.text.isEmpty
                ? null
                : () {
                    setState(() {
                      recordedText = '';
                      resultText = '';
                      previousText = '';
                      descriptionController.text = '';
                    });
                  },
          ),
        ),

        // Sixth Element

        Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: NormalButton(
                    title: 'Save',
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _save();
                      }
                    },
                  ),
                ),
                Expanded(
                    child: NormalButton(
                  title: 'Delete',
                  onPressed: () {
                    _delete();
                  },
                )),
              ],
            ))
      ],
    );
  }

//Convert String priority to the integer form before saving to the database
  void getIntPriority(String priority) {
    switch (priority) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
      default:
        note.priority = 2;
    }
  }

//Convert int priority to String and display it to the user in dropdown
  String getStringPriority(int priority) {
    String priorityString;
    switch (priority) {
      case 1:
        priorityString = _priorities[1]; //High
        break;
      case 2:
        priorityString = _priorities[0]; //Low
        break;
      default:
        priorityString = _priorities[0];
    }
    return priorityString;
  }

  //Update the title of the note object
  void updateTitle() {
    note.title = titleController.text;
  }

//Update description of note object
  void updateDescription() {
    if (resultText != null && resultText != "") descriptionController.text = resultText;
    note.description = descriptionController.text;
  }

  void _save() async {
    updateTitle();
    updateDescription();
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      //Case 1: update operation
      result = await databaseHelper.updateNote(note);
    } else {
      //Case 2: insert operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      // success!
      _showAlertDialog("Status", "Note Saved Successfully");
    } else {
      //failure
      _showAlertDialog("Status", "Problem saving Note");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _delete() async {
    moveToLastScreen();
    //Case 1: if the user is trying to delete the new note, if he has come to the
    //details page by pressing the fab
    if (note.id == null) {
      _showAlertDialog("Status", "No note was deleted");
      return;
    }
    //Case 2: if the user is trying to delete the note saved in the database
    //and has a valid id
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog("Status", "Note Deleted Successfully.");
    } else {
      _showAlertDialog("Status", "Error occurred while deleting note");
    }
  }

  void moveToLastScreen() {
    //pop accepts other parameter (can be anything?)
    Navigator.pop(context, true);
  }

  FormFieldValidator<String> getValidator(String validation) {
    return (String value) {
      if (value.isEmpty) {
        return 'Please enter a $validation!';
      }
    };
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler((bool result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );
    _speechRecognition.setRecognitionResultHandler((String speech) {
      setState(() {
        recordedText = speech;
        resultText = previousText + (previousText != '' ? " " : "") + recordedText;
        if (resultText != null) descriptionController.text = resultText;
      });
    });
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
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:STTC_NOTEPAD/utils/database_helper.dart';
import 'MicScreen.dart';

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
  MicScreenState m;

  DatabaseHelper databaseHelper = DatabaseHelper();

  static var _priorities = ["Low", "High"];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.AppBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;

    titleController.text = note.title;
    descriptionController.text = note.description;

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
        ListTile(
            title: DropdownButton(
          items: _priorities.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0)
              ? null
              : (valueSelectedByUser) {
                  setState(() {
                    debugPrint("User selected $valueSelectedByUser");
                    getIntPriority(valueSelectedByUser);
                  });
                },
          value: getStringPriority(note.priority),
          style: TextStyle(color: Colors.white, fontSize: 25, backgroundColor: Colors.black),
        )),

        //Second element
        Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextFormField(
              enabled: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0) ? false : true,
              controller: titleController,
              style: TextStyle(color: Colors.white, fontSize: 25),
              validator: getValidator(),
              decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                  errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.deepPurple), borderRadius: BorderRadius.circular(15.0))),
            )),

        //Third element
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            enabled: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0) ? false : true,
            controller: descriptionController,
            style: TextStyle(color: Colors.white, fontSize: 25),
            onChanged: (value) {
              debugPrint("Description has changed");
              updateDescription();
            },
            decoration: InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple), borderRadius: BorderRadius.circular(15.0))),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MicScreen(),
                      ));
                },
              ),
            ])),

        //Fifth element
        Padding(
          padding: EdgeInsets.only(top: 90),
          child: RaisedButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text(
                "Update Description",
                textScaleFactor: 1.5,
              ),
              onPressed: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0)
                  ? null
                  : () {
                      debugPrint("Update pressed");
                      descriptionController.text += ' ';
                      descriptionController.text += MicScreenState.a;
                      descriptionController.text += ' ';
                      updateDescription();
                      MicScreenState.resultText = "";
                    }),
        ),

        //Sixth element
        Padding(
            padding: EdgeInsets.only(top: 22.0, bottom: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        child: Text(
                          "Save",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0)
                            ? null
                            : () {
                                debugPrint("Saved pressed");
                                if (_formKey.currentState.validate()) {
                                  _save();
                                }
                              })),
                Container(
                  width: 5.0,
                ),
                Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        child: Text(
                          "Delete",
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (MicScreenState.resultText.length == 0 && descriptionController.text.length == 0)
                            ? null
                            : () {
                                debugPrint("Delete pressed");
                                _delete();
                              })),
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
    note.description = descriptionController.text;
  }

  void _save() async {
    updateTitle();
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

  FormFieldValidator<String> getValidator() {
    return (String value) {
      if (value.isEmpty) {
        return 'Please enter a Title';
      }
    };
  }
}

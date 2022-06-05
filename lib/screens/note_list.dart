import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:STTC_NOTEPAD/models/note.dart';
import 'package:STTC_NOTEPAD/utils/database_helper.dart';
import 'package:STTC_NOTEPAD/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'InstructionScreen.dart';

class NoteList extends StatefulWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => InsScreen("Go Back")));
            },
          ),
        ],
      ),
      body: getNoteListView(),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 0, 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.deepPurpleAccent,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.black),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToDetail(this.noteList[position], 'Edit Note');
              },
            ),
          );
        });
  }

  //Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.tealAccent;
        break;

      default:
        return Colors.tealAccent;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.star_border);
        break;
      case 2:
        return Icon(Icons.text_fields);
        break;

      default:
        return Icon(Icons.text_fields);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.noteList.sort(
                (a, b) => (b.time.compareTo(a.time)),
              );
          this.noteList.sort(
                (a, b) => (a.priority.compareTo(b.priority)),
              );
          this.count = noteList.length;
        });
      });
    });
  }
}

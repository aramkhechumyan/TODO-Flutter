import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_flutter/todo_item.dart';
import 'package:todo_flutter/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  createDB().then((db) => {runApp(Todo(db))});
}

class Todo extends StatelessWidget {
  final Database db;

  Todo(this.db);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TodoList(db));
  }
}

class TodoList extends StatefulWidget {
  final Database db;

  TodoList(this.db);

  @override
  TodoListState createState() => TodoListState(db);
}

class TodoListState extends State<TodoList> {
  final Database database;
  final List<String> todoList = <String>[];
  final List<String> textList = <String>[];
  final TextEditingController textFieldController = TextEditingController();
  TextEditingController textinput = TextEditingController();
  int titleIndex;
  List<dynamic> result;

  TodoListState(this.database) {
    getItems(database).then((todoListFromDB) => {print("object")});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: ListView.builder(
        itemBuilder: (BuildContext context, index) {
          titleIndex = index;
          return _buildTodoItem(index, context);
        },
        itemCount: todoList.length,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  void removeTodoItem(int indexItem) {
    setState(() {
      todoList.removeAt(indexItem);
      textList.removeAt(indexItem);
    });
  }

  void addTodoItem(String date, String text, BuildContext context) {
    addToDB(database, titleIndex, date, text);

    setState(() {
      if (date == textFieldController.text) {
        todoList.add(date);
        textList.add(text);

        textFieldController.clear();
        textinput.clear();
      } else if (date == result[0]) {
        todoList[titleIndex] = date;
        textList[titleIndex] = text;
        _buildTodoItem(titleIndex, context);
      }
    });
  }

  Widget _buildTodoItem(int index, BuildContext context) {
    return ListTile(
      title: Card(
          child: Padding(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            print('index$index');
            titleIndex = index;
            _awaitReturnValueFromTodoItem(context);
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${todoList[titleIndex]} ($titleIndex)",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_sharp),
              const SizedBox(height: 50),
            ],
          ),
        ),
      )),
    );
  }

  Future<Widget> _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext) {
          return AlertDialog(
            title: const Text('Create Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textFieldController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date" //label text of field
                      ),
                  readOnly: true,
                  onTap: () async {
                    DateTime pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement
                      setState(() {
                        print("Aram");
                        // if (textFieldController != null) {
                        textFieldController.text = formattedDate;
                        print(textFieldController
                            .text); //set output date to TextField value.
                        // }
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
                TextField(
                  controller: textinput,
                  decoration: const InputDecoration(hintText: 'Enter text'),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancle'),
                onPressed: () {
                  textFieldController.clear();
                  textinput.clear();
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  Navigator.of(context).pop();
                  print(textinput.text);
                  addTodoItem(
                      textFieldController.text, textinput.text, context);
                },
              )
            ],
          );
        });
  }

  void _awaitReturnValueFromTodoItem(BuildContext context) async {
    String dataToSend = todoList[titleIndex];
    String textToSend = textList[titleIndex];

    if (todoList[titleIndex] != null) {
      result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TodoItemState(
                text: textToSend, date: dataToSend, index: titleIndex),
          )) as List;
      if (result.length == 3) {
        print(result[0] + result[1]);
        addTodoItem(result[0], result[1], context);
        titleIndex = result[2];
      }
      if (result.length == 1) {
        removeTodoItem(result[0]);
      }
    } else if (todoList[titleIndex] == result[0]) {
      _sendDataTodoItem(context);
    }
  }

  void _sendDataTodoItem(BuildContext context) {
    String dataToSend = todoList[titleIndex];
    String textToSend = textList[titleIndex];
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TodoItemState(
            text: textToSend,
            date: dataToSend,
          ),
        ));
  }
}

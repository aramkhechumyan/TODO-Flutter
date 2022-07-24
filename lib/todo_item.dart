import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoItemState extends StatelessWidget {
  TextEditingController textFieldController = TextEditingController();
  TextEditingController textinput = TextEditingController();
  bool _state = false;
  final String date;
  final String text;
  final int index;

  TodoItemState({@required this.date, this.text, this.index});

  void _setState() {
    _state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('To-DO Item'), actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(right: 5.0),
            icon: Icon(
              Icons.edit,
              size: 30,
            ),
            onPressed: () {
              _setState();
              (context as Element).markNeedsBuild();
            },
          ),
          IconButton(
            padding: EdgeInsets.only(right: 15.0),
            icon: Icon(
              Icons.delete,
              size: 30,
            ),
            onPressed: () {
              _deleteData(context);
            },
          ),
        ]),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                enabled: _state,
                decoration: InputDecoration(icon: Icon(Icons.calendar_today)),
                controller: textFieldController..text = date,
                readOnly: true,
                onTap: () async {
                  DateTime pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    print(
                        formattedDate); //formatted date output using intl package =>  2021-03-16
                    //you can implement different kind of Date Format here according to your requirement

                    textFieldController.text =
                        formattedDate; //set output date to TextField value.
                  } else {
                    print("Date is not selected");
                  }
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: textinput..text = text,
                  decoration: InputDecoration(),
                  enabled: _state,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Visibility(
                  visible: _state,
                  child: ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      _sendDataBack(context);
                    },
                  ),
                )
              ]),
            ],
          ),
        ));
  }

  void _sendDataBack(BuildContext context) {
   List<dynamic> dataToSendBack = [
      textFieldController.text,
      textinput.text,
      index
    ];
   print(dataToSendBack);
    Navigator.pop(context,dataToSendBack);
  }

  void _deleteData(BuildContext context) {
    List<int> indexToSendBack = [index];
    Navigator.pop(context,indexToSendBack);
  }
}

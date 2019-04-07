import 'package:flutter/material.dart';
import '../model/database.dart';

class NewList extends StatefulWidget {
  @override
  _NewListState createState() => _NewListState();
}

class _NewListState extends State<NewList> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TodoProvider _db;

  _NewListState() {
    _db = TodoProvider();
  }

  @override
  void initState() {
    super.initState();
    _db.open().then((result) {});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController subjectController = TextEditingController();

    TextFormField todoTextField = TextFormField(
      controller: subjectController,
      decoration: InputDecoration(
        labelText: "Subject"
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please fill text';
        }
      },
    );
    
    RaisedButton submitButton = RaisedButton(
      child: const Text('Save'), color: Colors.teal[100],
      onPressed: () {
        if (_formKey.currentState.validate()) {
          Todo todo = Todo(subject: subjectController.text);
          _db.insert(todo).then((r) {
            Navigator.pushReplacementNamed(context, '/');
          });
        }
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New Subject'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              todoTextField,
              submitButton,
            ],
          ),
        ),
      ),
    );
  }
}

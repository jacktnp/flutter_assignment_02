import 'dart:async';
import 'package:sqflite/sqflite.dart';

final String tableTodo = "todo";
final String columnId = "_id";
final String columnTitle = "title";
final String columnDone = "done";

class Todo {
  int _id;
  String _subject;
  bool _done = false;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: _subject,
      columnDone: _done == true ? 1 : 0
    };
    if (_id != null) {
      map[columnId] = _id;
    }

    return map;
  }

  Todo({String subject}) {
    this._subject = subject;
  }

  set subject(String subject) => this._subject = subject;
  String get subject => this._subject;
  set id(int id) => this._id = id;
  int get id => this._id;
  set done(bool done) => this._done = done;
  bool get done => this._done;

  Todo.fromMap(Map<String, dynamic> map) {
    _id = map[columnId];
    _subject = map[columnTitle];
    _done = map[columnDone] == 1;
  }
}

class TodoProvider {
  Database db;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "\todo.db";

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableTodo (
            $columnId integer primary key autoincrement,
            $columnTitle text not null,
            $columnDone integer not null
          )
        ''');
      },
    );
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());

    return todo;
  }

  Future<List<Todo>> getTodos() async {
    var data = await db.query(tableTodo, where: '$columnDone = 0');
    return data.map((d) => Todo.fromMap(d)).toList();
  }

  Future<List<Todo>> getDones() async {
    var data = await db.query(tableTodo, where: '$columnDone = 1');
    return data.map((d) => Todo.fromMap(d)).toList();
  }

  Future<Todo> getTodo(int id) async {
    List<Map> maps = await db.query(
      tableTodo,
      columns: [columnId, columnTitle, columnDone],
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return new Todo.fromMap(maps.first);
    }

    return null;
  }

  Future<void> setTodoDone(Todo todo) async {
    await db.update(
      tableTodo,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      tableTodo,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteDone() async {
    await db.delete(
      tableTodo,
      where: '$columnDone = 1',
    );
  }

  Future close() async => db.close();
}

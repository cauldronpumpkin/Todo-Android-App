import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Todo {
  final int id;
  final String name;
  final String created_at;
  final int status;

  Todo({this.id, this.name, this.created_at, this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': created_at,
      'status': status,
    };
  }
}

class Database {
  var db;

  Future<void> init() async {

    final database = openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) async {
//        await db.execute("DROP TABLE Todo");
        return db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, created_at TEXT, status INT)",
        );
      },
      version: 1,
    );

    this.db = await database;
  }

  Future<void> addTodo(Todo todo) async {
    final temp = todo.toMap();
    await db.execute(
      "INSERT INTO todo(name, created_at, status) VALUES('${temp['name']}', '${temp['created_at']}', ${temp['status']})"
    );
  }

  Future<List> getTodo() async {

    final currDT = DateTime.now();
    final lowerT = DateTime(currDT.year, currDT.month, currDT.day).toString();
    final upperT = DateTime(currDT.year, currDT.month, currDT.day + 1).toString();
    final List<Map<String, dynamic>> maps = await db.query("todo WHERE created_at>='${lowerT}' AND created_at<'${upperT}'");

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        name: maps[i]['name'],
        created_at: maps[i]['created_at'],
        status: maps[i]['status'],
      ).toMap();
    });
  }

  Future<List> getTodoByTime(DateTime T) async {
    final lowerT = DateTime(T.year, T.month, T.day).toString();
    final upperT = DateTime(T.year, T.month, T.day + 1).toString();
    final List<Map<String, dynamic>> maps = await db.query("todo WHERE created_at>='${lowerT}' AND created_at<'${upperT}'");

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        name: maps[i]['name'],
        created_at: maps[i]['created_at'],
        status: maps[i]['status'],
      ).toMap();
    });
  }

  Future<void> updateTodo (todo) async {
    await db.execute("UPDATE todo SET status=${todo['status']} WHERE id=${todo['id']}");
  }

  Future<void> deleteTodo (todo) async {
    await db.execute("DELETE FROM todo WHERE id=${todo['id']}");
  }

  Future<void> deleteAll() async {
    db.execute("DELETE FROM todo");
  }
}

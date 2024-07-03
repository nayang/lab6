import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'todo.dart';
import 'todo_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Todo])
abstract class AppDatabase extends FloorDatabase {
  TodoDao get todoDao;
}

Future<AppDatabase> setupDatabase() async {
  final database = await $FloorAppDatabase
      .databaseBuilder('todo_database.db')
      .build();
  return database;
}

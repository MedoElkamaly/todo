import 'dart:async';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/src/exceptions/my_app_exception.dart';
import 'package:todo/src/resources/db/todo_contract.dart';
import 'package:todo/src/resources/models/todo_model.dart';

class TodoDb {
  final _logger = Logger();
  final _readyCompleter = Completer();

  Future get ready => _readyCompleter.future;
  late Database _database;

  TodoDb() {
    _init().then((_) {
      _readyCompleter.complete();
    });
  }

  /// Initialize the [Database] before using it
  Future _init() async {
    var documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, "t1.db");
    _database = await openDatabase(path, version: 13,
        onCreate: (Database newDb, int version) async {
      _createTables(newDb);
    }, onUpgrade: (Database newDb, int oldVersion, int newVersion) async {
      _dropTables(newDb);
      _createTables(newDb);
    });
  }

  /// Creates tables in the [Database]
  void _createTables(Database newDb) {
    newDb.execute("""
              CREATE TABLE ${TodoContract.tableName}
                (
                  ${TodoContract.columnId} INTEGER PRIMARY KEY,
                  ${TodoContract.columnUserId} INTEGER,
                  ${TodoContract.columnTitle} TEXT,
                  ${TodoContract.columnIsCompleted} INTEGER
                )
              """);
  }

  /// Drops all the tables in the [Database]
  void _dropTables(Database newDb) {
    newDb.execute('''
          DROP TABLE IF EXISTS ${TodoContract.tableName};
    ''');
  }

  /// Returns the number [int] of rows in [TodoContract.tableName] table
  ///
  /// Returns 0 if there is any [Exception]
  Future<int> getCount() async {
    try {
      await ready;
      var result = await _database
          .rawQuery('SELECT COUNT(*) as count FROM ${TodoContract.tableName}');
      return Sqflite.firstIntValue(result) ?? 0;
    } on Exception catch (e) {
      _logger.e(e.toString());
      return 0;
    }
  }

  /// Retrieves page [page] form [Database] as a [List] of [TodoModel],
  /// limiting the length to [limit]
  ///
  /// Throws [Exception] if there is a problem retrieving the data
  Future<List<TodoModel>> getTodos({
    int limit = 50,
    int page = 1,
  }) async {
    try {
      await ready;
      var result = await _database.query(
        TodoContract.tableName,
        limit: limit,
        offset: (page - 1) * limit,
      );

      return result.map((e) => TodoModel.fromMap(e)).toList();
    } on Exception catch (e) {
      _logger.e(e.toString());
      throw MyAppException(message: e.toString());
    }
  }

  /// Retrieves last rows form [Database] in [DESC] order,
  /// returns a [List] of [TodoModel],
  /// limiting the length to [limit] the default [limit] is 1
  ///
  /// Empty [List] of [TodoModel] if there is a problem retrieving the data
  Future<List<TodoModel>> getLastTodo({int limit = 1}) async {
    try {
      await ready;
      var result = await _database.query(TodoContract.tableName,
          orderBy: "${TodoContract.columnId} DESC", limit: limit);
      return result.map((e) => TodoModel.fromMap(e)).toList();
    } on Exception catch (e) {
      _logger.e(e.toString());
      return <TodoModel>[];
      //rethrow;
    }
  }

  /// Inserts a [List] of [TodoModel] if not exists to [Database] and update the duplicates
  ///
  /// Throws [Exception] if there is a problem inserting the data
  Future<void> insertTodos(List<TodoModel> todos) async {
    try {
      await ready;
      Batch batch = _database.batch();
      for (TodoModel model in todos) {
        batch.rawInsert("""
            INSERT OR REPLACE INTO 
            ${TodoContract.tableName}(${TodoContract.columnId},${TodoContract.columnUserId},${TodoContract.columnTitle},${TodoContract.columnIsCompleted})
            VALUES(${model.id},${model.userId},'${model.title}',${model.isCompleted ? 1 : 0})            
            """);
      }
      batch.commit();
    } on Exception catch (e) {
      _logger.e(e.toString());
      throw MyAppException(message: e.toString());
    }
  }

  /// Updates a [TodoModel] in the [Database]
  ///
  /// Throws [Exception] if there is a problem updating the record
  Future<void> updateTodo(TodoModel model) async {
    try {
      await ready;
      var count = await _database.update(
        TodoContract.tableName,
        model.toMap(toDb: true),
        where: '${TodoContract.columnId} = ?',
        whereArgs: [model.id],
      );
      if (count == 0) {
        await _database.insert(
          TodoContract.tableName,
          model.toMap(toDb: true),
        );
      }
    } on Exception catch (e) {
      _logger.e(e.toString());
      throw MyAppException(message: e.toString());
    }
  }

  /// Inserts a [TodoModel] to [Database] if not exists, or updates it if exists
  ///
  /// Throws [Exception] if there is a problem inserting the data
  Future<void> insertTodo(TodoModel model) async {
    try {
      await ready;
      await _database.rawInsert("""
            INSERT OR REPLACE INTO 
            ${TodoContract.tableName}(${TodoContract.columnId},${TodoContract.columnUserId},${TodoContract.columnTitle},${TodoContract.columnIsCompleted})
            VALUES(${model.id},${model.userId},'${model.title}',${model.isCompleted ? 1 : 0})            
            """);
    } on Exception catch (e) {
      _logger.e(e.toString());
      throw MyAppException(message: e.toString());
    }
  }

  /// Deletes all the data in Todos table
  ///
  /// Throws [Exception] if there is a problem deleting the data
  Future<void> deleteAllTodos() async {
    try {
      await ready;
      await _database.delete(TodoContract.tableName);
    } on Exception catch (e) {
      _logger.e(e.toString());
      throw MyAppException(message: e.toString());
    }
  }
}

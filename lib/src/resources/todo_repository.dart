import 'package:todo/src/resources/api/todo_api.dart';
import 'package:todo/src/resources/db/todo_db.dart';
import 'package:todo/src/resources/models/todo_model.dart';

class TodoRepository {
  /// Number of rows per page
  final int _limit = 30;
  final _api = TodoApi();
  final _db = TodoDb();

  /// Returns a [List] of [TodoModel] from cache or the API
  ///
  /// Checks the number of rows in cache, if all the requested [page] falls in cache
  /// it will retrieves the data from cache, else it will retrieve the remaining
  /// data from cache and fills the rest of the [page] from API
  ///
  /// Throws [Exception] if there is any error from cache or API
  Future<(List<TodoModel>, bool)> getTodos(int page) async {
    var count = await _db.getCount();
    if (count >= page * _limit) {
      var list = await _db.getTodos(limit: _limit, page: page);
      return (list, false);
    } else {
      int subPageCount = ((page * _limit) - count);

      var lastTodo = await _db.getLastTodo();
      var lastDbList =
          await _db.getLastTodo(limit: count - ((page - 1) * _limit));

      var list = await _api.getTodos(
        limit: subPageCount,
        start: lastTodo.isEmpty
            ? 0
            : lastTodo.last.id == 201
                ? count
                : lastTodo.last.id,
      );
      if (list.isNotEmpty) await _db.insertTodos(list);
      return (
        List<TodoModel>.of(lastDbList.reversed)..addAll(list),
        list.isEmpty || list.length < subPageCount
      );
    }
  }

  /// Clears all the data in cache and retrieve the first page from API and store
  /// it to the cache
  ///
  /// Throws [Exception] if there is any error from cache or API
  Future<(List<TodoModel>, bool)> refreshTodos() async {
    await _db.deleteAllTodos();
    return await getTodos(1);
  }

  /// Updates a [TodoModel] in the API, if successfully  updated it will update
  /// it also in the cache and returns the updated [TodoModel]
  ///
  /// Throws [Exception] if there is any error from cache or API
  Future<TodoModel> updateTodo(TodoModel model) async {
    var updatedModel = await _api.updateTodo(model);
    await _db.updateTodo(updatedModel);
    return updatedModel;
  }

  /// Inserts a new [TodoModel] in the API, if successfully  inserted it will insert
  /// it also in the cache and returns the new [TodoModel]
  ///
  /// Throws [Exception] if there is any error from cache or API
  Future<TodoModel> insertTodo(TodoModel model) async {
    var updatedModel = await _api.insertTodo(model);
    await _db.insertTodo(updatedModel);
    return updatedModel;
  }
}

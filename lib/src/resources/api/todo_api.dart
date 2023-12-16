import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:todo/src/exceptions/my_app_exception.dart';
import 'package:todo/src/resources/models/todo_model.dart';

class TodoApi {
  final _logger = Logger();
  late final Dio _dio;

  TodoApi() {
    var baseOptions = BaseOptions(connectTimeout: const Duration(seconds: 60));
    _dio = Dio(baseOptions);
  }

  /// Retrieves a [List] of [TodoModel] from API,
  /// limiting the length to [limit] starting from item no [start]
  ///
  /// Throws [Exception] if the the server responded with a status code
  /// that falls out of the range of 2xx and is also not 304.
  Future<List<TodoModel>> getTodos({int limit = 50, int start = 1}) async {
    try {
      var response = await _dio
          .get('https://jsonplaceholder.typicode.com/todos', queryParameters: {
        '_start': start,
        '_limit': limit,
      });

      var data = response.data as List;
      return data.map((e) => TodoModel.fromMap(e)).toList();
    } on DioException catch (e) {
      _logger.e(e.message, stackTrace: e.stackTrace);
      throw MyAppException(message: e.message);
    }
  }

  /// Updates a [TodoModel] in the API,
  /// if successfully updated it will return the updated [TodoModel]
  ///
  /// Throws [Exception] if the the server responded with a status code
  /// that falls out of the range of 2xx and is also not 304.
  Future<TodoModel> updateTodo(TodoModel model) async {
    try {
      var response = await _dio.put(
          'https://jsonplaceholder.typicode.com/todos/${model.id}',
          data: model.toMap());
      return TodoModel.fromMap(response.data);
    } on DioException catch (e) {
      _logger.e(e.message, stackTrace: e.stackTrace);
      throw MyAppException(message: e.message);
    }
  }

  /// Adds a [TodoModel] to the API,
  /// if successfully added it will return the added [TodoModel]
  ///
  /// Throws [Exception] if the the server responded with a status code
  /// that falls out of the range of 2xx and is also not 304.
  Future<TodoModel> insertTodo(TodoModel model) async {
    try {
      var response = await _dio.post(
          'https://jsonplaceholder.typicode.com/todos',
          data: model.toMap());
      return TodoModel.fromMap(response.data);
    } on DioException catch (e) {
      _logger.e(e.message, stackTrace: e.stackTrace);
      throw MyAppException(message: e.message);
    }
  }
}

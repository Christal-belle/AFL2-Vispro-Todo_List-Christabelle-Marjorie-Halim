import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'task_datasource.dart';

class LocalTaskDataSource implements TaskDataSource {
  final SharedPreferences sharedPreferences;
  static const String _tasksKey = 'cached_tasks';

  LocalTaskDataSource({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final jsonString = sharedPreferences.getString(_tasksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => TaskModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await sharedPreferences.setString(_tasksKey, json.encode(jsonList));
  }
}
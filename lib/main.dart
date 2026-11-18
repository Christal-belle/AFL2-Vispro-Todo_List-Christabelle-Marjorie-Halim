import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/task_viewmodel.dart';
import 'presentation/views/task_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceLocator.init();

  runApp(const TodoListApp());
}

class TodoListApp extends StatefulWidget {
  const TodoListApp({super.key});

  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  late final TaskViewModel _taskViewModel;

  @override
  void initState() {
    super.initState();
    _taskViewModel = ServiceLocator.createTaskViewModel()..loadTasks();
  }

  @override
  void dispose() {
    _taskViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: TaskListView(viewModel: _taskViewModel),
    );
  }
}
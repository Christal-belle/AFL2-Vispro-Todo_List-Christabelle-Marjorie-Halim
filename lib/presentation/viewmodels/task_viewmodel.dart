import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../states/task_state.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository repository;

  TaskState _state = const TaskLoading();
  TaskState get state => _state;

  List<Task> _allTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isDisposed = false;

  TaskViewModel({required this.repository});

  Future<void> loadTasks() async {
    _emit(const TaskLoading());
    try {
      final loadedTasks = await repository.getTasks();
      if (_isDisposed) return; 
      _allTasks = List<Task>.from(loadedTasks);
      _emitCurrentFilteredState();
    } catch (_) {
      if (_isDisposed) return;
      _emit(const TaskError('Gagal memuat daftar tugas. Silakan coba lagi.'));
    }
  }

  Future<void> addTask(String title, {DateTime? dueDate}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      _emit(const TaskError('Judul tugas tidak boleh kosong.'));
      return;
    }

    try {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: trimmed,
        dueDate: dueDate,
      );
      await repository.addTask(newTask);
      if (_isDisposed) return;

      _allTasks.add(newTask);
      _emitCurrentFilteredState();
    } catch (_) {
      if (_isDisposed) return;
      _emit(const TaskError('Maaf, gagal menyimpan tugas baru.'));
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    try {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updated);
      if (_isDisposed) return;

      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = updated;
        _emitCurrentFilteredState();
      }
    } catch (_) {
      if (_isDisposed) return;
      _emit(const TaskError('Gagal memperbarui status tugas.'));
    }
  }

  // --- Fungsi Hapus Langsung (Tanpa Undo) ---
  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);
      if (_isDisposed) return;

      _allTasks.removeWhere((t) => t.id == id);
      _emitCurrentFilteredState();
    } catch (_) {
      if (_isDisposed) return;
      _emit(const TaskError('Gagal menghapus tugas.'));
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    _emitCurrentFilteredState();
  }

  void _emitCurrentFilteredState() {
    final visibleTasks = _allTasks.where((t) {
      return switch (_currentFilter) {
        TaskFilter.all => true,
        TaskFilter.active => !t.isCompleted,
        TaskFilter.completed => t.isCompleted,
      };
    }).toList();

    if (visibleTasks.isEmpty) {
      _emit(TaskEmpty(activeFilter: _currentFilter));
    } else {
      _emit(TaskLoaded(
        tasks: visibleTasks,
        activeFilter: _currentFilter,
      ));
    }
  }

  void _emit(TaskState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
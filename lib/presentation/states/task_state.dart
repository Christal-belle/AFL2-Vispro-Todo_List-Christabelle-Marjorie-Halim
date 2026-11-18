import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

enum TaskFilter { all, active, completed }

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

final class TaskLoading extends TaskState {
  const TaskLoading();
}

final class TaskEmpty extends TaskState {
  final TaskFilter activeFilter;

  const TaskEmpty({this.activeFilter = TaskFilter.all});

  @override
  List<Object?> get props => [activeFilter];
}

final class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter activeFilter;

  const TaskLoaded({
    required this.tasks,
    this.activeFilter = TaskFilter.all,
  });

  @override
  List<Object?> get props => [tasks, activeFilter];
}

final class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
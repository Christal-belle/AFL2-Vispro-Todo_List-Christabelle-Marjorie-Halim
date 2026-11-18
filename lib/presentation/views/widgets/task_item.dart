import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: task.dueDate != null
            ? Text(
                'Due Date: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                style: TextStyle(
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          tooltip: 'Delete Task',
          onPressed: task.isCompleted ? onDelete : null,
        ),
      ),
    );
  }
}
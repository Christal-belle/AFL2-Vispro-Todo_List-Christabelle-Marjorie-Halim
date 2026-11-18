import 'package:flutter/material.dart';
import '../states/task_state.dart';
import '../viewmodels/task_viewmodel.dart';
import 'widgets/task_item.dart';

class TaskListView extends StatefulWidget {
  final TaskViewModel viewModel;

  const TaskListView({
    super.key,
    required this.viewModel,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _submitNewTask() async {
    final text = _textController.text;
    if (text.trim().isEmpty) {
      widget.viewModel.addTask(''); 
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      cancelText: ' No Due Date',
    );

    widget.viewModel.addTask(text, dueDate: selectedDate);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List!!'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add your next task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _submitNewTask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _submitNewTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final state = widget.viewModel.state;

                return Column(
                  children: [
                    if (state is TaskLoaded || state is TaskEmpty)
                      _buildFilterChips(
                        state is TaskLoaded
                            ? state.activeFilter
                            : (state as TaskEmpty).activeFilter,
                      ),
                    Expanded(
                      child: switch (state) {
                        TaskLoading() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        TaskEmpty(:final activeFilter) => _buildEmptyState(activeFilter),
                        TaskLoaded(:final tasks) => ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskItem(
                                task: task,
                                onToggle: () =>
                                    widget.viewModel.toggleTaskStatus(task),
                                onDelete: () =>
                                    widget.viewModel.deleteTask(task.id), // <-- Panggil fungsi baru
                              );
                            },
                          ),
                        TaskError(:final message) => _buildErrorState(message),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TaskFilter currentFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: currentFilter == TaskFilter.all,
            onSelected: (_) => widget.viewModel.setFilter(TaskFilter.all),
            showCheckmark: false,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Active'),
            selected: currentFilter == TaskFilter.active,
            onSelected: (_) => widget.viewModel.setFilter(TaskFilter.active),
            showCheckmark: false,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Finished'),
            selected: currentFilter == TaskFilter.completed,
            onSelected: (_) => widget.viewModel.setFilter(TaskFilter.completed),
            showCheckmark: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    final text = switch (filter) {
      TaskFilter.all => 'Yayy!! \n All Done!',
      TaskFilter.active => 'No Active Task',
      TaskFilter.completed => 'No Task Finished',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => widget.viewModel.loadTasks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
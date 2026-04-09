import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final TaskService taskService;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.taskService,
    required this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isExpanded = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _addSubtask() async {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;

    await widget.taskService.addSubtask(widget.task, text);
    _subtaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => widget.taskService.toggleTask(task),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                'Subtasks: ${task.subtasks.length}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: 'Add subtask...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSubtask,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (task.subtasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No subtasks yet.'),
                  ),
                )
              else
                Column(
                  children: List.generate(task.subtasks.length, (index) {
                    final subtask = task.subtasks[index];
                    final title = subtask['title'] ?? '';
                    final isDone = subtask['isDone'] ?? false;

                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 8, right: 0),
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (_) =>
                            widget.taskService.toggleSubtask(task, index),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            widget.taskService.deleteSubtask(task, index),
                      ),
                    );
                  }),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
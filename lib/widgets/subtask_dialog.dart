import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class SubtaskDialog extends StatefulWidget {
  final Todo todo;

  const SubtaskDialog({super.key, required this.todo});

  @override
  State<SubtaskDialog> createState() => _SubtaskDialogState();
}

class _SubtaskDialogState extends State<SubtaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        widget.todo.addSubtask(_controller.text.trim());
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Subtasks for "${widget.todo.title}"'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add subtask field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress indicator
            if (widget.todo.hasSubtasks) ...[
              LinearProgressIndicator(
                value: widget.todo.subtaskProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.todo.subtaskProgress == 1.0 ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.todo.completedSubtasks}/${widget.todo.totalSubtasks} completed',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Subtasks list
            if (widget.todo.hasSubtasks)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.todo.subtasks.length,
                  itemBuilder: (context, index) {
                    final subtask = widget.todo.subtasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: subtask.isDone,
                        onChanged: (value) {
                          setState(() {
                            widget.todo.toggleSubtask(index);
                          });
                        },
                      ),
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.todo.removeSubtask(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No subtasks yet. Add one above!'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
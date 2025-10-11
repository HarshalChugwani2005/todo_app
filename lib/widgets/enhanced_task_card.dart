import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../theme/app_theme.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const EnhancedTaskCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.softWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getPriorityColor(todo.priority).withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Checkbox
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getPriorityColor(todo.priority),
                        width: 2,
                      ),
                      color: todo.isDone ? _getPriorityColor(todo.priority) : Colors.transparent,
                    ),
                    child: InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          todo.isDone ? Icons.check : null,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isDone ? TextDecoration.lineThrough : null,
                        color: todo.isDone ? Colors.grey : null,
                      ),
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Priority Tag
                  _buildTag(
                    '${todo.priorityText} Priority',
                    todo.priorityColor,
                    Icons.flag,
                  ),
                  
                  // Category Tag
                  _buildTag(
                    todo.category,
                    AppColors.sageGreen,
                    Icons.folder,
                  ),
                  
                  // Recurring Tag
                  if (todo.isRecurring)
                    _buildTag(
                      todo.recurrenceText,
                      AppColors.lightPink,
                      Icons.repeat,
                    ),
                  
                  // Due Date Tag
                  if (todo.dueDate != null)
                    _buildTag(
                      _formatDueDate(todo.dueDate!),
                      _getDueDateColor(todo.dueDate!),
                      Icons.schedule,
                    ),
                ],
              ),
              
              // Subtasks Preview
              if (todo.subtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${todo.subtasks.where((s) => s.isDone).length}/${todo.subtasks.length} subtasks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference < 0) return 'Overdue';
    
    return '${difference}d left';
  }

  Color _getDueDateColor(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) return Colors.red;
    if (difference == 0) return Colors.orange;
    if (difference <= 2) return Colors.yellow.shade700;
    
    return Colors.green;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0: // High priority
        return AppColors.coralPink;
      case 1: // Medium priority
        return AppColors.sageGreen;
      case 2: // Low priority
        return AppColors.lightPink;
      default:
        return AppColors.sageGreen;
    }
  }
}
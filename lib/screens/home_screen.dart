import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../services/data_service.dart';
import '../services/recurring_task_service.dart';
import '../theme/theme_provider.dart';
import '../utils/database_helper.dart';
import '../widgets/enhanced_task_card.dart';
import 'statistics_screen.dart';
import 'pomodoro_screen.dart';
import 'calendar_screen.dart';
import 'collaboration_screen.dart';
import 'cloud_sync_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box<Todo> get todoBox => DatabaseHelper.getTodoBox();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  String selectedPriorityFilter = 'All';
  String selectedSort = 'None';
  DateTime? selectedDate;
  int selectedPriority = 1; // Medium priority by default
  int selectedRecurrence = 0; // No recurrence by default
  bool isRecurringTask = false;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'statistics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        );
        break;
      case 'calendar':
        final selectedDateFromCalendar = await Navigator.push<DateTime>(
          context,
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        );
        if (selectedDateFromCalendar != null) {
          // Set the selected date and open add task dialog
          selectedDate = selectedDateFromCalendar;
          _addOrEditTodoDialog();
        }
        break;
      case 'pomodoro':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PomodoroScreen()),
        );
        break;
      case 'collaboration':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CollaborationScreen()),
        );
        break;
      case 'cloud_sync':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CloudSyncScreen()),
        );
        break;
      case 'export':
        await _exportData();
        break;
      case 'import':
        await _importData();
        break;
    }
  }

  Future<void> _exportData() async {
    try {
      final filePath = await DataService().exportData();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will replace all current tasks with data from the backup file. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await DataService().importData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                  ? 'Data imported successfully!' 
                  : 'Failed to import data'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
        if (success) {
          setState(() {}); // Refresh the UI
          // Reschedule notifications for imported tasks
          await RecurringTaskService().scheduleAllNotifications();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ---------------------- ADD TASK DIALOG ------------------------
  void _addOrEditTodoDialog({Todo? existingTodo}) {
    bool isEdit = existingTodo != null;
    _controller.text = existingTodo?.title ?? '';
    selectedCategory = existingTodo?.category ?? 'Personal';
    selectedDate = existingTodo?.dueDate;
    selectedPriority = existingTodo?.priority ?? 1;
    selectedRecurrence = existingTodo?.recurrenceType ?? 0;
    isRecurringTask = existingTodo?.isRecurring ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? "Edit Task" : "Add Task"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "Task Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'Work', child: Text('Work')),
                        DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                        DropdownMenuItem(value: 'Study', child: Text('Study')),
                        DropdownMenuItem(value: 'Others', child: Text('Others')),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedCategory = value!);
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: selectedPriority,
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.priority_high, color: Colors.red),
                              SizedBox(width: 8),
                              Text('High Priority'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.remove, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Medium Priority'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.low_priority, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Low Priority'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedPriority = value!);
                      },
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 10),
                    // Recurring task toggle
                    SwitchListTile(
                      title: const Text('Recurring Task'),
                      value: isRecurringTask,
                      onChanged: (value) {
                        setDialogState(() {
                          isRecurringTask = value;
                          if (!value) {
                            selectedRecurrence = 0;
                          } else if (selectedRecurrence == 0) {
                            selectedRecurrence = 1; // Default to daily when enabling recurrence
                          }
                        });
                      },
                    ),
                    if (isRecurringTask) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        initialValue: selectedRecurrence == 0 ? 1 : selectedRecurrence,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Daily')),
                          DropdownMenuItem(value: 2, child: Text('Weekly')),
                          DropdownMenuItem(value: 3, child: Text('Monthly')),
                        ],
                        onChanged: (value) {
                          setDialogState(() => selectedRecurrence = value ?? 1);
                        },
                        decoration: const InputDecoration(labelText: 'Repeat'),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(selectedDate == null
                              ? "No date chosen"
                              : "Due: ${DateFormat('MMM dd, yyyy - HH:mm').format(selectedDate!)}"),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && context.mounted) {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedDate != null 
                                    ? TimeOfDay.fromDateTime(selectedDate!)
                                    : TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                final combinedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                setDialogState(() => selectedDate = combinedDateTime);
                              } else {
                                setDialogState(() => selectedDate = pickedDate);
                              }
                            }
                          },
                          child: const Text("Pick Date"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    selectedDate = null;
                    selectedPriority = 1;
                    selectedRecurrence = 0;
                    isRecurringTask = false;
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_controller.text.isNotEmpty) {
                      if (isEdit) {
                        existingTodo.title = _controller.text;
                        existingTodo.category = selectedCategory;
                        existingTodo.dueDate = selectedDate;
                        existingTodo.priority = selectedPriority;
                        existingTodo.recurrenceType = isRecurringTask ? selectedRecurrence : 0;
                        existingTodo.isRecurring = isRecurringTask;
                        existingTodo.save();
                        
                        // Reschedule notification with updated details
                        await RecurringTaskService().rescheduleTaskNotification(existingTodo);
                      } else {
                        final todo = Todo(
                          title: _controller.text,
                          category: selectedCategory,
                          dueDate: selectedDate,
                          priority: selectedPriority,
                          recurrenceType: isRecurringTask ? selectedRecurrence : 0,
                          isRecurring: isRecurringTask,
                        );
                        await todoBox.add(todo);
                        
                        // Schedule notification if the task has a due date
                        if (selectedDate != null) {
                          await RecurringTaskService().rescheduleTaskNotification(todo);
                        }
                      }
                      _controller.clear();
                      selectedDate = null;
                      selectedPriority = 1;
                      selectedRecurrence = 0;
                      isRecurringTask = false;
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(isEdit ? "Save Changes" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------- BUILD UI ------------------------
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 My Tasks'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
            ],
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // SEARCH BAR
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search your tasks...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // FILTER CHIPS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip('All', selectedCategory == 'All', () => setState(() => selectedCategory = 'All'))),
                    Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip('Work', selectedCategory == 'Work', () => setState(() => selectedCategory = 'Work'))),
                    Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip('Personal', selectedCategory == 'Personal', () => setState(() => selectedCategory = 'Personal'))),
                    Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip('Study', selectedCategory == 'Study', () => setState(() => selectedCategory = 'Study'))),
                    Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip('Others', selectedCategory == 'Others', () => setState(() => selectedCategory = 'Others'))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: todoBox.listenable(),
                builder: (context, Box<Todo> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text("No tasks yet — add some!"));
                  }

                  final todos = box.values.toList();

                  // Apply category and search filters
                  final filtered = todos.where((todo) {
                    final matchesCategory = selectedCategory == 'All' ||
                        todo.category == selectedCategory;
                    final matchesSearch = todo.title.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        );
                    return matchesCategory && matchesSearch;
                  }).toList();

                  // Sort by priority and due date by default
                  filtered.sort((a, b) {
                    // First sort by completion status (incomplete tasks first)
                    if (a.isDone != b.isDone) {
                      return a.isDone ? 1 : -1;
                    }
                    // Then by priority (high priority first)
                    final priorityComparison = a.priority.compareTo(b.priority);
                    if (priorityComparison != 0) return priorityComparison;
                    
                    // Finally by due date
                    if (a.dueDate == null && b.dueDate == null) return 0;
                    if (a.dueDate == null) return 1;
                    if (b.dueDate == null) return -1;
                    return a.dueDate!.compareTo(b.dueDate!);
                  });

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No matching tasks."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final todo = filtered[index];
                      return EnhancedTaskCard(
                        todo: todo,
                        onToggle: () async {
                          todo.isDone = !todo.isDone;
                          todo.save();
                          
                          // Handle notifications
                          if (todo.isDone) {
                            await RecurringTaskService().cancelTaskNotification(todo);
                          } else {
                            await RecurringTaskService().rescheduleTaskNotification(todo);
                          }
                        },
                        onDelete: () async {
                          await RecurringTaskService().cancelTaskNotification(todo);
                          todo.delete();
                        },
                        onTap: () => _addOrEditTodoDialog(existingTodo: todo),
                        onEdit: () => _addOrEditTodoDialog(existingTodo: todo),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTodoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

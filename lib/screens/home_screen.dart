import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../theme/theme_provider.dart';
import '../widgets/todo_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<Todo> todoBox = Hive.box<Todo>('todos');
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  DateTime? selectedDate;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------- ADD TASK DIALOG ------------------------
  void _addOrEditTodoDialog({Todo? existingTodo}) {
    bool isEdit = existingTodo != null;
    _controller.text = existingTodo?.title ?? '';
    selectedCategory = existingTodo?.category ?? 'Personal';
    selectedDate = existingTodo?.dueDate;

    showDialog(
      context: context,
      builder: (context) {
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
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                    DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                    DropdownMenuItem(value: 'Study', child: Text('Study')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedDate == null
                        ? "No date chosen"
                        : "Due: ${DateFormat.yMMMd().format(selectedDate!)}"),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
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
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  if (isEdit) {
                    existingTodo!.title = _controller.text;
                    existingTodo.category = selectedCategory;
                    existingTodo.dueDate = selectedDate;
                    existingTodo.save();
                  } else {
                    final todo = Todo(
                      title: _controller.text,
                      category: selectedCategory,
                      dueDate: selectedDate,
                    );
                    todoBox.add(todo);
                  }
                  _controller.clear();
                  selectedDate = null;
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? "Save Changes" : "Add"),
            ),
          ],
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
        title: const Text('📝 To-Do List'),
        centerTitle: true,
        actions: [
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
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // CATEGORY FILTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter by category:"),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                    DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                    DropdownMenuItem(value: 'Study', child: Text('Study')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
              ],
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

                  // Apply category + search filters
                  final filtered = todos.where((todo) {
                    final matchesCategory = selectedCategory == 'All' ||
                        todo.category == selectedCategory;
                    final matchesSearch = todo.title.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        );
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No matching tasks."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final todo = filtered[index];
                      return TodoTile(
                        todo: todo,
                        onToggle: () {
                          todo.isDone = !todo.isDone;
                          todo.save();
                        },
                        onDelete: () => todo.delete(),
                        onTap: () => _addOrEditTodoDialog(existingTodo: todo),
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
}

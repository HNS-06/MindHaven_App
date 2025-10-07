import 'package:flutter/material.dart';
import 'package:mindhaven/services/firebase_service.dart';
import 'package:mindhaven/services/reward_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  final List<Map<String, dynamic>> _defaultTasks = [
    {
      'task': 'Practice 5 minutes of meditation',
      'points': 15,
      'icon': Icons.self_improvement,
    },
    {
      'task': 'Write 3 things you\'re grateful for',
      'points': 10,
      'icon': Icons.emoji_emotions,
    },
    {
      'task': 'Drink 8 glasses of water',
      'points': 10,
      'icon': Icons.local_drink,
    },
    {
      'task': 'Take a 10-minute walk outside',
      'points': 15,
      'icon': Icons.directions_walk,
    },
    {
      'task': 'Read for 15 minutes',
      'points': 15,
      'icon': Icons.menu_book,
    },
  ];

  void _addTask() {
    final task = _taskController.text.trim();
    if (task.isEmpty) return;

    FirebaseService.saveTask(task, false).then((_) {
      setState(() {}); // Refresh the UI
    });
    _taskController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added!')),
    );
  }

  void _toggleTask(Map<String, dynamic> task, bool completed) async {
    await FirebaseService.updateTaskCompletion(task['id'], completed);
    if (completed) {
      await RewardService.addPoints(10);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task completed! +10 points'),
          backgroundColor: Colors.green,
        ),
      );
    }
    setState(() {}); // Refresh the UI
  }

  Future<bool?> _showDeleteDialog(Map<String, dynamic> task) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task['task']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTaskDeletion(Map<String, dynamic> task) async {
    try {
      await FirebaseService.deleteTask(task['id']);
      
      if (!mounted) return;
      setState(() {}); // Refresh the UI
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task['task']}" deleted'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              await FirebaseService.saveTask(task['task'], task['isCompleted'] ?? false);
              if (!mounted) return;
              setState(() {}); // Refresh the UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deletion undone!')),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addDefaultTask(Map<String, dynamic> taskData) {
    FirebaseService.saveTask(taskData['task'], false).then((_) {
      setState(() {}); // Refresh the UI
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
      ),
      body: Column(
        children: [
          // Add Task
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: 'Add a custom task...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addTask,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Add Tasks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _defaultTasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _addDefaultTask(task),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(task['icon'], color: Colors.purple),
                              const SizedBox(height: 8),
                              Text(
                                task['task'],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+${task['points']} pts',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Task List - UPDATED: Using ListView.builder instead of StreamBuilder
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: FirebaseService.tasks.length,
              itemBuilder: (context, index) {
                final task = FirebaseService.tasks[index];
                return Dismissible(
                  key: Key(task['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    final shouldDelete = await _showDeleteDialog(task);
                    if (shouldDelete == true) {
                      await _handleTaskDeletion(task);
                      return true;
                    }
                    return false;
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Checkbox(
                        value: task['isCompleted'] ?? false,
                        onChanged: (value) => _toggleTask(task, value!),
                      ),
                      title: Text(
                        task['task'],
                        style: TextStyle(
                          decoration: (task['isCompleted'] ?? false)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: (task['isCompleted'] ?? false)
                              ? Colors.grey
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () async {
                          final shouldDelete = await _showDeleteDialog(task);
                          if (shouldDelete == true) {
                            await _handleTaskDeletion(task);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
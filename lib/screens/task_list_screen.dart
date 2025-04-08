import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/subtask_list.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  String? _selectedDay;
  String? _selectedTimeRange;
  Task? _selectedTask;
  bool _isAddingSubtask = false;

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> timeRanges = ['9am-10am', '10am-11am', '11am-12pm', '12pm-1pm', '1pm-2pm', '2pm-3pm', '3pm-4pm', '4pm-5pm'];

  @override
  void dispose() {
    _taskNameController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_taskNameController.text.isNotEmpty) {
      final newTask = Task(
        id: const Uuid().v4(),
        name: _taskNameController.text.trim(),
        subtasks: {},
      );
      
      await FirebaseService.addTask(newTask);
      _taskNameController.clear();
    }
  }

  Future<void> _addSubtask() async {
    if (_selectedTask != null && 
        _subtaskController.text.isNotEmpty && 
        _selectedDay != null && 
        _selectedTimeRange != null) {
      final key = '$_selectedDay: $_selectedTimeRange';
      
      if (_selectedTask!.subtasks[key] == null) {
        _selectedTask!.subtasks[key] = [];
      }
      
      _selectedTask!.subtasks[key]!.add(_subtaskController.text.trim());
      
      await FirebaseService.updateTask(_selectedTask!);
      
      setState(() {
        _subtaskController.clear();
        _isAddingSubtask = false;
        _selectedTask = null;
        _selectedDay = null;
        _selectedTimeRange = null;
      });
    }
  }

  void _signOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          
          if (_isAddingSubtask) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _subtaskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a subtask',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Day'),
                          value: _selectedDay,
                          items: days.map((String day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDay = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Time Range'),
                          value: _selectedTimeRange,
                          items: timeRanges.map((String timeRange) {
                            return DropdownMenuItem<String>(
                              value: timeRange,
                              child: Text(timeRange),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTimeRange = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isAddingSubtask = false;
                            _selectedTask = null;
                            _subtaskController.clear();
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addSubtask,
                        child: const Text('Add Subtask'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: FirebaseService.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final tasks = snapshot.data ?? [];
                
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one!'));
                }
                
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                FirebaseService.toggleTaskCompletion(task);
                              },
                            ),
                            Expanded(
                              child: Text(
                                task.name,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                FirebaseService.deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                        children: [
                          SubtaskList(task: task),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Subtask'),
                              onPressed: () {
                                setState(() {
                                  _isAddingSubtask = true;
                                  _selectedTask = task;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
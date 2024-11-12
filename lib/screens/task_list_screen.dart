import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskService = TaskService();
  final _titleController = TextEditingController();
  final _timeSlotController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      _taskService.addTask(
                        Task(
                          id: DateTime.now().toString(),
                          title: _titleController.text,
                          dateTime: DateTime.now(),
                          userId: authService.currentUser!.uid,
                        ),
                      );
                      _titleController.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.getTasks(authService.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ExpansionTile(
                      title: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              _taskService.updateTask(
                                task.id,
                                {'isCompleted': value},
                              );
                            },
                          ),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _taskService.deleteTask(task.id),
                          ),
                        ],
                      ),
                      children: [
                        ...task.subTasks.map((subTask) => ListTile(
                              leading: Checkbox(
                                value: subTask.isCompleted,
                                onChanged: (value) {
                                  _taskService.updateSubTask(
                                    task.id,
                                    subTask.id,
                                    {'isCompleted': value},
                                  );
                                },
                              ),
                              title: Text('${subTask.timeSlot}: ${subTask.title}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _taskService.deleteSubTask(
                                  task.id,
                                  subTask.id,
                                ),
                              ),
                            )),
                        ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _timeSlotController,
                                  decoration: InputDecoration(
                                    labelText: 'Time Slot (e.g., 9 AM - 10 AM)',
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_timeSlotController.text.isNotEmpty) {
                                    _taskService.addSubTask(
                                      task.id,
                                      SubTask(
                                        id: DateTime.now().toString(),
                                        title: 'New Sub-task',
                                        timeSlot: _timeSlotController.text,
                                      ),
                                    );
                                    _timeSlotController.clear();
                                  }
                                },
                                child: Text('Add Sub-task'),
                              ),
                            ],
                          ),
                        ),
                      ],
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
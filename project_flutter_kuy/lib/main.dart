import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class Task {
  final int id;
  String title;
  String status;

  Task({required this.id, required this.title, required this.status});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // ← Use your Laravel API URL
  List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();
  bool loading = true;

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        tasks = data.map((e) => Task.fromJson(e)).toList();
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> addTask(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'status': 'pending'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      _controller.clear();
      await fetchTasks();
    }
  }

  Future<void> updateTask(Task task) async {
    await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': task.title, 'status': task.status}),
    );
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    await fetchTasks();
  }

  Future<void> toggleStatus(Task task) async {
    task.status = task.status == 'done' ? 'pending' : 'done';
    await updateTask(task);
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      body: RefreshIndicator(
        onRefresh: fetchTasks,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter new task title...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => addTask(_controller.text),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final task = tasks[index];
                        final titleController = TextEditingController(text: task.title);
                        return Card(
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                task.status == 'done'
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task.status == 'done'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              onPressed: () => toggleStatus(task),
                            ),
                            title: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(border: InputBorder.none),
                              onSubmitted: (value) {
                                task.title = value;
                                updateTask(task);
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTask(task.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

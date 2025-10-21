import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  final int? id;
  final String title;

  Task({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(id: map['id'], title: map['title']);
  }
}

class TaskDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'tasks.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT)',
        );
      },
    );
    return _database!;
  }

  static Future<int> insertTask(Task task) async {
    final db = await getDatabase();
    return await db.insert('tasks', task.toMap());
  }

  static Future<List<Task>> getTasks() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  static Future<int> updateTask(Task task) async {
    final db = await getDatabase();
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await getDatabase();
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

class SQLiteTasksPage extends StatefulWidget {
  const SQLiteTasksPage({super.key});

  @override
  State<SQLiteTasksPage> createState() => _SQLiteTasksPageState();
}

class _SQLiteTasksPageState extends State<SQLiteTasksPage> {
  final TextEditingController _controller = TextEditingController();
  List<Task> _tasks = [];
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addOrUpdateTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_editingId == null) {
      await TaskDatabase.insertTask(Task(title: text));
    } else {
      await TaskDatabase.updateTask(Task(id: _editingId, title: text));
      _editingId = null;
    }
    _controller.clear();
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await TaskDatabase.deleteTask(id);
    _loadTasks();
  }

  void _startEdit(Task task) {
    setState(() {
      _controller.text = task.title;
      _editingId = task.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas com SQLite')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: _editingId == null
                          ? 'Nova tarefa'
                          : 'Editar tarefa',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addOrUpdateTask,
                  child: Text(_editingId == null ? 'Adicionar' : 'Salvar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEdit(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(task.id!),
                        ),
                      ],
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

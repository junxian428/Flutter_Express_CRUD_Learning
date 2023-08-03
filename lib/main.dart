import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'ApiService.dart';

class Todo {
  final int id;
  final String title;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  setCompleted(bool newValue) {
    completed = newValue;
  }
}

void main() {
  runApp(MyApp());
}


// New EditTodoScreen widget for editing the todo
class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  EditTodoScreen({required this.todo});

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.todo.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _titleController.text);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD API',
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}


class _TodoScreenState extends State<TodoScreen> {
  final ApiService apiService = ApiService(baseUrl: 'http://localhost:3000');

  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      final response = await apiService.get('todos');
      if (response.statusCode == 200) {
        final List<dynamic> todoList = response.data;
        setState(() {
          todos = todoList.map((data) => Todo(
            id: data['id'],
            title: data['title'],
            completed: data['completed'],
          )).toList();
        });
      } else {
        // Handle API error
      }
    } catch (e) {
      // Handle network/Dio error
    }
  }

  Future<void> createTodo() async {
    try {
      final newTodo = await apiService.post('todos', {
        'title': 'New Todo',
        'completed': false,
      });
      setState(() {
        todos.add(Todo(
          id: newTodo.data['id'],
          title: newTodo.data['title'],
          completed: newTodo.data['completed'],
        ));
      });
    } catch (e) {
      // Handle API error
    }
  }



    Future<void> updateTodo(Todo todo) async {
      try {
        await apiService.put('todos/${todo.id}', {
          'completed': todo.completed,
        });
      } catch (e) {
        // Handle API error
      }
    }

    Future<void> deleteTodo(Todo todo) async {
      try {
        print('Deleting todo with id: ${todo.id}');
        await apiService.delete('todos/${todo.id}');
        setState(() {
          todos.remove(todo);
        });
      } catch (e) {
        // Handle API error
        print('Error deleting todo: $e');
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            trailing: Checkbox(
              value: todo.completed,
              onChanged: (newValue) {
                setState(() {
                  todo.completed = newValue!;
                  updateTodo(todo); // Call updateTodo to update the 'completed' status in the backend
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Call createTodo to add a new todo
              createTodo();
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Implement navigation to a screen where you can edit the todo
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              // Implement a confirmation dialog before deleting the todo
              // Call deleteTodo to delete the todo
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

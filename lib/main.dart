import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'ApiService.dart';

class Todo {
  final int id;
  String title; // Make the 'title' property mutable with no 'final' keyword
  bool completed;
  bool selected;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.selected = false,
  });

  bool get isCompleted => completed;
  set isCompleted(bool newValue) => completed = newValue;

  bool get isSelected => selected;
  set isSelected(bool newValue) => selected = newValue;

  // Add a setter for the 'title' property
  set setTitle(String newTitle) => title = newTitle;
}

void main() {
  runApp(MyApp());
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

  // Define the 'updateTodoTitle' method to update the title in the backend
  Future<void> updateTodoTitle(Todo todo, String newTitle) async {
    try {
      await apiService.put('todos/${todo.id}', {
        'title': newTitle,
      });
      setState(() {
        todo.title = newTitle; // Update the title locally after successful API call
      });
    } catch (e) {
      // Handle API error
      print(e);
    }
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

  // Function to delete selected todos
  void _deleteSelectedTodos() async {
    List<Todo> selectedTodos = todos.where((todo) => todo.completed).toList();
    for (Todo todo in selectedTodos) {
      await deleteTodo(todo);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      todo.completed = true;
      await apiService.put('todos/${todo.id}', {
        'title': todo.title,
        'completed': todo.completed,
      });
    } catch (e) {
      // Handle API error
      print(e);
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
              _editSelectedTodos();
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _deleteSelectedTodos(); // Call the function to delete selected todos
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  // Function to navigate to the EditSelectedTodosScreen when 'Edit' button is tapped
  void _editSelectedTodos() async {
    print("Editing...");
    List<Todo> selectedTodos = todos.where((todo) => todo.completed).toList();
    if (selectedTodos.isNotEmpty) {
      final newTitle = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSelectedTodosScreen(selectedTodos: selectedTodos),
        ),
      );

      if (newTitle != null) {
        updateSelectedTodos(selectedTodos, newTitle);
        updateSelectedTodosInBackend(selectedTodos);
      }
    }
  }

  // Function to update the titles of selected todos after editing
  void updateSelectedTodos(List<Todo> selectedTodos, String newTitle) {
    setState(() {
      for (Todo todo in selectedTodos) {
        todo.title = newTitle;
      }
    });
  }

  // Function to update the titles of selected todos in the backend after editing
  Future<void> updateSelectedTodosInBackend(List<Todo> selectedTodos) async {
    try {
      for (Todo todo in selectedTodos) {
        await updateTodoTitle(todo, todo.title);
      }
    } catch (e) {
      // Handle API error
    }
  }
}

class EditSelectedTodosScreen extends StatefulWidget {
  final List<Todo> selectedTodos;

  EditSelectedTodosScreen({required this.selectedTodos});

  @override
  _EditSelectedTodosScreenState createState() => _EditSelectedTodosScreenState();
}

class _EditSelectedTodosScreenState extends State<EditSelectedTodosScreen> {
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedTodos.isNotEmpty) {
      _titleController.text = widget.selectedTodos[0].title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Selected Todos'),
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

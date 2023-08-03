const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// In-memory data storage (replace this with a database in a real application)
let todos = [
  { id: 1, title: 'Learn JavaScript', completed: false },
  { id: 2, title: 'Learn Node.js', completed: false },
  { id: 3, title: 'Build a backend API', completed: false },
];

// CRUD routes

// Read all todos
app.get('/todos', (req, res) => {
    console.log("get api is called /todos");
  res.json(todos);
});

// Read a single todo by ID
app.get('/todos/:id', (req, res) => {
  console.log("get api is called /todos/:id");
  const id = parseInt(req.params.id);
  const todo = todos.find((todo) => todo.id === id);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// Create a new todo
app.post('/todos', (req, res) => {
    console.log("post api is called /todos");
  const { title, completed } = req.body;
  const id = todos.length > 0 ? todos[todos.length - 1].id + 1 : 1;
  const newTodo = { id, title, completed };
  todos.push(newTodo);
  res.status(201).json(newTodo);
});

// Update an existing todo by ID
app.put('/todos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { title, completed } = req.body;
  const index = todos.findIndex((todo) => todo.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  todos[index].title = title;
  todos[index].completed = completed;
  console.log("ID: " + index + " PUT API is called. Title " + todos[index].title + " " + todos[index].completed);
  res.json(todos[index]);
});

// Delete a todo by ID
app.delete('/todos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  console.log("Delete API is called");
  todos = todos.filter((todo) => todo.id !== id);
  res.sendStatus(204);
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

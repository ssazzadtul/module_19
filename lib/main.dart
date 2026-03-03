import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'todo_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {

  final String baseUrl = "https://jsonplaceholder.typicode.com/todos";

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load");
    }
  }

  Future<void> addTodo() async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": "New Todo",
        "completed": false,
        "userId": 1
      }),
    );
    setState(() {});
  }

  Future<void> updateTodo(int id) async {
    await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "title": "Updated Todo",
        "completed": true,
        "userId": 1
      }),
    );
    setState(() {});
  }

  Future<void> deleteTodo(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TODO App")),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<List<Todo>>(
        future: fetchTodos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Icon(
                    todo.completed
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: todo.completed ? Colors.green : Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => updateTodo(todo.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTodo(todo.id),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
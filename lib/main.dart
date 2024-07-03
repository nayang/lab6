import 'package:flutter/material.dart';
import 'data/database.dart';
import 'data/todo.dart';
import 'data/todo_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await setupDatabase();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AppDatabase database;

  const MyHomePage({Key? key, required this.database}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Todo> _todoItems = [];
  final TextEditingController _controller = TextEditingController();
  late TodoDao _todoDao;

  @override
  void initState() {
    super.initState();
    _todoDao = widget.database.todoDao;
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    final items = await _todoDao.findAllTodos();
    setState(() {
      _todoItems.clear();
      _todoItems.addAll(items);
    });
  }

  Future<void> _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      final todo = Todo(
        task: task,
      );
      await _todoDao.insertTodo(todo);
      final items = await _todoDao.findAllTodos();
      setState(() {
        _todoItems.clear();
        _todoItems.addAll(items);
      });
      _controller.clear();
    }
  }

  Future<void> _removeTodoItem(int index) async {
    final todo = _todoItems[index];
    await _todoDao.deleteTodo(todo);
    final items = await _todoDao.findAllTodos();
    setState(() {
      _todoItems.clear();
      _todoItems.addAll(items);
    });
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "${_todoItems[index].task}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _removeTodoItem(index);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a todo item',
                    ),
                  ),
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    _addTodoItem(_controller.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _todoItems.isEmpty
                ? Center(
              child: Text('There are no items in the list'),
            )
                : ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Row number: $index'),
                      SizedBox(width: 100),
                      Text(_todoItems[index].task),
                    ],
                  ),
                  onLongPress: () => _promptRemoveTodoItem(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

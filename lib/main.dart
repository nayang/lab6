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
  Todo? _selectedTodo; // 新增：选中的待办事项

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

  Future<void> _deleteTodoItem(Todo todo) async {
    await _todoDao.deleteTodo(todo);
    final items = await _todoDao.findAllTodos();
    setState(() {
      _todoItems.clear();
      _todoItems.addAll(items);
      _selectedTodo = null; // 删除后清空选中项
    });
  }

  void _showTodoDetails(Todo todo) {
    setState(() {
      _selectedTodo = todo;
    });

    // 检查当前是否为平板横屏模式
    bool isTabletLandscape = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).orientation == Orientation.landscape;
    if (!isTabletLandscape) {
      // 如果不是平板横屏模式，则导航到详情页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TodoDetailsPage(
            todo: todo,
            onDelete: () {
              _deleteTodoItem(todo);
              // 检查是否可以返回上一页
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTabletLandscape = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
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
                        onTap: () => _showTodoDetails(_todoItems[index]), // 修改：用点击事件显示详情
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 如果是平板横屏模式，则显示详情页面
          if (isTabletLandscape && _selectedTodo != null)
            VerticalDivider(),
          if (isTabletLandscape && _selectedTodo != null)
            Expanded(
              child: _buildDetailsPage(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return _selectedTodo == null
        ? Center(
      child: Text('No item selected'),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Task: ${_selectedTodo!.task}', style: TextStyle(fontSize: 20)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('ID: ${_selectedTodo!.id}', style: TextStyle(fontSize: 20)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            child: Text('Delete'),
            onPressed: () {
              _deleteTodoItem(_selectedTodo!);
            },
          ),
        ),
      ],
    );
  }
}

class TodoDetailsPage extends StatelessWidget {
  final Todo todo;
  final VoidCallback onDelete;

  const TodoDetailsPage({Key? key, required this.todo, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task: ${todo.task}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Text('ID: ${todo.id}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                onDelete();
                // 检查是否可以返回上一页
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

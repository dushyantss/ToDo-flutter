import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

const _appTitle = 'ToDo';
final _accentColor = Colors.blueGrey[700];
final _primaryColor = Colors.orange[100];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      theme: ThemeData(
        primaryColor: _primaryColor,
        accentColor: _accentColor,
        iconTheme: IconThemeData.fallback().copyWith(color: _accentColor),
        cardColor: _primaryColor,
      ),
      home: MyHomePage(title: _appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _todos = <Todo>[];

  void _addTodo(String text) {
    _todos.add(Todo(text));
  }

  void _removeTodo(Todo todo) {
    _todos.remove(todo);
  }

  void _onPressRemove(Todo todo) {
    setState(() => _removeTodo(todo));
  }

  void _onSubmit(String text) {
    final validText = text.trim();
    if (validText.length > 0) {
      setState(() {
        _addTodo(validText);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Input(
            onSubmit: _onSubmit,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, i) => ListItem(
                      key: Key(_todos[i].id),
                      todo: _todos[i],
                      handleRemove: _onPressRemove,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Input extends StatelessWidget {
  Input({Key key, @required this.onSubmit}) : super(key: key);

  final ValueChanged<String> onSubmit;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 16.0, 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: controller,
            onSubmitted: onSubmit,
          )),
          IconButton(
            onPressed: () => onSubmit(controller.text),
            icon: Icon(
              Icons.add,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}

class Todo {
  static int _nextId = 0;

  final String text;
  final String id;

  factory Todo(String text) {
    final todo = Todo._withId(_nextId.toString(), text);
    _nextId += 1;
    return todo;
  }

  Todo._withId(this.id, this.text);
}

class ListItem extends StatelessWidget {
  const ListItem({Key key, @required this.todo, @required this.handleRemove})
      : super(key: key);

  final Todo todo;
  final ValueChanged<Todo> handleRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      onDismissed: (_) => handleRemove(todo),
      child: Card(
        child: ListTile(
          title: Text(todo.text),
        ),
      ),
    );
  }
}

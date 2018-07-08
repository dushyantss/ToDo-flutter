import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

const _appTitle = 'ToDo';
final _accentColor = Colors.blueGrey[700];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      theme: ThemeData(
        primaryColor: Colors.orange[100],
        accentColor: _accentColor,
        iconTheme: IconThemeData.fallback().copyWith(color: _accentColor),
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

  void _onSubmit(String text) {
    if (text.trim().length > 0) {
      setState(() {
        _addTodo(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Input(
              onSubmit: _onSubmit,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    key: Key(_todos[i].id),
                    title: Text(_todos[i].text),
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

class Input extends StatelessWidget {
  Input({Key key, @required this.onSubmit});

  final ValueChanged<String> onSubmit;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextField(
          controller: controller,
          onSubmitted: this.onSubmit,
        )),
        IconButton(
          onPressed: () => this.onSubmit(controller.text),
          icon: Icon(
            Icons.add,
            size: 32.0,
          ),
        ),
      ],
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

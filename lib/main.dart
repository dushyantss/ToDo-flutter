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
  final _listKey = GlobalKey<AnimatedListState>();

  void _addTodo(String text) {
    _listKey.currentState.insertItem(_todos.length);
    _todos.add(Todo(text));
  }

  void _removeTodo(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos.removeAt(index);
    _listKey.currentState.removeItem(index, (context, animation) {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    });
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
              child: MyAnimatedList(
                listKey: _listKey,
                todos: _todos,
                handleRemove: _onPressRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAnimatedList extends StatelessWidget {
  const MyAnimatedList(
      {Key key,
      @required this.listKey,
      @required this.todos,
      @required this.handleRemove})
      : super(key: key);

  final List<Todo> todos;
  final GlobalKey<AnimatedListState> listKey;
  final ValueChanged<Todo> handleRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      initialItemCount: todos.length,
      itemBuilder: (context, i, animation) {
        return ListItem(
          key: Key(todos[i].id),
          todo: todos[i],
          handleRemove: handleRemove,
          animation: Tween(
            begin: Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
        );
      },
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
  const ListItem(
      {Key key,
      @required this.todo,
      this.handleRemove,
      @required this.animation})
      : super(key: key);

  final Todo todo;
  final ValueChanged<Todo> handleRemove;
  final Animation<Offset> animation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: Dismissible(
        key: key,
        onDismissed: handleRemove != null ? (_) => handleRemove(todo) : null,
        child: Card(
          child: ListTile(
            title: Text(todo.text),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

void main() => runApp(MyApp());

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
        buttonColor: _primaryColor,
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final _todos = <Todo>[];
  final _listKey = GlobalKey<AnimatedListState>();
  SharedPreferences _prefs;
  var _error;
  bool _authorized = false;
  bool _firstCheckForAuthorization = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setPrefs();
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() {
        _firstCheckForAuthorization = true;
        _authorized = false;
      });
    }
  }

  _setPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      var storedTodos =
          _prefs.getKeys().map((id) => Todo.withId(id, _prefs.getString(id)));
      for (var i = 0; i < storedTodos.length; i++) {
        _listKey.currentState?.insertItem(i);
      }
      setState(() {
        _todos.addAll(storedTodos);
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _error = e);
    }
  }

  void _addTodo(String text) {
    _listKey.currentState?.insertItem(_todos.length);
    var todo = Todo(text);
    _todos.add(todo);
    _prefs.setString(todo.id, todo.text);
  }

  void _removeTodo(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos.removeAt(index);
    _prefs.remove(todo.id);
    _listKey.currentState?.removeItem(index, (context, animation) {
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

  Widget _buildAuthorized() {
    return _error != null
        ? ErrorWidget(_error)
        : Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: MyAnimatedList(
                    listKey: _listKey,
                    todos: _todos,
                    handleRemove: _onPressRemove,
                  ),
                ),
              ),
              Input(
                onSubmit: _onSubmit,
              ),
            ],
          );
  }

  _authenticate() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } catch (e) {
      debugPrint(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated;
    });
  }

  Widget _buildAuthorize() {
    if (_firstCheckForAuthorization) {
      _firstCheckForAuthorization = false;
      _authenticate();
    }
    return Center(
      child: RaisedButton.icon(
        label: Text('Authorize to access'),
        icon: Icon(Icons.security),
        onPressed: _authenticate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _authorized ? _buildAuthorized() : _buildAuthorize(),
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
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 16.0, 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: controller,
            onSubmitted: onSubmit,
          )),
          IconButton(
            onPressed: () {
              onSubmit(controller.text);
            },
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
  static Uuid uuid = Uuid();

  final String text;
  final String id;

  Todo(this.text) : id = uuid.v4();

  Todo.withId(this.id, this.text);
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

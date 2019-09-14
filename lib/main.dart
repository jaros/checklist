import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist',
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
      ),
      home: TodoList(), //RandomWords(),
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup name generator'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _pushSaved,
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final tasks = <Todo>[Todo('one'), Todo('two'), Todo('three')];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => {},
          )
        ],
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(child: _buildTodoList()),
          buildBottomBar()
        ],
      ),
      //,
    );
  }

  Container buildBottomBar() {
    var textEditingController = TextEditingController();
    var inputField = TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter NEW task',
        contentPadding: const EdgeInsets.all(15.0),
      ),
      controller: textEditingController,
    );
    return Container(
      color: Colors.white,
      padding: new EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(child: inputField),
          IconButton(
            icon: Icon(Icons.send),
            tooltip: 'Add new task',
            onPressed: () {
              var text = textEditingController.text;
              if (text.isNotEmpty) {
                setState(() {
                  tasks.add(Todo(text));
                  textEditingController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.separated(
      separatorBuilder: (ctx, i) => Divider(),
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildRow(tasks[index], index, context);
      },
    );
  }

  Widget _buildRow(Todo todo, int index, BuildContext context) {
    print('todo: ${todo.text} is done= ${todo.done}');
    var done = todo.done;

    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: Key(todo.text),
      // Provide a function that tells the app
      // what to do after an item has been swiped away.
      onDismissed: (direction) {
        // Remove the item from the data source.
        setState(() {
          tasks.removeAt(index);
        });
        // Show a snackbar. This snackbar could also contain "Undo" actions.
        Scaffold.of(context)
            .showSnackBar(
            SnackBar(
              content: Text("${todo.text} dismissed"),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    tasks.insert(index, todo);
                  });
                },
              ),
            ));
      },
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(
          todo.text,
          style: _biggerFont,
        ),
        leading: Icon(done ? Icons.check_box : Icons.check_box_outline_blank),
        onTap: () {
          setState(() {
            todo.done = !done;
          });
        },
      ),
    );
  }
}

class Todo {
  bool done = false;
  String text;

  Todo(this.text);
}

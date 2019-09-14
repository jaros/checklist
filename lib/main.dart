import 'package:english_words/english_words.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

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
  final doneTasks = Set<Todo>();
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
      body: _buildTodoList(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: buildBottomBar(),
      ),
    );
  }

  Container buildBottomBar() {
    var textEditingController = TextEditingController();
    var inputField = TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter NEW task',
        contentPadding: const EdgeInsets.all(20.0),
      ),
      controller: textEditingController,
    );
    return Container(
      height: 50.0,
      child: Row(
        children: <Widget>[
          Expanded(child: inputField),
          IconButton(
            icon: Icon(Icons.send),
            tooltip: 'Add new task',
            onPressed: () {
              setState(() {
                print('sending tedt: ${textEditingController.text}');
                tasks.add(Todo(textEditingController.text));
                textEditingController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= tasks.length) {
          return null;
        }
        return _buildRow(tasks[index]);
      },
    );
  }

  Widget _buildRow(Todo todo) {
    print('todo: ${todo.text} is done= ${todo.done}');
    var done = todo.done;
    return ListTile(
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
    );
  }
}

class Todo {
  bool done = false;
  String text;

  Todo(this.text);
}

import 'dart:async';

import 'package:check_flut/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

var formatter = new DateFormat('MMM d HH:mm');

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final listId = 'checklist_main';
  var tasks = <Todo>[Todo('one'), Todo('two'), Todo('three')];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  //Loading counter value on start
  _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var tass = prefs.getStringList(listId) ?? [];
      tasks = tass.map((item) {
        var dividerIdx = item.lastIndexOf("-");
        var isDone = item.substring(dividerIdx + 1, item.length);
        var text = item.substring(0, dividerIdx);
        return Todo(text, isDone == "true");
      }).toList();
    });
  }

  _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var tass =
          tasks.map((todo) => todo.text + "-" + todo.done.toString()).toList();
      prefs.setStringList(listId, tass);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mainView = SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Expanded(child: _buildTodoList()),
            buildBottomBar()
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Events Calendar'),
                ),
                body: CalendarWidget(this.tasks),
              );
            })),
          )
        ],
      ),
      body: mainView,
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
      onTap: scrollBottom,
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
                  addTask(text);
                  textEditingController.clear();
                });
                scrollBottom();
              }
            },
          ),
        ],
      ),
    );
  }

  scrollBottom() {
    Timer(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut);
    });
  }

  addTask(text) {
    tasks.add(Todo(text));
    _saveTasks();
  }

  deleteTask(idx) {
    tasks.removeAt(idx);
    _saveTasks();
  }

  insertTask(int idx, Todo task) {
    tasks.insert(idx, task);
    _saveTasks();
  }

  Widget _buildTodoList() {
    return ListView.separated(
      separatorBuilder: (ctx, i) => Divider(),
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildRow(tasks[index], index, context);
      },
    );
  }

  Widget _buildRow(Todo todo, int index, BuildContext context) {
//    print('todo: ${todo.text} is done= ${todo.done}');

    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: Key(todo.text),
      // Provide a function that tells the app
      // what to do after an item has been swiped away.
      onDismissed: (direction) {
        // Remove the item from the data source.
        setState(() {
          deleteTask(index);
        });
        // Show a snackbar. This snackbar could also contain "Undo" actions.
        Scaffold.of(context)
            .removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("${todo.text} dismissed"),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                insertTask(index, todo);
              });
            },
          ),
        ));
      },
      background: Container(color: Colors.red),
      child: TodoItemRow(todo, _saveTasks),
    );
  }
}

class TodoItemRow extends StatefulWidget {
  final Todo todo;
  final Function onUpdate;

  TodoItemRow(this.todo, this.onUpdate);

  @override
  State<StatefulWidget> createState() =>
      new TodoItemRowState(this.todo, this.onUpdate);
}

class TodoItemRowState extends State<TodoItemRow> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final Todo todo;
  final Function onUpdate;

  TodoItemRowState(this.todo, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            title: Text(
              todo.text,
              style: _biggerFont,
            ),
            subtitle:
                todo.date != null ? Text(formatter.format(todo.date)) : null,
            leading: Icon(
                todo.done ? Icons.check_box : Icons.check_box_outline_blank),
            onTap: () {
              setState(() {
                todo.done = !todo.done;
                this.onUpdate();
//                _saveTasks();
              });
            },
            onLongPress: _pushItemEdit,
          ),
        ),
        Expanded(
          flex: 0,
          child: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              DatePicker.showPicker(context, pickerModel: CustomPicker(),
                  onConfirm: (date) {
                print('confirm $date');
                todo.date = date;
                this.onUpdate();
              }, locale: LocaleType.en);
            },
          ),
        ),
      ],
    );
  }

  void _pushItemEdit() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {
          var sample = ["üks", "kaks", "kolm"];
          final Iterable<ListTile> tiles = sample.map(
            (String text) {
              return ListTile(
                title: Text(
                  text,
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
              title: Text('Sample edit'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class Todo {
  bool done;
  String text;
  DateTime date;

  Todo(this.text, [this.done = false]);
}

class CustomPicker extends DateTimePickerModel {
  static const minutesStep = 15;
  static var date = DateTime.now();

  CustomPicker()
      : super(currentTime: date.subtract(Duration(minutes: date.minute)));

  @override
  DateTime finalTime() {
    DateTime time = currentTime.add(Duration(days: currentLeftIndex()));
    return currentTime.isUtc
        ? DateTime.utc(time.year, time.month, time.day, currentMiddleIndex(),
            currentRightIndex() * minutesStep)
        : DateTime(time.year, time.month, time.day, currentMiddleIndex(),
            currentRightIndex() * minutesStep);
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < 4) {
      var minutes = index * minutesStep;
      return '$minutes'.padLeft(2, "0");
    } else {
      return null;
    }
  }
}

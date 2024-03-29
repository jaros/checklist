import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:table_calendar/table_calendar.dart';

import 'checklist_page.dart';

class CalendarWidget extends StatefulWidget {

  final List<Todo> events;

  CalendarWidget(this.events);

  @override
  State<StatefulWidget> createState() {
    var filtered = events.where( (todo) => todo.date != null);

    Map<DateTime, List> es = groupBy(filtered, (todo) => new DateTime(todo.date.year, todo.date.month, todo.date.day));

    return Calendar(es);
  }

}

class Calendar extends State<CalendarWidget> with TickerProviderStateMixin {
  final CalendarController _calendarController = CalendarController();

  Map<DateTime, List> _events;
  List _selectedEvents;

  Calendar(this._events);

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

//    _events = {
//      _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
//      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
//      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
//      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
//      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
//      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
//      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
//      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7', '1', '2', '3', '4'],
//      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
//      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
//      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
//      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
//      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
//      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
//      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
//    };

    _selectedEvents = _events[_selectedDay] ?? [];
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected ' + events.toString());
    setState(() {
      _selectedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        // Switch out 2 lines below to play with TableCalendar's settings
        //-----------------------
        buildCalendar(),
        // _buildTableCalendarWithBuilders(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  TableCalendar buildCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      onDaySelected: _onDaySelected,
    );
  }

  Widget _buildEventList() {
    return ListView(
      // sort by todo.date - time
      children: _selectedEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.text),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
    );
  }

}
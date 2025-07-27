import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  // Store events in JSON-like format
  Map<String, List<Map<String, dynamic>>> _eventsData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadSampleData();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  void _loadSampleData() {
    // Sample JSON data
    _eventsData = {
      '2025-07-27': [
        {'title': 'Vaccination - Sheep #123', 'type': 'medical', 'time': '09:00'},
        {'title': 'Health Check - Flock A', 'type': 'checkup', 'time': '14:00'},
      ],
      '2025-07-28': [
        {'title': 'Feed Delivery', 'type': 'feeding', 'time': '08:00'},
      ],
      '2025-07-30': [
        {'title': 'Vet Visit - Emergency', 'type': 'emergency', 'time': '10:30'},
        {'title': 'Temperature Alert', 'type': 'alert', 'time': '15:45'},
      ],
    };
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateKey = _formatDateKey(day);
    final eventsJson = _eventsData[dateKey] ?? [];
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _addEvent(String title, String type, String time) {
    if (_selectedDay == null) return;
    
    final dateKey = _formatDateKey(_selectedDay!);
    final newEvent = {
      'title': title,
      'type': type,
      'time': time,
    };

    setState(() {
      if (_eventsData[dateKey] == null) {
        _eventsData[dateKey] = [];
      }
      _eventsData[dateKey]!.add(newEvent);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    String selectedType = 'medical';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'e.g., Vaccination - Sheep #456',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Event Type'),
              items: const [
                DropdownMenuItem(value: 'medical', child: Text('Medical')),
                DropdownMenuItem(value: 'feeding', child: Text('Feeding')),
                DropdownMenuItem(value: 'checkup', child: Text('Checkup')),
                DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                DropdownMenuItem(value: 'alert', child: Text('Alert')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => selectedType = value!,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: 'e.g., 09:00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addEvent(
                  titleController.text,
                  selectedType,
                  timeController.text.isEmpty ? 'All day' : timeController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            rangeSelectionMode: _rangeSelectionMode,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              holidayTextStyle: TextStyle(color: Colors.red[800]),
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
          ),
          const SizedBox(height: 8.0),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Events for ${_formatDateKey(_selectedDay!)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddEventDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Event'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events for this day\nTap "Add Event" to create one',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: event.getTypeColor()),
                        borderRadius: BorderRadius.circular(12.0),
                        color: event.getTypeColor().withOpacity(0.1),
                      ),
                      child: ListTile(
                        leading: Icon(
                          event.getTypeIcon(),
                          color: event.getTypeColor(),
                        ),
                        title: Text(event.title),
                        subtitle: Text('${event.type} • ${event.time}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              final dateKey = _formatDateKey(_selectedDay!);
                              _eventsData[dateKey]?.removeAt(index);
                              _selectedEvents.value = _getEventsForDay(_selectedDay!);
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Event class with JSON support
class Event {
  final String title;
  final String type;
  final String time;

  const Event({
    required this.title,
    required this.type,
    required this.time,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      type: json['type'] ?? 'other',
      time: json['time'] ?? 'All day',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'time': time,
    };
  }

  Color getTypeColor() {
    switch (type) {
      case 'medical':
        return Colors.blue;
      case 'emergency':
        return Colors.red;
      case 'feeding':
        return Colors.green;
      case 'checkup':
        return Colors.orange;
      case 'alert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'emergency':
        return Icons.emergency;
      case 'feeding':
        return Icons.restaurant;
      case 'checkup':
        return Icons.health_and_safety;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.event;
    }
  }

  @override
  String toString() => title;
}

final kFirstDay = DateTime(DateTime.now().year - 1, 1, 1);
final kLastDay = DateTime(DateTime.now().year + 1, 12, 31);

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

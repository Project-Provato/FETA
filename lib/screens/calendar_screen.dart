import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../data/events_data.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return EventsData.getEventsForDate(day);
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

  void _addEvent(String title, String type, String time, String description) {
    if (_selectedDay == null) return;
    
    final newEvent = Event(
      title: title,
      type: type,
      time: time,
      description: description,
    );

    setState(() {
      EventsData.addEvent(_selectedDay!, newEvent);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _deleteEvent(Event event) {
    if (_selectedDay == null || event.id == null) return;
    
    setState(() {
      EventsData.deleteEvent(_selectedDay!, event.id!);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'medical';
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
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
                // Time picker button
                InkWell(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedTime != null
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Time',
                            style: TextStyle(
                              color: selectedTime != null 
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : Theme.of(context).hintColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (selectedTime != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                selectedTime = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Additional details...',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final timeString = selectedTime != null
                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'All day';
                
                  _addEvent(
                    titleController.text,
                    selectedType,
                    timeString,
                    descriptionController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${event.type} • ${event.time}'),
                            if (event.description.isNotEmpty)
                              Text(
                                event.description,
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event),
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

final kFirstDay = DateTime(DateTime.now().year - 1, 1, 1);
final kLastDay = DateTime(DateTime.now().year + 1, 12, 31);

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

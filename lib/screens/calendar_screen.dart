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

  void _addEvent(String title, String type, String time, String description, int? milkProduction) {
    if (_selectedDay == null) return;
    
    final newEvent = Event(
      title: title,
      type: type,
      time: time,
      description: description,
      milkProduction: milkProduction,
    );

    setState(() {
      EventsData.addEvent(_selectedDay!, newEvent);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _addEventToPeriod(String title, String type, String time, String description, int? milkProduction) {
    if (_rangeStart == null || _rangeEnd == null) return;
    
    final days = daysInRange(_rangeStart!, _rangeEnd!);
    
    for (final day in days) {
      final newEvent = Event(
        title: title,
        type: type,
        time: time,
        description: description,
        milkProduction: milkProduction,
      );
      EventsData.addEvent(day, newEvent);
    }

    setState(() {
      _selectedEvents.value = _getEventsForRange(_rangeStart!, _rangeEnd!);
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
    double milkProduction = 0.0; // ml
    bool isRecurringEvent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(_rangeStart != null && _rangeEnd != null 
            ? 'Add Event to Period' 
            : 'Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Period indicator
                if (_rangeStart != null && _rangeEnd != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Period: ${_formatDateKey(_rangeStart!)} - ${_formatDateKey(_rangeEnd!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                
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
                    DropdownMenuItem(value: 'milking', child: Text('Milking')),
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
                
                // Milk production slider (show for milking events or all)
                if (selectedType == 'milking' || selectedType == 'feeding')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.opacity, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              selectedType == 'milking' 
                                ? 'Milk Production: ${milkProduction.round()} ml'
                                : 'Feed Amount: ${milkProduction.round()} ml',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: milkProduction,
                          min: 0,
                          max: 5000, // 5 liters max
                          divisions: 50,
                          label: '${milkProduction.round()} ml',
                          onChanged: (value) {
                            setState(() {
                              milkProduction = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0 ml', style: TextStyle(color: Colors.grey[600])),
                            Text('5000 ml', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
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
                  
                  final milkProd = (selectedType == 'milking' || selectedType == 'feeding') && milkProduction > 0
                      ? milkProduction.round()
                      : null;

                  if (_rangeStart != null && _rangeEnd != null) {
                    _addEventToPeriod(
                      titleController.text,
                      selectedType,
                      timeString,
                      descriptionController.text,
                      milkProd,
                    );
                  } else {
                    _addEvent(
                      titleController.text,
                      selectedType,
                      timeString,
                      descriptionController.text,
                      milkProd,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(_rangeStart != null && _rangeEnd != null 
                ? 'Add to Period' 
                : 'Add'),
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
        _rangeStart = null; // Clear range when selecting single day
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null; // Clear single day when selecting range
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
        actions: [
          // Toggle between single day and range selection
          IconButton(
            icon: Icon(_rangeSelectionMode == RangeSelectionMode.toggledOn 
              ? Icons.event 
              : Icons.date_range),
            onPressed: () {
              setState(() {
                if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
                  _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedDay = DateTime.now();
                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                } else {
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                  _selectedDay = null;
                }
              });
            },
            tooltip: _rangeSelectionMode == RangeSelectionMode.toggledOn 
              ? 'Single Day Mode' 
              : 'Period Selection Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode indicator
          if (_rangeSelectionMode == RangeSelectionMode.toggledOn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.blue.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.date_range, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Period Selection Mode - Tap start and end dates',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          
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
              rangeHighlightColor: Colors.blue.withOpacity(0.2),
              rangeStartDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
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
          
          // Event info section
          if (_selectedDay != null || (_rangeStart != null && _rangeEnd != null))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDay != null 
                        ? 'Events for ${_formatDateKey(_selectedDay!)}'
                        : 'Events for ${_formatDateKey(_rangeStart!)} - ${_formatDateKey(_rangeEnd!)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddEventDialog,
                    icon: const Icon(Icons.add),
                    label: Text(_rangeStart != null && _rangeEnd != null 
                      ? 'Add to Period' 
                      : 'Add Event'),
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
                  return Center(
                    child: Text(
                      _selectedDay != null 
                        ? 'No events for this day\nTap "Add Event" to create one'
                        : _rangeStart != null && _rangeEnd != null
                          ? 'No events for this period\nTap "Add to Period" to create events'
                          : 'Select a day or period to view events',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
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
                            if (event.milkProduction != null)
                              Text(
                                event.type == 'milking' 
                                  ? '🥛 Milk: ${event.milkProduction} ml'
                                  : '🍼 Feed: ${event.milkProduction} ml',
                                style: const TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
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

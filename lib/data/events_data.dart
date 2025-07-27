import '../models/event.dart';

class EventsData {
  // Made the field final and removed Flutter import
  static final Map<String, List<Map<String, dynamic>>> _eventsJson = {
    '2025-07-27': [
      {
        'id': 1,
        'title': 'Vaccination - Sheep #123',
        'type': 'medical',
        'time': '09:00',
        'description': 'Annual vaccination for sheep #123',
        'animalId': 123,
      },
      {
        'id': 2,
        'title': 'Health Check - Flock A',
        'type': 'checkup',
        'time': '14:00',
        'description': 'Routine health inspection',
        'animalId': null,
      },
    ],
    '2025-07-28': [
      {
        'id': 3,
        'title': 'Feed Delivery',
        'type': 'feeding',
        'time': '08:00',
        'description': 'Weekly feed supply delivery',
        'animalId': null,
      },
    ],
    '2025-07-30': [
      {
        'id': 4,
        'title': 'Vet Visit - Emergency',
        'type': 'emergency',
        'time': '10:30',
        'description': 'Emergency vet call for sick animal',
        'animalId': 456,
      },
      {
        'id': 5,
        'title': 'Temperature Alert',
        'type': 'alert',
        'time': '15:45',
        'description': 'High temperature detected in barn',
        'animalId': null,
      },
    ],
  };

  // Get events for a specific date
  static List<Event> getEventsForDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    final eventsJson = _eventsJson[dateKey] ?? [];
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  // Add a new event
  static void addEvent(DateTime date, Event event) {
    final dateKey = _formatDateKey(date);
    if (_eventsJson[dateKey] == null) {
      _eventsJson[dateKey] = [];
    }

    // Generate new ID
    final newId = _getNextId();
    final eventJson = event.toJson();
    eventJson['id'] = newId;

    _eventsJson[dateKey]!.add(eventJson);
  }

  // Delete an event
  static void deleteEvent(DateTime date, int eventId) {
    final dateKey = _formatDateKey(date);
    _eventsJson[dateKey]?.removeWhere((event) => event['id'] == eventId);
  }

  // Helper methods
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static int _getNextId() {
    int maxId = 0;
    for (final dayEvents in _eventsJson.values) {
      for (final event in dayEvents) {
        final id = event['id'] as int? ?? 0;
        if (id > maxId) maxId = id;
      }
    }
    return maxId + 1;
  }
}


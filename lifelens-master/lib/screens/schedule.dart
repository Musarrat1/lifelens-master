import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'package:table_calendar/table_calendar.dart';
import '../model/event.dart';  // Assuming Event class is defined here
import 'dashboard.dart';  // Import the Dashboard screen

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  DateTime today = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier<List<Event>>(_getEventsForDay(_selectedDay));
    _loadEventsFromFirestore(); // Load events from Firestore initially
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEventsFromFirestore(); // Reload events when returning to this screen
  }

  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusDay;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  // Load events from Firestore for the selected day
  void _loadEventsFromFirestore() async {
    setState(() {
      events.clear(); // Clear the existing events
    });

    QuerySnapshot snapshot = await _firestore.collection('events').get();
    snapshot.docs.forEach((doc) {
      Timestamp timestamp = doc['date'];  // Get the Timestamp
      DateTime eventDate = timestamp.toDate();  // Convert Timestamp to DateTime

      Event event = Event(doc['name'], eventDate, doc.id);  // Include the document ID for deletion
      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      events[eventDate]!.add(event);
    });

    // Update the selected events
    setState(() {
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  // Save event to Firestore with DateTime (includes time)
  void _saveEventToFirestore() async {
    String eventName = _eventController.text;
    if (eventName.isNotEmpty) {
      DateTime eventDate = _selectedDay;  // Use the selected date and time
      Event newEvent = Event(eventName, eventDate, "");  // Add a placeholder id for the event

      // Save the event in Firestore with Timestamp for the date field
      await _firestore.collection('events').add({
        'name': newEvent.name,
        'date': Timestamp.fromDate(eventDate), // Store date as Timestamp
      });

      // Update the local events map
      setState(() {
        if (events[eventDate] == null) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(newEvent);
      });

      // Close the dialog
      Navigator.of(context).pop();
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    }
  }

  // Delete event from Firestore
  void _deleteEventFromFirestore(String eventId, DateTime eventDate) async {
    await _firestore.collection('events').doc(eventId).delete(); // Delete from Firestore

    // Update local events map
    setState(() {
      events[eventDate]!.removeWhere((event) => event.id == eventId); // Remove event from local map
      if (events[eventDate]!.isEmpty) {
        events.remove(eventDate); // Remove the date if no events remain
      }
    });
    _selectedEvents.value = _getEventsForDay(_selectedDay);
  }

  // Format DateTime to show both date and time
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Schedule Overview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Dashboard(), // Navigate to Dashboard
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: Text("Event Name"),
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: _saveEventToFirestore,
                    child: Text("Submit"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Column(
      children: [
        Text("Selected Day: " + _selectedDay.toString().split(" ")[0]),
        Container(
          child: TableCalendar(
            rowHeight: 43,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: EdgeInsets.all(6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green, // Set selected day color to green
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green,
                    ),
                    child: ListTile(
                      onTap: () => print("Tapped on event"),
                      title: Text("${value[index].name}"),
                      subtitle: Text(_formatDateTime(value[index].date)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Confirm delete action before actually deleting
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete Event?"),
                                content: Text("Are you sure you want to delete this event?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _deleteEventFromFirestore(value[index].id, value[index].date);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
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
    );
  }
}

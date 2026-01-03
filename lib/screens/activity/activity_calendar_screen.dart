import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';

class ActivityCalendarScreen extends StatefulWidget {
  const ActivityCalendarScreen({Key? key}) : super(key: key);

  @override
  State<ActivityCalendarScreen> createState() => _ActivityCalendarScreenState();
}

class _ActivityCalendarScreenState extends State<ActivityCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Store activities grouped by date
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Helper to normalize dates (remove time part) so keys match
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Groups the raw Firestore data by Date
  Map<DateTime, List<Map<String, dynamic>>> _groupActivitiesByDate(List<QueryDocumentSnapshot> docs) {
    Map<DateTime, List<Map<String, dynamic>>> data = {};

    for (var doc in docs) {
      final activity = doc.data() as Map<String, dynamic>;
      if (activity['timestamp'] != null) {
        DateTime date = (activity['timestamp'] as Timestamp).toDate();
        DateTime normalizedDate = _normalizeDate(date);

        if (data[normalizedDate] == null) data[normalizedDate] = [];
        data[normalizedDate]!.add(activity);
      }
    }
    return data;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Calendar"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            _events = _groupActivitiesByDate(snapshot.data!.docs);
          }

          return Column(
            children: [
              // --- 1. CALENDAR WIDGET ---
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                
                // Styling
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.orange, // Dots for days with workouts
                    shape: BoxShape.circle,
                  ),
                ),

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
              ),

              const SizedBox(height: 20),
              const Divider(),

              // --- 2. DAILY SUMMARY SECTION ---
              Expanded(
                child: _buildDailySummary(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailySummary(bool isDark) {
    // Get activities for selected day
    final activities = _getEventsForDay(_selectedDay!);
    
    // Calculate Totals for that day
    double totalCals = 0;
    double totalMins = 0;
    for (var act in activities) {
      totalCals += double.tryParse(act['calories'].toString()) ?? 0;
      totalMins += double.tryParse(act['duration'].toString()) ?? 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date
          Text(
            DateFormat.yMMMMEEEEd().format(_selectedDay!),
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.teal[800]
            ),
          ),
          const SizedBox(height: 15),

          // Summary Cards
          Row(
            children: [
              _buildMiniCard(Icons.local_fire_department, "${totalCals.toStringAsFixed(0)} kcal", Colors.orange),
              const SizedBox(width: 15),
              _buildMiniCard(Icons.timer, "${totalMins.toStringAsFixed(0)} min", Colors.blue),
              const SizedBox(width: 15),
              _buildMiniCard(Icons.fitness_center, "${activities.length} workouts", Colors.purple),
            ],
          ),

          const SizedBox(height: 20),
          const Text("Activities:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // List of specific activities for that day
          Expanded(
            child: activities.isEmpty 
              ? Center(child: Text("No activities on this day.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final act = activities[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.teal),
                        title: Text(act['type']),
                        trailing: Text("${act['calories']} kcal"),
                        subtitle: Text("${act['duration']} mins"),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
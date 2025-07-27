import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:daytask/constants.dart'; // Assuming your constants.dart has colors like scaffoldBackgroundColor, textColor, etc.
import 'package:daytask/models/note.dart'; // To show notes on the calendar
import 'package:provider/provider.dart';
import 'package:daytask/providers/note_provider.dart';

@RoutePage()
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Note>> _events = {}; // Store events (notes) by date

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEventsForCalendar();
  }

  void _loadEventsForCalendar() {
    // Populate _events map from NoteProvider
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    _events = {}; // Clear previous events

    for (var note in noteProvider.notes) {
      // Assuming Note has a 'createdAt' or 'dueDate' field.
      // For this example, let's use a dummy date for simplification,
      // or you'd use a real date from your `Note` model.
      // E.g., DateTime eventDate = DateTime(note.createdAt.year, note.createdAt.month, note.createdAt.day);

      // Dummy date for demonstration: All notes on today's date
      final DateTime eventDate = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );

      if (_events[eventDate] == null) {
        _events[eventDate] = [];
      }
      _events[eventDate]!.add(note);
    }
    setState(() {}); // Rebuild to show events
  }

  List<Note> _getEventsForDay(DateTime day) {
    // Normalize the day to compare with keys in _events map (remove time)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay =
            focusedDay; // update `_focusedDay` to make the calendar scroll to correct month
      });
      // You can add logic here to load events for the selected day from your NoteProvider
      // For now, _getEventsForDay uses the already loaded _events map.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, // From your constants
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.router.pop(), // Goes back to previous route
        ),
        title: Text(
          'Stellar Schedule',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          // Re-load events if notes have changed in NoteProvider
          if (noteProvider.notes.length !=
              _events.values.expand((element) => element).length) {
            _loadEventsForCalendar(); // Simple check to trigger reload
          }

          return Column(
            children: [
              Container(
                margin: padding.copyWith(
                  bottom: 0,
                ), // Use your existing padding but adjust bottom
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color:
                      searchFieldFillColor, // A slightly different dark color
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TableCalendar<Note>(
                  firstDay:
                      kFirstDay, // From table_calendar constants or define your own
                  lastDay:
                      kLastDay, // From table_calendar constants or define your own
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // Hide the format button
                    titleCentered: true,
                    titleTextFormatter: (date, locale) =>
                        '${date.year} ${Constants.months[date.month - 1]}', // Custom format for "YYYY Month"
                    titleTextStyle: GoogleFonts.inter(
                      color: const Color(0xffFED36A), // Your accent color
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                    rightChevronIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: GoogleFonts.inter(color: Colors.white54),
                    defaultTextStyle: GoogleFonts.inter(color: Colors.white),
                    todayTextStyle: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    holidayTextStyle: GoogleFonts.inter(
                      color: Colors.redAccent,
                    ),
                    // Custom today/selected colors
                    todayDecoration: const BoxDecoration(
                      color: Colors.white70, // Slightly off-white for today
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color(
                        0xffFED36A,
                      ), // Your accent for selected
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffFED36A).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    markerDecoration: const BoxDecoration(
                      // For events
                      color: Colors.blueAccent, // A small blue dot for events
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5.0, // Size of the event dot
                    markersAutoAligned: true,
                    markersMaxCount: 3, // Show up to 3 dots per day
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: GoogleFonts.inter(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    weekdayStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadEventsForCalendar(); // Reload events for the new month if needed
                  },
                ),
              ),
              normalHeight,
              Expanded(
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color:
                        searchFieldFillColor, // Consistent background for event list
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      minimumHeight,
                      Expanded(
                        child: _getEventsForDay(_selectedDay!).isEmpty
                            ? Center(
                                child: Text(
                                  'No cosmic events scheduled for this day.',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _getEventsForDay(
                                  _selectedDay!,
                                ).length,
                                itemBuilder: (context, index) {
                                  final event = _getEventsForDay(
                                    _selectedDay!,
                                  )[index];
                                  return Card(
                                    color: Colors.white10,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xffFED36A),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event.content,
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

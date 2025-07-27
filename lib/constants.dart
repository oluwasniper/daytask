import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //

const scaffoldBackgroundColor = Color(0xff202832);
const searchFieldFillColor = Color(0xff455A64);
const normalHeight = SizedBox(height: 20);
const minimumHeight = SizedBox(height: 10);
const padding = EdgeInsets.all(20);

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class Constants {
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}

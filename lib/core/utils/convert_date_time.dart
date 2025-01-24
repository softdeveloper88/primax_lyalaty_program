import 'package:intl/intl.dart';

String formatDate(String dateString) {
  // Parse the input date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Define day suffixes
  String daySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Format the day with suffix
  String day = date.day.toString() + daySuffix(date.day);

  // Format the month and year
  String month = DateFormat('MMMM').format(date);
  String year = DateFormat('y').format(date);

  // Combine into the desired format
  return '$day $month $year';
}

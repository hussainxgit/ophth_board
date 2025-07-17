extension BoaliDateExtensions on DateTime {
  String get formattedDate {
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
  }

  String get monthAndDay {
    final List<String> months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[month]} ${day.toString().padLeft(2, '0')}";
  }

  String get formattedTime {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  bool isPastDate() {
    return isBefore(DateTime.now());
  }

  bool isSameDate(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  String get pastDatePeriod {
    final DateTime now = DateTime.now();
    final DateTime pastDate = DateTime(year, month, day);
    final Duration duration = now.difference(pastDate);
    if (duration.inDays == 0) {
      return 'Today';
    } else if (duration.inDays > 0) {
      return 'Yesterday';
    } else if (duration.inDays >= 7) {
      return '1 week';
    } else if (duration.inDays >= 14) {
      return '2 week';
    } else {
      return 'More than months ago';
    }
  }
}

import 'package:intl/intl.dart';

final _apiDatePrefix = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

DateTime? parseApiDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  final match = _apiDatePrefix.firstMatch(raw);
  if (match != null) {
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
  return DateTime.tryParse(raw);
}

String formatApiDate(dynamic value, {String fallback = ''}) {
  final parsed = parseApiDate(value);
  if (parsed == null) return value?.toString().trim() ?? fallback;
  return DateFormat('MMM d, yyyy').format(parsed);
}

String formatApiDateWithWeekday(dynamic value, {String fallback = ''}) {
  final parsed = parseApiDate(value);
  if (parsed == null) return value?.toString().trim() ?? fallback;
  return DateFormat('EEE, MMM d, yyyy').format(parsed);
}

String formatApiTime(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final raw = value.toString().trim();
  if (raw.isEmpty) return fallback;

  final parsed = DateTime.tryParse(raw);
  if (parsed != null && raw.contains('T')) {
    return DateFormat('h:mm a').format(parsed.toLocal());
  }

  final parts = raw.split(':');
  if (parts.length >= 2) {
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour != null && minute != null) {
      return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
    }
  }

  return raw;
}

String formatApiDateTime(dynamic date, dynamic time) {
  final dateText = formatApiDate(date);
  final timeText = formatApiTime(time);
  if (dateText.isEmpty) return timeText;
  if (timeText.isEmpty) return dateText;
  return '$dateText - $timeText';
}

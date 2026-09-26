const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String formatDateEs(DateTime date) {
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day} de ${_months[date.month - 1]}, $hh:$mm';
}

String formatDateShortEs(DateTime date) {
  return '${date.day} de ${_months[date.month - 1]}';
}

/// "07:30" from minutes since midnight.
String formatMinuteOfDay(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

/// "hace 5 min", "hace 3 h", "hace 2 días".
String formatAgoEs(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  final days = diff.inDays;
  return 'hace $days día${days == 1 ? '' : 's'}';
}

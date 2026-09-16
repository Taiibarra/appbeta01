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

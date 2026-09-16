String formatMoney(double amount) {
  final negative = amount < 0;
  final value = amount.abs();
  final wholePart = value.truncate().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < wholePart.length; i++) {
    final posFromEnd = wholePart.length - i;
    buffer.write(wholePart[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
  }
  return '${negative ? '-' : ''}\$$buffer';
}

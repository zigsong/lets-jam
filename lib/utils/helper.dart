String enumToString(dynamic enumItem) {
  return enumItem.toString().split('.').last;
}

String formatList(List<dynamic> items) {
  if (items.isEmpty) return '';

  String firstItem = items[0];

  if (items.length > 1) {
    return '$firstItem 외 ${items.length - 1}';
  } else {
    return firstItem;
  }
}

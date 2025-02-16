// items는 List<Map<String, String>> 타입
Map<String, List<String>> groupByCategory(dynamic items) {
  Map<String, List<String>> groupedRegions = {};

  for (var item in items) {
    String category = item['category'] ?? '';
    String subcategory = item['subcategory'] ?? '';

    if (category.isNotEmpty && subcategory.isNotEmpty) {
      groupedRegions.putIfAbsent(category, () => []).add(subcategory);
    }
  }

  return groupedRegions;
}

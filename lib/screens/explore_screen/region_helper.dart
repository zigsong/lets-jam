// items는 List<Map<String, String>> 타입
Map<String, List<Map<String, String>>> groupByCategory(dynamic items) {
  Map<String, List<Map<String, String>>> groupedRegions = {};

  for (var item in items) {
    String category = item['category'] ?? '';
    String subcategory = item['subcategory'] ?? '';
    String regionId = item['id'].toString();

    if (category.isNotEmpty && subcategory.isNotEmpty) {
      /** TODO: 타이핑 개선 */
      groupedRegions.putIfAbsent(category, () => []).add({
        'regionId': regionId,
        'subcategory': subcategory,
      });
    }
  }

  return groupedRegions;
}

// items는 List<Map<String, String>> 타입
typedef RegionMap = Map<String, List<Map<String, String>>>;

RegionMap groupByCategory(dynamic items) {
  RegionMap groupedRegions = {};

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

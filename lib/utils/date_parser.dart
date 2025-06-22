String getRelativeTime(DateTime timestamp) {
  final now = DateTime.now(); // 현재 시간
  final difference = now.difference(timestamp); // 현재 시간과의 차이 계산

  if (difference.inMinutes < 1) {
    return '방금 전';
  } else if (difference.inMinutes < 60) {
    // 1시간 이내
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    // 24시간 이내
    return '${difference.inHours}시간 전';
  } else {
    // 24시간 이상
    return '${difference.inDays}일 전';
  }
}

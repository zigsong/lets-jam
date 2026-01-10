String getRelativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return '방금 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}일 전';
  } else if (difference.inDays < 30) {
    return '${difference.inDays ~/ 7}주 전';
  } else if (difference.inDays < 365) {
    return '${difference.inDays ~/ 30}개월 전';
  } else {
    return '${difference.inDays ~/ 365}년 전';
  }
}

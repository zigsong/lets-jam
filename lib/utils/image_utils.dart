/// 이미지 URL을 그대로 반환합니다.
/// (Supabase Image Transformation은 Pro 플랜 필요 - 현재 캐싱만 적용)
String supabaseImageUrl(
  String url, {
  int width = 400,
  int quality = 80,
  String resize = 'cover',
}) {
  return url;
}

/// Supabase Storage URL에서 bucket 이후 경로만 추출.
/// 예: https://.../storage/v1/object/public/images/post/abc.jpg → post/abc.jpg
String? extractStoragePath(String url, {String bucket = 'images'}) {
  final segments = Uri.parse(url).pathSegments;
  final idx = segments.indexOf(bucket);
  if (idx == -1 || idx + 1 >= segments.length) return null;
  return segments.sublist(idx + 1).join('/');
}

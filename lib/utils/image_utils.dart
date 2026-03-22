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

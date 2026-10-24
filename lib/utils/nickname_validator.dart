import 'package:supabase_flutter/supabase_flutter.dart';

/// 닉네임 입력 검증 규칙과 중복 조회를 한곳에 모은다.
/// 온보딩과 프로필 작성/수정 화면이 공유한다.
class NicknameValidator {
  NicknameValidator._();

  /// 최대 글자 수.
  static const int maxLength = 8;

  /// 최소 글자 수.
  static const int minLength = 2;

  /// 허용 문자: 영어, 한글(자모 포함), 숫자, 특수문자(_ - + =).
  static final RegExp allowedPattern =
      RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_+=\-]+$');

  /// 중복 닉네임 안내 문구.
  static const String duplicateMessage = '사용 중인 닉네임이에요';

  /// 로컬 검증. 우선순위대로 첫 번째 위반 메시지를 반환, 통과하면 null.
  /// (글자 수 상한은 입력 단계에서 잘라내는 쪽이 자연스러워 여기서 다루지 않는다.
  ///  중복 검사는 네트워크가 필요해 [isDuplicate]로 분리한다.)
  static String? localError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '입력이 필요해요';
    if (value.contains(RegExp(r'\s'))) return '띄어쓰기 없이 입력해주세요';
    if (trimmed.length < minLength) return '$minLength글자 이상 입력해 주세요';
    if (!allowedPattern.hasMatch(trimmed)) {
      return '영어, 한글, 숫자, 특수문자(_, -, +, =)만 입력할 수 있어요';
    }
    return null;
  }

  /// profiles.nickname 중복 여부를 조회한다.
  /// [excludeId]가 있으면 해당 프로필(자기 자신)은 제외한다(수정 모드).
  static Future<bool> isDuplicate(
    SupabaseClient supabase,
    String nickname, {
    String? excludeId,
  }) async {
    var query =
        supabase.from('profiles').select('id').eq('nickname', nickname.trim());
    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }
    final result = await query;
    return (result as List).isNotEmpty;
  }
}

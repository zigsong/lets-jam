import 'package:firebase_analytics/firebase_analytics.dart';

/// 앱 전역 애널리틱스 헬퍼.
///
/// 화면 추적은 [observer]를 라우터에 등록하고, 커스텀 이벤트는
/// 아래 정적 메서드로 호출한다. 이벤트 이름은 GA4 컨벤션(snake_case).
class Analytics {
  Analytics._();

  static final FirebaseAnalytics instance = FirebaseAnalytics.instance;

  /// GoRouter/Navigator에 등록해 화면 전환을 자동 기록한다.
  /// route의 `settings.name`을 화면 이름으로 사용한다.
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: instance);

  /// 탭 전환 등 route 전환이 아닌 화면 진입을 수동으로 기록한다.
  static Future<void> logScreen(String screenName) {
    return instance.logScreenView(screenName: screenName);
  }

  /// 프로필 작성 완료
  static Future<void> writeProfile() {
    return instance.logEvent(name: 'write_profile');
  }

  /// 게시글 작성 완료. [postType]은 'findBand' / 'findMember' 등.
  static Future<void> writePost(String postType) {
    return instance.logEvent(
      name: 'write_post',
      parameters: {'post_type': postType},
    );
  }

  /// 게시글 찜(좋아요 추가)
  static Future<void> likePost(String postId) {
    return instance.logEvent(
      name: 'like_post',
      parameters: {'post_id': postId},
    );
  }

  /// 합주실 문의 버튼 클릭
  static Future<void> clickInquiry(String studioId) {
    return instance.logEvent(
      name: 'click_inquiry',
      parameters: {'studio_id': studioId},
    );
  }

  /// 합주실 목록 아이템 클릭
  static Future<void> selectStudio(String studioId, String? studioName) {
    return instance.logEvent(
      name: 'select_studio',
      parameters: {
        'studio_id': studioId,
        if (studioName != null) 'studio_name': studioName,
      },
    );
  }

  /// 합주실 예약하기 버튼 클릭
  static Future<void> clickStudioReservation(String studioId) {
    return instance.logEvent(
      name: 'click_studio_reservation',
      parameters: {'studio_id': studioId},
    );
  }
}

import 'package:get/get.dart';

/// [개발자 전용] isDev 유저만 볼 수 있는 미배포 기능의 노출 여부를 관리한다.
/// 설정 > JAM 개발자 테스트의 토글로 켜고 끈다.
///
/// 프로토타입 단계라 인메모리로만 유지한다(앱 재시작 시 기본값으로 초기화).
class FeatureFlagController extends GetxController {
  /// 합주실 탭 노출 여부
  final RxBool studioEnabled = false.obs;
}

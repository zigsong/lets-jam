import 'package:get/get.dart';
import 'package:lets_jam/models/session_enum.dart';

class ProfileController extends GetxController {
  /// 닉네임
  var nickname = ''.obs;

  /// 연락처
  var contact = ''.obs;

  /// 세션 (리스트)
  var sessions = <SessionEnum>[].obs;

  /// 자기소개
  var bio = ''.obs;

  /// 프로필 사진
  var profileImage = Rx<String?>(null);

  /// 배경 사진
  var backgroundImage = Rx<String?>(null);

  /// 프로필 작성 여부
  var hasProfile = false.obs;

  void setNickname(String value) {
    nickname.value = value;
  }

  void setContact(String value) {
    contact.value = value;
  }

  void setSessions(List<SessionEnum> value) {
    sessions.value = value;
  }

  void addSession(SessionEnum session) {
    if (!sessions.contains(session)) {
      sessions.add(session);
    }
  }

  void removeSession(SessionEnum session) {
    sessions.remove(session);
  }

  void setBio(String value) {
    bio.value = value;
  }

  void setProfileImage(String? value) {
    profileImage.value = value;
  }

  void setBackgroundImage(String? value) {
    backgroundImage.value = value;
  }

  void clear() {
    nickname.value = '';
    contact.value = '';
    sessions.clear();
    bio.value = '';
    profileImage.value = null;
    backgroundImage.value = null;
  }
}

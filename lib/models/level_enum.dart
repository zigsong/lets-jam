import 'package:lets_jam/models/session_enum.dart';

enum LevelEnum {
  newbie,
  beginner,
  intermediate,
  advanced,
  // master,
}

Map<LevelEnum, String> levelMap = {
  LevelEnum.newbie: '뉴비',
  LevelEnum.beginner: '초보',
  LevelEnum.intermediate: '중수',
  LevelEnum.advanced: '고수',
  // LevelEnum.master: '고인물',
};

Map<SessionEnum, Map<LevelEnum, String>> sessionLevelText = {
  SessionEnum.vocal: {
    LevelEnum.newbie: '뉴비: 노래를 처음 해봐요!',
    LevelEnum.beginner: '초보: 노래방에서 90점은 거뜬해요:)',
    LevelEnum.intermediate: '중수: 밴드에서 보컬을 해봤어요',
    LevelEnum.advanced: '고수: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.drum: {
    LevelEnum.newbie: '뉴비: 드럼은 처음 쳐봐요!',
    LevelEnum.beginner: '초보: 기본 비트는 칠 수 있어요',
    LevelEnum.intermediate: '중수: 밴드에서 드럼을 쳐봤어요',
    LevelEnum.advanced: '고수: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.guitar: {
    LevelEnum.newbie: '뉴비: 기타를 배운지 한달 됐어요!',
    LevelEnum.beginner: '초보: 기타로 한곡은 연주할 수 있어요',
    LevelEnum.intermediate: '중수: 밴드에서 기타리스트로 합주해봤어요',
    LevelEnum.advanced: '고수: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.bass: {
    LevelEnum.newbie: '뉴비: 베이스를 배운지 한달 됐어요!',
    LevelEnum.beginner: '초보: 베이스로 한곡은 연주할 수 있어요',
    LevelEnum.intermediate: '중수: 밴드에서 베이시스트로 합주해봤어요',
    LevelEnum.advanced: '고수: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.keyboard: {
    LevelEnum.newbie: '뉴비: 키보드를 배운지 한달 됐어요!',
    LevelEnum.beginner: '초보: 키보드로 한곡은 연주할 수 있어요',
    LevelEnum.intermediate: '중수: 밴드에서 키보드로 합주해봤어요',
    LevelEnum.advanced: '고수: 공연을 2회 이상 해봤어요',
  },
  // SessionEnum.etc: '그 외',
};

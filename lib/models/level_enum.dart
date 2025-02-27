import 'package:lets_jam/models/session_enum.dart';

enum LevelEnum {
  lv1,
  lv2,
  lv3,
  lv4,
}

Map<LevelEnum, String> levelMap = {
  LevelEnum.lv1: 'Lv.1',
  LevelEnum.lv2: 'Lv.2',
  LevelEnum.lv3: 'Lv.3',
  LevelEnum.lv4: 'Lv.4',
};

Map<SessionEnum, Map<LevelEnum, String>> sessionLevelText = {
  SessionEnum.vocal: {
    LevelEnum.lv1: 'Lv.1: 노래를 처음 해봐요!',
    LevelEnum.lv2: 'Lv.2: 노래방에서 90점은 거뜬해요:)',
    LevelEnum.lv3: 'Lv.3: 밴드에서 보컬을 해봤어요',
    LevelEnum.lv4: 'Lv.4: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.drum: {
    LevelEnum.lv1: 'Lv.1: 드럼은 처음 쳐봐요!',
    LevelEnum.lv2: 'Lv.2: 기본 비트는 칠 수 있어요',
    LevelEnum.lv3: 'Lv.3: 밴드에서 드럼을 쳐봤어요',
    LevelEnum.lv4: 'Lv.4: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.guitar: {
    LevelEnum.lv1: 'Lv.1: 기타를 배운지 한달 됐어요!',
    LevelEnum.lv2: 'Lv.2: 기타로 한곡은 연주할 수 있어요',
    LevelEnum.lv3: 'Lv.3: 밴드에서 기타리스트로 합주해봤어요',
    LevelEnum.lv4: 'Lv.4: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.bass: {
    LevelEnum.lv1: 'Lv.1: 베이스를 배운지 한달 됐어요!',
    LevelEnum.lv2: 'Lv.2: 베이스로 한곡은 연주할 수 있어요',
    LevelEnum.lv3: 'Lv.3: 밴드에서 베이시스트로 합주해봤어요',
    LevelEnum.lv4: 'Lv.4: 공연을 2회 이상 해봤어요',
  },
  SessionEnum.keyboard: {
    LevelEnum.lv1: 'Lv.1: 키보드를 배운지 한달 됐어요!',
    LevelEnum.lv2: 'Lv.2: 키보드로 한곡은 연주할 수 있어요',
    LevelEnum.lv3: 'Lv.3: 밴드에서 키보드로 합주해봤어요',
    LevelEnum.lv4: 'Lv.4: 공연을 2회 이상 해봤어요',
  },
  // SessionEnum.etc: '그 외',
};

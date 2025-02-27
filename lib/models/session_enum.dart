enum SessionEnum {
  vocalM,
  vocalF,
  drum,
  guitarFirst,
  guitarSecond,
  bass,
  keyboard,
  etc,
}

Map<SessionEnum, String> sessionMap = {
  SessionEnum.vocalM: '보컬(남)',
  SessionEnum.vocalF: '보컬(여)',
  SessionEnum.drum: '드럼',
  SessionEnum.guitarFirst: '퍼스트기타',
  SessionEnum.guitarSecond: '세컨기타',
  SessionEnum.bass: '베이스',
  SessionEnum.keyboard: '키보드',
  SessionEnum.etc: '그 외',
};

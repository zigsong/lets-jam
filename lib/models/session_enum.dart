/// TODO: 보컬(남/여), 기타(퍼스트/세컨) 구분하는지 확인
enum SessionEnum {
  vocal,
  drum,
  guitar,
  bass,
  keyboard,
  etc,
}

Map<SessionEnum, String> sessionMap = {
  SessionEnum.vocal: '보컬',
  SessionEnum.drum: '드럼',
  SessionEnum.guitar: '기타',
  SessionEnum.bass: '베이스',
  SessionEnum.keyboard: '키보드',
  SessionEnum.etc: '그 외',
};

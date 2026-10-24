/// 온보딩에서만 쓰는 밴드 취향(장르). 아직 프로필 모델/DB에는 없는 목업 개념이다.
enum Genre {
  rock,
  pop,
  rnbSoul,
  indie,
  metal,
  funk,
  kpop,
  jpop,
  cityPop,
  anime,
  etc
}

const Map<Genre, String> genreLabels = {
  Genre.rock: '록',
  Genre.pop: 'POP',
  Genre.rnbSoul: 'R&B/소울',
  Genre.indie: '인디',
  Genre.metal: '메탈',
  Genre.funk: '펑크',
  Genre.kpop: 'K-POP',
  Genre.jpop: 'J-POP',
  Genre.cityPop: '시티팝',
  Genre.anime: '애니',
  Genre.etc: '그 외',
};

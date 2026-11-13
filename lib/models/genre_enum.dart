/// 밴드 취향(장르) 도메인 enum.
/// profiles.genres(text[]) 컬럼에 `.name` 문자열로 저장된다.
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

/// 사용자 노출 라벨 (enum과 분리해 관리)
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

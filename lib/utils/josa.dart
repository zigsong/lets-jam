/// 마지막 글자의 받침 유무에 따라 알맞은 조사를 붙인다.
/// 예) `josa('전화', '으로', '로', rieulAsVowel: true)` -> '전화로',
///     `josa('이메일', '을', '를')` -> '이메일을'.
///
/// 받침이 있으면 [withBatchim], 없으면 [withoutBatchim]을 사용한다.
/// 단, '로/으로'처럼 ㄹ받침을 모음처럼 취급해야 하는 조사는
/// [rieulAsVowel]을 true로 넘기면 ㄹ받침도 [withoutBatchim]을 쓴다.
String josa(
  String word,
  String withBatchim,
  String withoutBatchim, {
  bool rieulAsVowel = false,
}) {
  if (word.isEmpty) return '$word$withBatchim';
  final code = word.codeUnitAt(word.length - 1);
  // 한글 음절 범위(가 ~ 힣)가 아니면 받침 있는 것으로 간주.
  if (code < 0xAC00 || code > 0xD7A3) return '$word$withBatchim';
  final jong = (code - 0xAC00) % 28; // 0: 받침 없음, 8: ㄹ받침
  final hasBatchim = jong != 0 && !(rieulAsVowel && jong == 8);
  return '$word${hasBatchim ? withBatchim : withoutBatchim}';
}

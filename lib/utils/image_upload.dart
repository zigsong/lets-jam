import 'dart:io';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

/// 원본 파일명의 확장자만 안전하게 추출합니다.
/// 영문/숫자 확장자가 아니면 빈 문자열을 반환합니다.
String _safeExtension(String path) {
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  if (dot <= 0 || dot == name.length - 1) return '';
  final ext = name.substring(dot).toLowerCase();
  return RegExp(r'^\.[a-z0-9]+$').hasMatch(ext) ? ext : '';
}

Future<List<String>> uploadImages(
  List<String> paths, {
  required String pathPrefix,
  String bucket = 'images',
}) async {
  final supabase = Supabase.instance.client;
  final urls = <String>[];
  final random = Random();

  for (final image in paths) {
    if (image.startsWith('http')) {
      urls.add(image);
      continue;
    }

    if (FileSystemEntity.typeSync(image) != FileSystemEntityType.file) {
      continue;
    }

    // 원본 파일명(공백/한글/특수문자)을 그대로 쓰면 스토리지 키 에러가 날 수 있어
    // 타임스탬프 + 랜덤값 + 안전한 확장자로만 키를 구성합니다.
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(1 << 32)}${_safeExtension(image)}';
    final res = await supabase.storage
        .from(bucket)
        .upload('$pathPrefix/$fileName', File(image));
    final filePath = res.replaceFirst('$bucket/', '');
    urls.add(supabase.storage.from(bucket).getPublicUrl(filePath));
  }

  return urls;
}

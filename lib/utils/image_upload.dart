import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<String>> uploadImages(
  List<String> paths, {
  required String pathPrefix,
  String bucket = 'images',
}) async {
  final supabase = Supabase.instance.client;
  final urls = <String>[];

  for (final image in paths) {
    if (image.startsWith('http')) {
      urls.add(image);
      continue;
    }

    if (FileSystemEntity.typeSync(image) != FileSystemEntityType.file) {
      continue;
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}-${image.split('/').last}';
    final res =
        await supabase.storage.from(bucket).upload('$pathPrefix/$fileName', File(image));
    final filePath = res.replaceFirst('$bucket/', '');
    urls.add(supabase.storage.from(bucket).getPublicUrl(filePath));
  }

  return urls;
}

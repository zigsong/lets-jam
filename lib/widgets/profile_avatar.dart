import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_jam/utils/image_utils.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (size * 2).round();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.isNotEmpty == true
          ? CachedNetworkImage(
              fadeInDuration: Duration.zero,
              imageUrl: supabaseImageUrl(imageUrl!, width: cacheWidth, quality: 80),
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
            )
          : Image.asset('assets/images/profile_avatar.png'),
    );
  }
}

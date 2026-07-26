import 'package:flutter/material.dart';
import 'package:lets_jam/screens/studio_screen/studio.dart';
import 'package:lets_jam/screens/studio_screen/studio_card.dart';
import 'package:lets_jam/screens/studio_screen/studio_like_service.dart';

/// 찜 탭 > '합주실': 내가 찜한 합주실 목록.
class LikedStudios extends StatefulWidget {
  const LikedStudios({super.key});

  @override
  State<LikedStudios> createState() => _LikedStudiosState();
}

class _LikedStudiosState extends State<LikedStudios> {
  List<Studio>? _studios; // null = 로딩 중
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await StudioLikeService.fetchLikedStudios();
      if (!mounted) return;
      setState(() {
        _studios = list;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  Future<void> _unlike(Studio studio) async {
    final current = _studios;
    if (current == null) return;

    // 낙관적 제거 후 실패하면 롤백
    setState(() {
      _studios = current.where((s) => s.id != studio.id).toList();
    });

    try {
      await StudioLikeService.unlike(studio.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _studios = current);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(
        child: Text(
          '합주실을 불러오지 못했어요',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );
    }

    final studios = _studios;
    if (studios == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (studios.isEmpty) {
      return const Center(
        child: Text(
          '아직 찜한 합주실이 없어요',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: studios.length,
      itemBuilder: (context, index) {
        final studio = studios[index];
        return StudioCard(
          room: studio,
          liked: true,
          onToggleLike: () => _unlike(studio),
        );
      },
    );
  }
}

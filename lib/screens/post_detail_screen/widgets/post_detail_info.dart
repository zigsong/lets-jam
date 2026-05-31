import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class PostDetailInfo extends StatelessWidget {
  const PostDetailInfo({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xfff5f5f5),
          border:
              Border.all(width: 1, color: ColorSeed.meticulousGrayLight.color),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          if (post.postType == PostTypeEnum.findMember)
            _filterDataList('세션',
                post.sessions.map((session) => sessionMap[session]!).toList()),
          const SizedBox(height: 8),
          if (post.regions?.isNotEmpty ?? false)
            _filterDataList('지역',
                post.regions?.map((region) => region.displayName).toList()),
          const SizedBox(height: 8),
          if (post.tags?.isNotEmpty ?? false)
            _listHashTags('해시태그', post.tags),
        ],
      ),
    );
  }

  Widget _filterDataList(String label, List<String>? tags) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: SizedBox(
            width: 48,
            child: Text(label, style: const TextStyle(fontSize: 13, height: 1)),
          ),
        ),
        if (tags != null)
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 4,
                  children: tags
                      .expand((tag) => [
                            Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xff7c7c7c),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text('•',
                                style: TextStyle(color: Color(0xff7c7c7c))),
                          ])
                      .toList()
                    ..removeLast(),
                )),
          )
      ],
    );
  }

  Widget _listHashTags(String label, List<String>? tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SizedBox(
              width: 48,
              child: Text(label, style: const TextStyle(fontSize: 13, height: 1)),
            ),
          ),
          if (tags != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: tags
                        .map((tag) => Text(tag,
                            style: const TextStyle(
                                color: Color(0xff7c7c7c),
                                fontWeight: FontWeight.w500)))
                        .toList()),
              ),
            )
        ],
      ),
    );
  }
}

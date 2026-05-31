import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/widgets/tag.dart';

class WantedSession extends StatelessWidget {
  const WantedSession({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: ColorSeed.boldOrangeRegular.color),
            borderRadius: BorderRadius.circular(10)),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            const Text('밴드에서'),
            const SizedBox(width: 4),
            ...post.sessions
                .map((session) => sessionMap[session]!)
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Tag(
                      text: tag,
                      color: TagColorEnum.orange,
                      selected: true,
                      size: TagSizeEnum.small,
                    ),
                  ),
                ),
            const SizedBox(width: 4),
            const Text('을(를) 담당하고 싶어요'),
          ],
        ));
  }
}

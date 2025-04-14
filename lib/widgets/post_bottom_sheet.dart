import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/screens/upload_screen/upload_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';

class PostBottomSheet extends StatelessWidget {
  final VoidCallback onClose;
  const PostBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: ColorSeed.boldOrangeMedium.color),
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: const Text(
              '어떤 글을 써볼까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
          Column(
            children: [
              PostBottomSheetSelect(
                postType: PostTypeEnum.findMember,
                onClose: onClose,
                title: '멤버 구하기',
                desc: '같이 합주할 멤버를 구해요.\n작성한 글은 [밴드] 게시판에서 볼 수 있어요.',
              ),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ColorSeed.boldOrangeMedium.color,
              ),
              PostBottomSheetSelect(
                  postType: PostTypeEnum.findBand,
                  onClose: onClose,
                  title: '밴드 구하기',
                  desc: '같이 합주할 밴드를 구해요.\n작성한 글은 [멤버] 게시판에서 볼 수 있어요.'),
              const SizedBox(
                height: 14,
              )
            ],
          )
        ],
      ),
    );
  }
}

class PostBottomSheetSelect extends StatelessWidget {
  final PostTypeEnum postType;
  final VoidCallback onClose;
  final String title;
  final String desc;

  const PostBottomSheetSelect({
    super.key,
    required this.postType,
    required this.onClose,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClose();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadScreen(postType: postType),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, color: ColorSeed.organizedBlackMedium.color),
            ),
            const SizedBox(
              width: 22,
            ),
            Expanded(
              child: Text(
                desc,
                style: TextStyle(
                    color: ColorSeed.organizedBlackLight.color, fontSize: 12),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20,
              color: ColorSeed.organizedBlackLight.color,
            ),
          ],
        ),
      ),
    );
  }
}

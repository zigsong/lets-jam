import 'package:flutter/material.dart';
import 'package:lets_jam/screens/upload_screen.dart';

class PostBottomSheet extends StatelessWidget {
  final VoidCallback onClose;
  const PostBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('어떤 글을 써볼까요?'),
          ),
          Column(
            children: [
              PostBottomSheetSelect(
                postType: PostTypeEnum.findSession,
                onClose: onClose,
                title: '세션 구하기',
                desc:
                    '세션을 구하기 위해 우리 밴드를 소개해요.\n글은 밴드를 찾고 있는 세션들이 볼 수 있도록 ‘밴드찾기’ 게시판에 올라가요.',
              ),
              PostBottomSheetSelect(
                postType: PostTypeEnum.findBand,
                onClose: onClose,
                title: '밴드 구하기',
                desc:
                    '밴드에 들어가기 위해 저(세션)를 소개해요.\n글은 세션을 찾고 있는 밴드들이 볼수 있도록 ‘세션찾기’ 게시판에 올라가요.',
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
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(width: 0.5, color: Color(0xff9C9C9C)),
        )),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xff9C9C9C),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    desc,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xff878787)),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            const Icon(Icons.keyboard_arrow_right, color: Color(0xff8F9098)),
          ],
        ),
      ),
    );
  }
}

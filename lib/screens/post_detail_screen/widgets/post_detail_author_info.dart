import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lets_jam/models/profile_model.dart';
import 'package:lets_jam/models/session_enum.dart';
import 'package:lets_jam/screens/profile_screen/profile_screen.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/utils/navigation.dart';
import 'package:lets_jam/widgets/modal.dart';
import 'package:lets_jam/widgets/profile_avatar.dart';

class PostDetailAuthorInfo extends StatelessWidget {
  const PostDetailAuthorInfo({
    super.key,
    required this.user,
    required this.contact,
  });

  final ProfileModel user;
  final String contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 1, color: ColorSeed.meticulousGrayLight.color),
              bottom: BorderSide(
                  width: 1, color: ColorSeed.meticulousGrayLight.color))),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                pushScreen(context, ProfileScreen(profileId: user.id))
                    .then((blocked) {
                  if (blocked == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                });
              },
              child: Row(
                children: [
                  ProfileAvatar(imageUrl: user.profileImage),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        user.sessions
                            .map((session) => sessionMap[session])
                            .join(','),
                        style: const TextStyle(color: Color(0xff838589)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSeed.boldOrangeStrong.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                showModal(
                  context: context,
                  title: '연락처 복사하기',
                  cancelText: '닫기',
                  desc: Builder(
                    builder: (modalcontext) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(modalcontext).pop();
                          Clipboard.setData(ClipboardData(text: contact));
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackbar('연락처가 복사되었어요'),
                          );
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(contact),
                            SvgPicture.asset(
                              'assets/icons/plus_copy.svg',
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text('문의하기')),
        ],
      ),
    );
  }
}

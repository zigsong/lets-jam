import 'package:flutter/material.dart';
import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecruitingCheckbox extends StatefulWidget {
  const RecruitingCheckbox({super.key, required this.post});

  final PostModel post;

  @override
  State<RecruitingCheckbox> createState() => _RecruitingCheckboxState();
}

class _RecruitingCheckboxState extends State<RecruitingCheckbox> {
  final supabase = Supabase.instance.client;
  late bool _isRecruiting = widget.post.isRecruiting;
  bool _updating = false;

  Future<void> _updateRecruiting(bool newValue) async {
    if (_updating) return;
    final previous = _isRecruiting;
    setState(() {
      _isRecruiting = newValue;
      _updating = true;
    });
    try {
      await supabase
          .from('posts')
          .update({'is_recruiting': newValue}).eq('id', widget.post.id);
      widget.post.isRecruiting = newValue;
    } catch (error) {
      debugPrint('모집 상태 변경 에러 : $error');
      if (mounted) {
        setState(() => _isRecruiting = previous);
        ScaffoldMessenger.of(context).showSnackBar(customSnackbar('변경에 실패했어요'));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = !_isRecruiting;
    return GestureDetector(
      onTap: () => _updateRecruiting(!_isRecruiting),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ColorSeed.boldOrangeLight.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 2,
                  color: isDone
                      ? ColorSeed.boldOrangeStrong.color
                      : ColorSeed.meticulousGrayMedium.color,
                ),
              ),
              child: isDone
                  ? Icon(Icons.check,
                      size: 14, color: ColorSeed.boldOrangeStrong.color)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              '모집 완료',
              style: TextStyle(
                color: ColorSeed.organizedBlackMedium.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

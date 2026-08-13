import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lets_jam/screens/studio_screen/studio_detail.dart';
import 'package:lets_jam/screens/studio_screen/studio_like_service.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/like_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 1000 단위 콤마. 13000 -> "13,000".
final _priceFormat = NumberFormat('#,###');

// 디자인 토큰 중 ColorSeed에 없는 값들.
const _navyTitle = Color(0xff0C1A30); // 합주실 이름
const _neutralDark = Color(0xff2F3036); // 섹션/라벨 텍스트
const _valueGray = Color(0xff7C7C7C); // 가격·정원 값
const _roomCardBg = Color(0xffF5F5F5); // 룸 카드 배경
const _bodyBlack = Color(0xff222222); // 기본정보 본문 (= organizedBlackMedium)
const _equipDark = Color(0xff4D4D4D); // 장비목록 (= organizedBlackLight)

const _imageHeight = 267.0;

class StudioDetailScreen extends StatefulWidget {
  const StudioDetailScreen({
    super.key,
    required this.studioId,
    this.studioName,
    this.initiallyLiked = false,
  });

  final String studioId;

  /// 로딩 중에도 곧바로 보여줄 이름 (목록에서 넘겨받음).
  final String? studioName;
  final bool initiallyLiked;

  @override
  State<StudioDetailScreen> createState() => _StudioDetailScreenState();
}

class _StudioDetailScreenState extends State<StudioDetailScreen> {
  final _supabase = Supabase.instance.client;
  late Future<StudioDetail> _detail;
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _detail = _fetch();
  }

  Future<StudioDetail> _fetch() async {
    final res = await _supabase
        .from('studios')
        .select(
            'id, studio_name, region, rooms, address, studio_phone, reservation_method, reservation_method_link, studio_photo')
        .eq('id', widget.studioId)
        .single();
    return StudioDetail.fromMap(res);
  }

  Future<void> _toggleLike() async {
    final wasLiked = _liked;
    setState(() => _liked = !wasLiked);
    try {
      if (wasLiked) {
        await StudioLikeService.unlike(widget.studioId);
      } else {
        await StudioLikeService.like(widget.studioId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _liked = wasLiked); // 실패 시 롤백
    }
  }

  Future<void> _copyPhone(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackbar('연락처를 복사했어요'));
    }
  }

  Future<void> _launch(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(customSnackbar('링크를 열 수 없어요'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<StudioDetail>(
        future: _detail,
        builder: (context, snapshot) {
          final waiting = snapshot.connectionState == ConnectionState.waiting;
          final studio = snapshot.data;

          return Stack(
            children: [
              if (snapshot.hasError)
                _buildError()
              else
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhoto(studio?.photo),
                      if (waiting) ...[
                        if (widget.studioName != null) ...[
                          const SizedBox(height: 25),
                          _buildTitle(widget.studioName!),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ] else if (studio != null) ...[
                        const SizedBox(height: 25),
                        _buildTitle(studio.name),
                        const SizedBox(height: 25),
                        _buildBasicInfo(studio),
                        const SizedBox(height: 25),
                        _buildSectionTitle('합주실 정보'),
                        const SizedBox(height: 25),
                        _buildRooms(studio.rooms),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              // 상단 네비게이션 (뒤로가기 + 찜)
              _buildNavBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('합주실 정보를 불러오지 못했어요',
              style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _detail = _fetch()),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String? photo) {
    if (photo != null) {
      return CachedNetworkImage(
        imageUrl: photo,
        width: double.infinity,
        height: _imageHeight,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(color: ColorSeed.boldOrangeLight.color),
        errorWidget: (_, __, ___) => _photoPlaceholder(),
      );
    }
    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Container(
      width: double.infinity,
      height: _imageHeight,
      color: ColorSeed.boldOrangeLight.color,
      alignment: Alignment.center,
      child: Text(
        '사진을 준비중이에요',
        style:
            TextStyle(fontSize: 13, color: ColorSeed.organizedBlackLight.color),
      ),
    );
  }

  Widget _buildNavBar() {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: topInset),
        height: topInset + 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorSeed.organizedBlackMedium.color.withOpacity(0.3),
              ColorSeed.organizedBlackMedium.color.withOpacity(0),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LikeButton(
                isLiked: _liked,
                onTap: _toggleLike,
                size: LikeButtonSize.lg,
                hasBackground: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 24,
          height: 26 / 24,
          fontWeight: FontWeight.w600,
          color: _navyTitle,
        ),
      ),
    );
  }

  Widget _buildBasicInfo(StudioDetail studio) {
    final rows = <Widget>[
      if (studio.address != null)
        _infoRow(
          icon: Icons.place_outlined,
          text: studio.address!,
          trailingIcon: Icons.north_east,
          onTap: () => _launch(
              'https://map.naver.com/p/search/${Uri.encodeComponent(studio.address!)}'),
        ),
      if (studio.phone != null)
        _infoRow(
          icon: Icons.phone_android_outlined,
          text: studio.phone!,
          onTap: () => _copyPhone(studio.phone!),
          trailing: GestureDetector(
            onTap: () => _copyPhone(studio.phone!),
            behavior: HitTestBehavior.opaque,
            child: SvgPicture.asset(
              'assets/icons/plus_copy.svg',
              width: 16,
              height: 16,
            ),
          ),
        ),
      if (studio.reservationMethod != null)
        _infoRow(
          icon: Icons.today_outlined,
          text: '${studio.reservationMethod}으로 문의',
          onTap: studio.reservationLink == null
              ? null
              : () => _launch(studio.reservationLink),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: ColorSeed.meticulousGrayLight.color),
          const SizedBox(height: 20),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            rows[i],
          ],
          const SizedBox(height: 20),
          Divider(height: 1, color: ColorSeed.meticulousGrayLight.color),
          const SizedBox(height: 20),
          _buildReserveButton(studio.reservationLink),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    IconData? trailingIcon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: _neutralDark),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w500,
                color: _bodyBlack,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing,
          ] else if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(trailingIcon,
                size: 12, color: ColorSeed.meticulousGrayMedium.color),
          ],
        ],
      ),
    );
  }

  Widget _buildReserveButton(String? link) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: link == null ? null : () => _launch(link),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorSeed.boldOrangeStrong.color,
          disabledBackgroundColor: ColorSeed.boldOrangeRegular.color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          '예약하기',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w500,
          color: _neutralDark,
        ),
      ),
    );
  }

  Widget _buildRooms(List<StudioRoom> rooms) {
    if (rooms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('등록된 룸 정보가 없어요',
            style: TextStyle(fontSize: 13, color: _valueGray)),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < rooms.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _RoomCard(room: rooms[i]),
        ],
      ],
    );
  }
}

/// 룸 카드 (회색 배경 + 가격/정원/장비목록).
class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room});

  final StudioRoom room;

  String get _priceText {
    if (room.price == null) return '가격 문의';
    return '${_priceFormat.format(room.price)}원 (1시간당)';
  }

  String get _capacityText {
    final cap = room.capacity;
    final max = room.maxCapacity;
    if (cap == null && max == null) return '정보 없음';
    final buffer = StringBuffer();
    if (cap != null) buffer.write('$cap명');
    if (max != null) buffer.write('${cap != null ? ' ' : ''}($max명)');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _roomCardBg,
        border: Border.all(color: ColorSeed.meticulousGrayLight.color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              room.name,
              style: const TextStyle(
                fontSize: 17,
                height: 22 / 17,
                fontWeight: FontWeight.w500,
                color: _neutralDark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row('가격', Text(_priceText, style: _valueStyle)),
          _row('정원(최대인원)', Text(_capacityText, style: _valueStyle)),
          _row('장비목록', _equipments()),
        ],
      ),
    );
  }

  Widget _equipments() {
    if (room.equipments.isEmpty) {
      return const Text('정보 없음', style: _equipStyle);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in room.equipments)
          Text(e.displayLine, style: _equipStyle),
      ],
    );
  }

  Widget _row(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: _neutralDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: value),
        ],
      ),
    );
  }

  static const _valueStyle = TextStyle(
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w500,
    color: _valueGray,
  );

  static const _equipStyle = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: _equipDark,
  );
}

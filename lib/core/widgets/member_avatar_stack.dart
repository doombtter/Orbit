import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

/// 멤버들을 둥근 도트로 겹쳐서 표시. 그룹 정체성을 가장 잘 나타내는 컴포넌트.
///
/// [colors]는 멤버 가입 순서대로의 컬러. [maxVisible]을 넘으면 +N 표시.
/// [size]는 도트 한 개의 지름.
class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({
    super.key,
    required this.colors,
    this.maxVisible = 4,
    this.size = 22,
    this.borderColor = OrbitTokens.surface,
    this.borderWidth = 2,
  });

  final List<Color> colors;
  final int maxVisible;
  final double size;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final visible = colors.take(maxVisible).toList();
    final overflow = colors.length - visible.length;
    final overlap = size * 0.27; // 약 27% 겹침

    final dots = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      dots.add(_dot(visible[i], i == 0 ? 0 : -overlap));
    }
    if (overflow > 0) {
      dots.add(_overflowDot(overflow, -overlap));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: dots);
  }

  Widget _dot(Color color, double leftMargin) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(left: leftMargin),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }

  Widget _overflowDot(int count, double leftMargin) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(left: leftMargin),
      decoration: BoxDecoration(
        color: OrbitTokens.primary60,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: TextStyle(
          color: OrbitTokens.background,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }
}

/// 단일 멤버 이니셜 아바타 (이벤트 작성자 표시용)
class MemberInitialAvatar extends StatelessWidget {
  const MemberInitialAvatar({
    super.key,
    required this.initial,
    required this.color,
    this.size = 24,
  });

  final String initial;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial.isEmpty ? '?' : initial.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.46,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }
}

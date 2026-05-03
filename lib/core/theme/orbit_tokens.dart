import 'package:flutter/material.dart';

/// Orbit 디자인 토큰
/// 모든 색상/간격/라운드는 여기서만 정의. 다른 곳에서 직접 hex 쓰지 말 것.
class OrbitTokens {
  OrbitTokens._();

  // ─── Primary (차콜) ───────────────────────────────
  /// 텍스트, 주요 액션
  static const Color primary = Color(0xFF292524);
  /// 호버, 강조
  static const Color primary80 = Color(0xFF44403C);
  /// 서브 텍스트
  static const Color primary60 = Color(0xFF78716C);
  /// 힌트, 비활성, 메타
  static const Color primary40 = Color(0xFFA8A29E);

  // ─── Accent (베이지) ──────────────────────────────
  /// CTA, 강조 액션
  static const Color accent = Color(0xFFD4A574);
  /// 라이트 액센트 배경 (배지, 칩)
  static const Color accent50 = Color(0xFFF5E6D3);

  // ─── Surface ──────────────────────────────────────
  /// 카드, 시트, 다이얼로그
  static const Color surface = Color(0xFFFFFFFF);
  /// 화면 배경 (살짝 따뜻한 종이 톤)
  static const Color background = Color(0xFFFAFAF7);
  /// 매우 연한 회색 — 아이콘 배경 등
  static const Color surfaceDim = Color(0xFFF5F5F4);

  // ─── Border ───────────────────────────────────────
  static const Color border = Color(0xFFE7E5E0);
  static const Color borderStrong = Color(0xFFD6D3D1);

  // ─── Semantic ─────────────────────────────────────
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);

  // ─── 멤버 컬러 팔레트 ─────────────────────────────
  /// 그룹 멤버에게 자동 할당. 6명 이상이면 순환.
  /// 베이지 톤과 어울리게 채도를 살짝 낮춤
  static const List<Color> memberPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFD97706), // Amber
    Color(0xFF059669), // Emerald
    Color(0xFFDB2777), // Pink
    Color(0xFF0891B2), // Cyan
    Color(0xFF7C3AED), // Violet
  ];

  /// 멤버 인덱스로부터 색상을 결정 (가입 순서 기반)
  static Color memberColor(int index) =>
      memberPalette[index % memberPalette.length];

  // ─── Spacing ──────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  // ─── Radius ───────────────────────────────────────
  /// 작은 요소 (칩, 도트)
  static const double radiusSm = 8;
  /// 표준 (버튼, 셀)
  static const double radiusMd = 12;
  /// 카드, 일정 항목
  static const double radiusLg = 14;
  /// 그룹 카드, 큰 카드
  static const double radiusXl = 18;
  /// 화면 컨테이너
  static const double radius2xl = 24;

  // ─── Typography sizes ─────────────────────────────
  static const double fsDisplay = 26;
  static const double fsHeading = 22;
  static const double fsTitle = 17;
  static const double fsBody = 15;
  static const double fsLabel = 13;
  static const double fsCaption = 12;
  static const double fsMicro = 11;
}

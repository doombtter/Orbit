import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

/// 화면 하단에 떠 있는 캡슐형 네비게이션 바.
/// - 화이트 배경 + 부드러운 그림자로 종이 위에 떠 있는 느낌
/// - 라벨 없이 아이콘만, 선택된 탭은 베이지 원형 배경으로 강조
/// - 하단 시스템 영역(제스처바)으로부터 충분한 여백
class OrbitNavBar extends StatelessWidget {
  const OrbitNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<OrbitNavItem> items;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        OrbitTokens.space24,
        0,
        OrbitTokens.space24,
        // 제스처바 영역 + 추가 여백 (시각적 호흡)
        bottomInset + OrbitTokens.space12,
      ),
      child: PhysicalShape(
        elevation: 12,
        shadowColor: OrbitTokens.primary.withValues(alpha: 0.16),
        color: OrbitTokens.surface,
        clipper: const ShapeBorderClipper(
          shape: StadiumBorder(),
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: OrbitTokens.border, width: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: OrbitTokens.space8),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: _NavTile(
                  item: items[i],
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class OrbitNavItem {
  const OrbitNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label; // 접근성용. 시각적으로는 표시 안 함
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final OrbitNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? OrbitTokens.accent50 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: selected
                    ? OrbitTokens.primary
                    : OrbitTokens.primary40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

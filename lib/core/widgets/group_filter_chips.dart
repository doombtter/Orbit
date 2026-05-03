import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

/// 그룹 필터 칩 행. "전체" + 각 그룹 칩.
/// 단일 선택 (전체 선택 시 모든 그룹의 데이터, 그룹 선택 시 해당 그룹만).
///
/// MVP는 단일 선택. 추후 다중 선택으로 확장 가능.
class GroupFilterChips extends StatelessWidget {
  const GroupFilterChips({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  /// (groupId, groupName) 쌍의 리스트
  final List<({String id, String name})> groups;

  /// 선택된 groupId. null이면 "전체"
  final String? selectedGroupId;

  /// null = "전체" 선택, String = 특정 그룹 선택
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OrbitTokens.space20),
        children: [
          _Chip(
            label: '전체',
            selected: selectedGroupId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: OrbitTokens.space6),
          for (final g in groups) ...[
            _Chip(
              label: g.name,
              selected: selectedGroupId == g.id,
              onTap: () => onSelected(g.id),
            ),
            const SizedBox(width: OrbitTokens.space6),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? OrbitTokens.primary : OrbitTokens.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? null
                : Border.all(color: OrbitTokens.border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: OrbitTokens.space14,
            vertical: 8,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: OrbitTokens.fsLabel,
              fontWeight: FontWeight.w500,
              color:
                  selected ? OrbitTokens.background : OrbitTokens.primary,
            ),
          ),
        ),
      ),
    );
  }
}

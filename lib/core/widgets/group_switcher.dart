import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

/// 상단 헤더에 들어가는 그룹 스위처 칩.
/// 현재 선택된 그룹명 + 화살표를 표시. 탭하면 그룹 선택 시트가 올라옴.
class GroupSwitcher extends StatelessWidget {
  const GroupSwitcher({
    super.key,
    required this.label,
    required this.onTap,
  });

  /// 현재 선택된 그룹명. null이면 "전체" 표시.
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OrbitTokens.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: OrbitTokens.border, width: 0.5),
          ),
          padding: const EdgeInsets.fromLTRB(
            OrbitTokens.space14,
            8,
            OrbitTokens.space10,
            8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: OrbitTokens.fsLabel,
                  fontWeight: FontWeight.w500,
                  color: OrbitTokens.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.expand_more,
                size: 18,
                color: OrbitTokens.primary60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 그룹 선택 시트 — 빠른 전환용
class GroupSwitcherSheet extends StatelessWidget {
  const GroupSwitcherSheet({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  final List<({String id, String name, int memberCount})> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OrbitTokens.space20,
          OrbitTokens.space12,
          OrbitTokens.space20,
          OrbitTokens.space20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 그랩 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: OrbitTokens.primary40,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OrbitTokens.space20),
            Text(
              '궤도 전환',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: OrbitTokens.space12),
            _GroupRow(
              label: '전체',
              meta: '모든 궤도의 일정과 핀',
              icon: Icons.public,
              selected: selectedGroupId == null,
              onTap: () {
                onSelected(null);
                Navigator.of(context).pop();
              },
            ),
            for (final g in groups)
              _GroupRow(
                label: g.name,
                meta: '멤버 ${g.memberCount}명',
                icon: Icons.group_outlined,
                selected: selectedGroupId == g.id,
                onTap: () {
                  onSelected(g.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.label,
    required this.meta,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String meta;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OrbitTokens.space8),
      child: Material(
        color: selected ? OrbitTokens.accent50 : OrbitTokens.surface,
        borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
              border: Border.all(
                color: selected ? OrbitTokens.accent : OrbitTokens.border,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: OrbitTokens.space14,
              vertical: OrbitTokens.space12,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: OrbitTokens.primary),
                const SizedBox(width: OrbitTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: OrbitTokens.primary40),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: OrbitTokens.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/member_avatar_stack.dart';
import '../../../../core/widgets/orbit_button.dart';
import '../../../../core/widgets/orbit_card.dart';
import '../../domain/group.dart';
import '../providers/group_providers.dart';
import '../widgets/group_create_sheet.dart';
import '../widgets/invite_link_sheet.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);

    return Scaffold(
      backgroundColor: OrbitTokens.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('내 궤도'),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (groups) => groups.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        OrbitTokens.space20,
                        OrbitTokens.space8,
                        OrbitTokens.space20,
                        // 하단 + 버튼 공간 + 네비바 공간
                        140,
                      ),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: OrbitTokens.space10),
                      itemBuilder: (_, i) => _GroupItem(group: groups[i]),
                    ),
            ),
            Positioned(
              left: OrbitTokens.space20,
              right: OrbitTokens.space20,
              bottom: OrbitTokens.space16,
              child: OrbitButton(
                label: '새 궤도 만들기',
                icon: Icons.add,
                variant: OrbitButtonVariant.accent,
                fullWidth: true,
                onPressed: () => _showCreate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreate(BuildContext context) async {
    final result = await showModalBottomSheet<GroupCreateResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OrbitTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OrbitTokens.radius2xl),
        ),
      ),
      builder: (_) => const GroupCreateSheet(),
    );

    if (result == null || !context.mounted) return;

    // 만들자마자 초대 링크 시트 띄우기
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OrbitTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OrbitTokens.radius2xl),
        ),
      ),
      builder: (_) => InviteLinkSheet(
        groupName: result.group.name,
        inviteLink: result.inviteLink,
        hasSecret: result.group.hasSecretEnabled,
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final memberColors = List.generate(
      group.memberIds.length,
      (i) => OrbitTokens.memberColor(i),
    );

    return OrbitCard(
      onTap: () {
        // TODO: 그룹 상세
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: OrbitTokens.surfaceDim,
              borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
            ),
            child: Icon(_groupIcon(group.type),
                size: 22, color: OrbitTokens.primary),
          ),
          const SizedBox(width: OrbitTokens.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '멤버 ${group.memberIds.length}명',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OrbitTokens.primary40,
                      ),
                ),
              ],
            ),
          ),
          MemberAvatarStack(colors: memberColors),
        ],
      ),
    );
  }

  IconData _groupIcon(GroupType type) => switch (type) {
        GroupType.family => Icons.people_alt_outlined,
        GroupType.couple => Icons.favorite_border,
        GroupType.team => Icons.work_outline,
        GroupType.friends => Icons.celebration_outlined,
        GroupType.other => Icons.group_outlined,
      };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 48, color: OrbitTokens.primary40),
            const SizedBox(height: OrbitTokens.space16),
            Text(
              '아직 궤도가 없어요',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: OrbitTokens.space6),
            Text(
              '아래 버튼으로 첫 궤도를 만들어보세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OrbitTokens.primary60,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

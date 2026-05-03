import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/orbit_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/invite_link.dart';
import '../../domain/group.dart';
import '../providers/group_providers.dart';

/// 그룹 생성 시트. 완료 시 [InviteResult]를 반환.
class GroupCreateSheet extends ConsumerStatefulWidget {
  const GroupCreateSheet({super.key});

  @override
  ConsumerState<GroupCreateSheet> createState() => _GroupCreateSheetState();
}

class _GroupCreateSheetState extends ConsumerState<GroupCreateSheet> {
  final _name = TextEditingController();
  GroupType _type = GroupType.family;
  bool _enableSecret = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          OrbitTokens.space20,
          OrbitTokens.space12,
          OrbitTokens.space20,
          MediaQuery.of(context).viewInsets.bottom + OrbitTokens.space20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const Text(
              '새 궤도 만들기',
              style: TextStyle(
                fontSize: OrbitTokens.fsHeading,
                fontWeight: FontWeight.w600,
                color: OrbitTokens.primary,
              ),
            ),
            const SizedBox(height: OrbitTokens.space20),

            // 이름
            const _Label('이름'),
            const SizedBox(height: OrbitTokens.space6),
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: '예) 우리 가족',
                counterText: '',
              ),
            ),
            const SizedBox(height: OrbitTokens.space16),

            // 타입
            const _Label('관계'),
            const SizedBox(height: OrbitTokens.space8),
            Wrap(
              spacing: OrbitTokens.space6,
              runSpacing: OrbitTokens.space6,
              children: [
                for (final t in GroupType.values)
                  _TypeChip(
                    label: _typeLabel(t),
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),

            const SizedBox(height: OrbitTokens.space20),

            // 비밀 메모 토글
            Container(
              decoration: BoxDecoration(
                color: OrbitTokens.surface,
                borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
                border: Border.all(color: OrbitTokens.border, width: 0.5),
              ),
              padding: const EdgeInsets.all(OrbitTokens.space14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 18, color: OrbitTokens.primary),
                      const SizedBox(width: OrbitTokens.space8),
                      const Expanded(
                        child: Text(
                          '비밀 메모 사용',
                          style: TextStyle(
                            fontSize: OrbitTokens.fsTitle,
                            fontWeight: FontWeight.w500,
                            color: OrbitTokens.primary,
                          ),
                        ),
                      ),
                      Switch(
                        value: _enableSecret,
                        onChanged: (v) => setState(() => _enableSecret = v),
                        activeColor: OrbitTokens.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: OrbitTokens.space6),
                  const Text(
                    '계정 비밀번호 같은 정보를 암호화해서 저장. 초대 링크에 키가 포함되며, 한 번 설정 후 변경할 수 없어요.',
                    style: TextStyle(
                      fontSize: OrbitTokens.fsCaption,
                      color: OrbitTokens.primary60,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OrbitTokens.space20),

            // 액션
            Row(
              children: [
                Expanded(
                  child: OrbitButton(
                    label: '취소',
                    variant: OrbitButtonVariant.outline,
                    fullWidth: true,
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: OrbitTokens.space10),
                Expanded(
                  child: OrbitButton(
                    label: _submitting ? '만드는 중…' : '만들기',
                    variant: OrbitButtonVariant.accent,
                    fullWidth: true,
                    onPressed:
                        _submitting || _name.text.trim().isEmpty ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _submitting = true);

    try {
      final result = await ref.read(groupRepositoryProvider).createGroup(
            name: _name.text.trim(),
            type: _type,
            ownerId: user.uid,
            enableSecret: _enableSecret,
          );

      if (!mounted) return;

      // 생성된 그룹을 자동 선택
      ref.read(selectedGroupIdProvider.notifier).state = result.group.id;

      // 초대 링크 미리 만들어서 결과로 전달 (다음 화면에서 공유 다이얼로그 등에 사용)
      final link = InviteLink.build(
        inviteCode: result.group.inviteCode,
        secretPassword: result.autoPassword,
      );

      Navigator.of(context).pop(
        GroupCreateResult(group: result.group, inviteLink: link),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('그룹 생성에 실패했어요: $e')),
      );
    }
  }

  String _typeLabel(GroupType t) => switch (t) {
        GroupType.family => '가족',
        GroupType.couple => '연인',
        GroupType.team => '팀',
        GroupType.friends => '친구',
        GroupType.other => '기타',
      };
}

class GroupCreateResult {
  const GroupCreateResult({required this.group, required this.inviteLink});
  final Group group;
  final Uri inviteLink;
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: OrbitTokens.fsLabel,
        fontWeight: FontWeight.w500,
        color: OrbitTokens.primary60,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
